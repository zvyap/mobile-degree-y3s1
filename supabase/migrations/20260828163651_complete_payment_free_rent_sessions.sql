drop index public.rentals_one_blocking_per_user_idx;
create unique index rentals_one_blocking_per_user_idx
  on public.rentals (user_id)
  where user_id is not null
    and status in (
      'reserved', 'pending_authorization', 'authorized', 'active', 'returning',
      'payment_pending', 'payment_failed'
    );

drop index public.rentals_one_engaged_per_bike_idx;
create unique index rentals_one_engaged_per_bike_idx
  on public.rentals (bike_id)
  where status in (
    'reserved', 'pending_authorization', 'authorized', 'active', 'returning'
  );

create or replace function private.reserve_rental_session(p_qr_token uuid)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_candidate_id bigint;
  v_existing public.rentals%rowtype;
  v_candidate_rental public.rentals%rowtype;
  v_bike public.bikes%rowtype;
  v_plan public.rental_plans%rowtype;
  v_rental public.rentals%rowtype;
begin
  if v_user_id is null then
    raise exception using errcode = 'P0001', message = 'not_authenticated';
  end if;

  if not exists (
    select 1
    from public.profiles as profile
    where profile.id = v_user_id and profile.account_status = 'active'
  ) then
    raise exception using errcode = 'P0001', message = 'account_unavailable';
  end if;

  select bike.id
  into v_candidate_id
  from public.bikes as bike
  where bike.qr_token = p_qr_token;

  if v_candidate_id is null then
    raise exception using errcode = 'P0001', message = 'bike_not_found';
  end if;

  select rental.*
  into v_existing
  from public.rentals as rental
  where rental.user_id = v_user_id
    and rental.status in (
      'reserved', 'pending_authorization', 'authorized', 'active', 'returning',
      'payment_pending', 'payment_failed'
    )
  order by rental.id
  limit 1;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_candidate_id or bike.id = v_existing.bike_id
  order by bike.id
  for update;

  if v_existing.id is not null then
    select rental.*
    into v_existing
    from public.rentals as rental
    where rental.id = v_existing.id
    for update;

    if v_existing.status in ('reserved', 'pending_authorization')
      and v_existing.reservation_expires_at <= now() then
      update public.rentals
      set status = 'cancelled',
          cancelled_at = now(),
          failure_reason = 'reservation_expired'
      where id = v_existing.id;

      update public.rental_payments
      set status = 'cancelled', processed_at = now()
      where rental_id = v_existing.id and status = 'pending';

      update public.bikes
      set status = 'available', current_station_id = v_existing.start_station_id
      where id = v_existing.bike_id;

      perform private.add_rental_event(
        v_existing.id,
        v_user_id,
        'reservation_expired'
      );
    elsif v_existing.status = 'reserved'
      and v_existing.bike_id = v_candidate_id
      and not v_existing.payment_required then
      return v_existing;
    else
      raise exception using errcode = 'P0001', message = 'active_rental_exists';
    end if;
  end if;

  select bike.*
  into v_bike
  from public.bikes as bike
  where bike.id = v_candidate_id
  for update;

  if v_bike.status = 'reserved' then
    select rental.*
    into v_candidate_rental
    from public.rentals as rental
    where rental.bike_id = v_bike.id
      and rental.status in ('reserved', 'pending_authorization')
    order by rental.id desc
    limit 1
    for update;

    if v_candidate_rental.id is not null
      and v_candidate_rental.reservation_expires_at <= now() then
      update public.rentals
      set status = 'cancelled',
          cancelled_at = now(),
          failure_reason = 'reservation_expired'
      where id = v_candidate_rental.id;

      update public.rental_payments
      set status = 'cancelled', processed_at = now()
      where rental_id = v_candidate_rental.id and status = 'pending';

      update public.bikes
      set status = 'available',
          current_station_id = v_candidate_rental.start_station_id
      where id = v_candidate_rental.bike_id
      returning * into v_bike;

      perform private.add_rental_event(
        v_candidate_rental.id,
        v_candidate_rental.user_id,
        'reservation_expired'
      );
    end if;
  end if;

  if v_bike.status <> 'available' or v_bike.current_station_id is null then
    raise exception using errcode = 'P0001', message = 'bike_unavailable';
  end if;

  select plan.*
  into v_plan
  from public.rental_plans as plan
  where plan.is_active
    and plan.valid_from <= now()
    and (plan.valid_until is null or plan.valid_until > now())
  order by plan.valid_from desc
  limit 1;

  if v_plan.id is null then
    raise exception using errcode = 'P0001', message = 'rental_plan_unavailable';
  end if;

  insert into public.rentals (
    user_id,
    bike_id,
    rental_plan_id,
    payment_method_id,
    payment_required,
    start_station_id,
    status,
    currency,
    unlock_fee,
    per_minute_rate,
    hold_amount,
    reservation_expires_at
  )
  values (
    v_user_id,
    v_bike.id,
    v_plan.id,
    null,
    false,
    v_bike.current_station_id,
    'reserved',
    v_plan.currency,
    v_plan.unlock_fee,
    v_plan.per_minute_rate,
    v_plan.hold_amount,
    now() + interval '10 minutes'
  )
  returning * into v_rental;

  update public.bikes
  set status = 'reserved'
  where id = v_bike.id;

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'bike_reserved',
    jsonb_build_object(
      'bike_id', v_bike.id,
      'reservation_expires_at', v_rental.reservation_expires_at,
      'payment_required', false
    )
  );

  return v_rental;
end;
$$;

create or replace function private.start_rental(p_rental_id bigint)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_bike_id bigint;
  v_rental public.rentals%rowtype;
begin
  if v_user_id is null then
    raise exception using errcode = 'P0001', message = 'not_authenticated';
  end if;

  select rental.bike_id into v_bike_id
  from public.rentals as rental
  where rental.id = p_rental_id;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_bike_id
  for update;

  select rental.*
  into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id
  for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if not (
    (v_rental.status = 'reserved' and not v_rental.payment_required)
    or (v_rental.status = 'authorized' and v_rental.payment_required)
  ) then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;
  if v_rental.payment_required and not exists (
    select 1
    from public.rental_payments as payment
    where payment.rental_id = v_rental.id
      and payment.kind = 'authorization'
      and payment.status = 'succeeded'
  ) then
    raise exception using errcode = 'P0001', message = 'payment_authorization_required';
  end if;

  update public.bikes
  set status = 'in_use', current_station_id = null
  where id = v_rental.bike_id and status = 'reserved';

  if not found then
    raise exception using errcode = 'P0001', message = 'bike_unavailable';
  end if;

  update public.rentals
  set status = 'active', started_at = now(), reservation_expires_at = null
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(v_rental.id, v_user_id, 'rental_started');
  return v_rental;
end;
$$;

create or replace function private.cancel_rental(p_rental_id bigint)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_bike_id bigint;
  v_rental public.rentals%rowtype;
begin
  if v_user_id is null then
    raise exception using errcode = 'P0001', message = 'not_authenticated';
  end if;

  select rental.bike_id into v_bike_id
  from public.rentals as rental
  where rental.id = p_rental_id;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_bike_id
  for update;

  select rental.*
  into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id
  for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if v_rental.status not in ('reserved', 'pending_authorization', 'authorized') then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;

  update public.rental_payments
  set status = 'cancelled', processed_at = now()
  where rental_id = v_rental.id and status = 'pending';

  if v_rental.payment_required and exists (
    select 1
    from public.rental_payments as payment
    where payment.rental_id = v_rental.id
      and payment.kind = 'authorization'
      and payment.status = 'succeeded'
  ) then
    insert into public.rental_payments (
      rental_id, user_id, kind, status, amount, currency, provider
    )
    select
      v_rental.id,
      v_user_id,
      'release',
      'pending',
      v_rental.hold_amount,
      v_rental.currency,
      method.provider
    from public.payment_methods as method
    where method.id = v_rental.payment_method_id;
  end if;

  update public.bikes
  set status = 'available', current_station_id = v_rental.start_station_id
  where id = v_rental.bike_id;

  update public.rentals
  set status = 'cancelled', cancelled_at = now(), failure_reason = 'user_cancelled'
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(v_rental.id, v_user_id, 'rental_cancelled');
  return v_rental;
end;
$$;

create or replace function private.complete_return(
  p_rental_id bigint,
  p_distance_km numeric default 0
)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_bike_id bigint;
  v_rental public.rentals%rowtype;
  v_station public.stations%rowtype;
  v_method public.payment_methods%rowtype;
  v_occupied integer;
  v_duration integer;
  v_minutes integer;
  v_fare numeric(10, 2);
  v_release numeric(10, 2);
begin
  if v_user_id is null then
    raise exception using errcode = 'P0001', message = 'not_authenticated';
  end if;
  if p_distance_km is null or p_distance_km < 0 then
    raise exception using errcode = 'P0001', message = 'invalid_distance';
  end if;

  select rental.bike_id into v_bike_id
  from public.rentals as rental
  where rental.id = p_rental_id;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_bike_id
  for update;

  select rental.*
  into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id
  for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if v_rental.status <> 'returning' or v_rental.end_station_id is null then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;

  select station.*
  into v_station
  from public.stations as station
  where station.id = v_rental.end_station_id
  for update;

  if v_station.id is null or not v_station.is_active then
    raise exception using errcode = 'P0001', message = 'station_unavailable';
  end if;

  select count(*)::integer
  into v_occupied
  from public.bikes as bike
  where bike.current_station_id = v_station.id and bike.status <> 'retired';

  if v_occupied >= v_station.capacity then
    raise exception using errcode = 'P0001', message = 'station_full';
  end if;

  v_duration := greatest(
    1,
    floor(extract(epoch from (now() - v_rental.started_at)))::integer
  );
  v_minutes := greatest(1, ceil(v_duration / 60.0)::integer);
  v_fare := round(v_rental.unlock_fee + (v_minutes * v_rental.per_minute_rate), 2);
  v_release := greatest(round(v_rental.hold_amount - v_fare, 2), 0);

  update public.bikes
  set status = 'available', current_station_id = v_station.id
  where id = v_rental.bike_id and status = 'in_use';

  if not found then
    raise exception using errcode = 'P0001', message = 'bike_unavailable';
  end if;

  if not v_rental.payment_required then
    update public.rentals
    set status = 'completed',
        ended_at = now(),
        duration_seconds = v_duration,
        distance_km = p_distance_km,
        charged_minutes = v_minutes,
        final_fare = v_fare,
        failure_reason = null
    where id = v_rental.id
    returning * into v_rental;
  else
    select method.*
    into v_method
    from public.payment_methods as method
    where method.id = v_rental.payment_method_id;

    if v_method.id is null then
      raise exception using errcode = 'P0001', message = 'payment_method_not_found';
    end if;

    update public.rentals
    set status = 'payment_pending',
        ended_at = now(),
        duration_seconds = v_duration,
        distance_km = p_distance_km,
        charged_minutes = v_minutes,
        final_fare = v_fare,
        failure_reason = null
    where id = v_rental.id
    returning * into v_rental;

    insert into public.rental_payments (
      rental_id, user_id, kind, status, amount, currency, provider
    )
    values (
      v_rental.id, v_user_id, 'capture', 'pending', v_fare,
      v_rental.currency, v_method.provider
    );

    if v_release > 0 then
      insert into public.rental_payments (
        rental_id, user_id, kind, status, amount, currency, provider
      )
      values (
        v_rental.id, v_user_id, 'release', 'pending', v_release,
        v_rental.currency, v_method.provider
      );
    end if;
  end if;

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'bike_returned',
    jsonb_build_object(
      'station_id', v_station.id,
      'duration_seconds', v_duration,
      'charged_minutes', v_minutes,
      'final_fare', v_fare,
      'payment_required', v_rental.payment_required
    )
  );
  return v_rental;
end;
$$;

create or replace function public.reserve_rental_session(p_qr_token uuid)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.reserve_rental_session(p_qr_token);
$$;

revoke execute on function private.reserve_rental_session(uuid)
from public, anon;
grant execute on function private.reserve_rental_session(uuid)
to authenticated;

revoke execute on function public.reserve_rental_session(uuid)
from public, anon;
grant execute on function public.reserve_rental_session(uuid)
to authenticated;

-- Test-only fixtures used by the current camera placeholder. Real station and
-- bike provisioning belongs to the future fleet-management integration.
insert into public.stations (
  code,
  name,
  address,
  latitude,
  longitude,
  capacity
)
values
  ('central', 'Central Station', 'Central Station', 3.139000, 101.686900, 12),
  ('riverside', 'Riverside Park', 'Riverside Park', 3.147800, 101.695300, 10),
  ('market', 'Market Square', 'Market Square', 3.145100, 101.695800, 8),
  ('university', 'University Gate', 'University Gate', 3.120900, 101.654400, 10)
on conflict (code) do nothing;

insert into public.bikes (
  code,
  qr_token,
  current_station_id,
  battery_percent,
  status
)
select
  fixture.code,
  fixture.qr_token,
  station.id,
  fixture.battery_percent,
  'available'
from (
  values
    ('BIKE-C042', '00000000-0000-4000-8000-000000000042'::uuid, 'central', 86)
) as fixture(code, qr_token, station_code, battery_percent)
join public.stations as station on station.code = fixture.station_code
on conflict (code) do nothing;
