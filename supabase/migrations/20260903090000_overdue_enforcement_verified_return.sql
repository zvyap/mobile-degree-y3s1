-- Overdue enforcement ladder for never-returned bikes, plus verified return
-- (station QR token + GPS proximity). Overdue is derived: an overdue ride keeps
-- status 'active' with overdue_at set so the rider can still return. 'lost' is
-- the terminal state that suspends the rider account.

alter table public.rental_plans
  add column max_ride_minutes integer not null default 240
    constraint rental_plans_max_ride_minutes_check check (max_ride_minutes > 0),
  add column lost_grace_minutes integer not null default 1440
    constraint rental_plans_lost_grace_minutes_check check (lost_grace_minutes > 0);

alter table public.rentals
  add column ride_deadline_at timestamptz,
  add column overdue_at timestamptz,
  add column extensions_used smallint not null default 0
    constraint rentals_extensions_used_check check (extensions_used >= 0);

alter table public.rentals drop constraint rentals_status_check;
alter table public.rentals
  add constraint rentals_status_check check (
    status in (
      'reserved',
      'pending_authorization',
      'authorized',
      'active',
      'returning',
      'payment_pending',
      'payment_failed',
      'completed',
      'cancelled',
      'lost'
    )
  );

alter table public.bikes drop constraint bikes_status_check;
alter table public.bikes
  add constraint bikes_status_check check (
    status in ('available', 'reserved', 'in_use', 'maintenance', 'retired', 'lost')
  );

alter table public.stations
  add column qr_token uuid not null default gen_random_uuid()
    constraint stations_qr_token_key unique;

drop view public.station_availability;
create view public.station_availability
with (security_invoker = true)
as
select
  station.id,
  station.code,
  station.name,
  station.address,
  station.latitude,
  station.longitude,
  station.capacity,
  station.qr_token,
  count(bike.id) filter (where bike.status = 'available')::integer
    as available_bikes,
  greatest(
    station.capacity - count(bike.id) filter (where bike.status <> 'retired'),
    0
  )::integer as available_docks,
  station.is_active,
  station.updated_at
from public.stations as station
left join public.bikes as bike
  on bike.current_station_id = station.id
group by station.id;

revoke all on public.station_availability from public, anon, authenticated;
grant select on public.station_availability to authenticated;

create function private.haversine_meters(
  p_lat1 double precision,
  p_lon1 double precision,
  p_lat2 double precision,
  p_lon2 double precision
)
returns double precision
language sql
immutable
as $$
  select 6371000.0 * 2 * asin(
    sqrt(
      power(sin(radians(p_lat2 - p_lat1) / 2), 2)
      + cos(radians(p_lat1)) * cos(radians(p_lat2))
        * power(sin(radians(p_lon2 - p_lon1) / 2), 2)
    )
  );
$$;

create function private.return_geofence_radius_m()
returns integer
language sql
stable
as $$
  select 250;
$$;

-- The by-code return path predates verified return and cannot prove station
-- presence; it is superseded by the token + GPS request_return signature.
drop function public.request_return_by_code(bigint, text);
drop function private.request_return_by_code(bigint, text);
drop function public.request_return(bigint, bigint);
drop function private.request_return(bigint, bigint);

create function private.request_return(
  p_rental_id bigint,
  p_station_id bigint,
  p_latitude double precision,
  p_longitude double precision,
  p_station_qr_token uuid
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
  v_occupied integer;
begin
  if v_user_id is null then
    raise exception using errcode = 'P0001', message = 'not_authenticated';
  end if;

  select rental.bike_id into v_bike_id
  from public.rentals as rental where rental.id = p_rental_id;
  perform bike.id from public.bikes as bike
  where bike.id = v_bike_id for update;
  select rental.* into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id for update;
  select station.* into v_station
  from public.stations as station
  where station.id = p_station_id for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if v_rental.status <> 'active' then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;
  if v_station.id is null or not v_station.is_active then
    raise exception using errcode = 'P0001', message = 'station_unavailable';
  end if;
  if p_station_qr_token is null
    or v_station.qr_token is null
    or p_station_qr_token <> v_station.qr_token then
    raise exception using errcode = 'P0001', message = 'station_qr_mismatch';
  end if;
  if p_latitude is null or p_longitude is null
    or private.haversine_meters(
      p_latitude,
      p_longitude,
      v_station.latitude,
      v_station.longitude
    ) > private.return_geofence_radius_m() then
    raise exception using errcode = 'P0001', message = 'outside_return_zone';
  end if;

  select count(*)::integer into v_occupied
  from public.bikes as bike
  where bike.current_station_id = v_station.id and bike.status <> 'retired';

  if v_occupied >= v_station.capacity then
    raise exception using errcode = 'P0001', message = 'station_full';
  end if;

  update public.rentals
  set status = 'returning',
      end_station_id = v_station.id,
      return_requested_at = now()
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'return_requested',
    jsonb_build_object('station_id', v_station.id)
  );
  return v_rental;
end;
$$;

create function public.request_return(
  p_rental_id bigint,
  p_station_id bigint,
  p_latitude double precision,
  p_longitude double precision,
  p_station_qr_token uuid
)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.request_return(
    p_rental_id,
    p_station_id,
    p_latitude,
    p_longitude,
    p_station_qr_token
  );
$$;

-- Marks deadline-exceeded rides overdue, sends the one-time final warning, and
-- converts expired overdue rides to 'lost' (bike lost, rider suspended). Each
-- step is idempotent under row locks so any caller can drive the sweep.
create function private.enforce_rental_deadlines()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_candidate record;
  v_bike_id bigint;
  v_user_id uuid;
  v_deadline timestamptz;
  v_rental public.rentals%rowtype;
  v_grace_minutes integer;
  v_duration integer;
  v_minutes integer;
  v_fare numeric(10, 2);
begin
  for v_candidate in
    select rental.id
    from public.rentals as rental
    where rental.status = 'active'
      and rental.ride_deadline_at is not null
      and rental.ride_deadline_at <= now()
      and rental.overdue_at is null
    order by rental.id
  loop
    select rental.bike_id into v_bike_id
    from public.rentals as rental where rental.id = v_candidate.id;
    perform bike.id from public.bikes as bike
    where bike.id = v_bike_id for update;

    update public.rentals
    set overdue_at = now()
    where id = v_candidate.id
      and status = 'active'
      and overdue_at is null
    returning user_id, ride_deadline_at into v_user_id, v_deadline;

    if found then
      perform private.add_rental_event(
        v_candidate.id,
        v_user_id,
        'rental_overdue',
        jsonb_build_object('ride_deadline_at', v_deadline)
      );
    end if;
  end loop;

  for v_candidate in
    select rental.id
    from public.rentals as rental
    join public.rental_plans as plan on plan.id = rental.rental_plan_id
    where rental.status = 'active'
      and rental.overdue_at is not null
      and now() >= rental.overdue_at
        + make_interval(mins => plan.lost_grace_minutes / 2)
      and not exists (
        select 1 from public.rental_events as event
        where event.rental_id = rental.id
          and event.event_type = 'rental_overdue_final'
      )
    order by rental.id
  loop
    select rental.* into v_rental
    from public.rentals as rental
    where rental.id = v_candidate.id for update;

    continue when v_rental.status <> 'active' or v_rental.overdue_at is null;

    if exists (
      select 1 from public.rental_events as event
      where event.rental_id = v_rental.id
        and event.event_type = 'rental_overdue_final'
    ) then
      continue;
    end if;

    perform private.add_rental_event(
      v_rental.id,
      v_rental.user_id,
      'rental_overdue_final',
      jsonb_build_object(
        'overdue_at', v_rental.overdue_at,
        'account_suspends_at', v_rental.overdue_at + coalesce(
          (
            select make_interval(mins => plan.lost_grace_minutes)
            from public.rental_plans as plan
            where plan.id = v_rental.rental_plan_id
          ),
          make_interval(mins => 1440)
        )
      )
    );
  end loop;

  for v_candidate in
    select rental.id
    from public.rentals as rental
    join public.rental_plans as plan on plan.id = rental.rental_plan_id
    where rental.status = 'active'
      and rental.overdue_at is not null
      and now() >= rental.overdue_at
        + make_interval(mins => plan.lost_grace_minutes)
    order by rental.id
  loop
    select rental.bike_id into v_bike_id
    from public.rentals as rental where rental.id = v_candidate.id;
    perform bike.id from public.bikes as bike
    where bike.id = v_bike_id for update;
    select rental.* into v_rental
    from public.rentals as rental
    where rental.id = v_candidate.id for update;

    select plan.lost_grace_minutes into v_grace_minutes
    from public.rental_plans as plan
    where plan.id = v_rental.rental_plan_id;

    continue when v_rental.status <> 'active'
      or v_rental.overdue_at is null
      or v_rental.started_at is null
      or v_grace_minutes is null
      or now() < v_rental.overdue_at + make_interval(mins => v_grace_minutes);

    v_duration := greatest(
      1,
      floor(extract(epoch from (now() - v_rental.started_at)))::integer
    );
    v_minutes := greatest(1, ceil(v_duration / 60.0)::integer);
    v_fare := round(v_rental.unlock_fee + (v_minutes * v_rental.per_minute_rate), 2);

    update public.bikes
    set status = 'lost'
    where id = v_rental.bike_id and status = 'in_use';

    update public.rentals
    set status = 'lost',
        ended_at = now(),
        duration_seconds = v_duration,
        charged_minutes = v_minutes,
        final_fare = v_fare,
        failure_reason = 'bike_not_returned'
    where id = v_rental.id;

    update public.profiles
    set account_status = 'suspended'
    where id = v_rental.user_id and account_status = 'active';

    perform private.add_rental_event(
      v_rental.id,
      v_rental.user_id,
      'rental_marked_lost',
      jsonb_build_object(
        'bike_id', v_rental.bike_id,
        'duration_seconds', v_duration,
        'charged_minutes', v_minutes,
        'final_fare', v_fare
      )
    );
  end loop;
end;
$$;

create function public.sweep_rental_deadlines()
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.enforce_rental_deadlines();
$$;

create function private.extend_rental(p_rental_id bigint)
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
  from public.rentals as rental where rental.id = p_rental_id;
  perform bike.id from public.bikes as bike
  where bike.id = v_bike_id for update;
  select rental.* into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if v_rental.status <> 'active' or v_rental.ride_deadline_at is null then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;
  if v_rental.extensions_used >= 2 then
    raise exception using errcode = 'P0001', message = 'max_extensions_reached';
  end if;

  update public.rentals
  set ride_deadline_at =
        greatest(v_rental.ride_deadline_at, now()) + interval '60 minutes',
      extensions_used = v_rental.extensions_used + 1
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'rental_extended',
    jsonb_build_object(
      'extensions_used', v_rental.extensions_used,
      'ride_deadline_at', v_rental.ride_deadline_at
    )
  );
  return v_rental;
end;
$$;

create function public.extend_rental(p_rental_id bigint)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.extend_rental(p_rental_id);
$$;

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

  perform private.enforce_rental_deadlines();

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
    0,
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
  v_max_ride_minutes integer;
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

  select rental.* into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id for update;

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

  select plan.max_ride_minutes into v_max_ride_minutes
  from public.rental_plans as plan
  where plan.id = v_rental.rental_plan_id;

  update public.bikes
  set status = 'in_use', current_station_id = null
  where id = v_rental.bike_id and status = 'reserved';

  if not found then
    raise exception using errcode = 'P0001', message = 'bike_unavailable';
  end if;

  update public.rentals
  set status = 'active',
      started_at = now(),
      reservation_expires_at = null,
      ride_deadline_at = now()
        + make_interval(mins => coalesce(v_max_ride_minutes, 240)),
      overdue_at = null,
      extensions_used = 0
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(v_rental.id, v_user_id, 'rental_started');
  return v_rental;
end;
$$;

revoke execute on function private.haversine_meters(
  double precision, double precision, double precision, double precision
) from public, anon, authenticated, service_role;
revoke execute on function private.return_geofence_radius_m()
from public, anon, authenticated, service_role;

revoke execute on function private.request_return(
  bigint, bigint, double precision, double precision, uuid
) from public, anon;
grant execute on function private.request_return(
  bigint, bigint, double precision, double precision, uuid
) to authenticated;
revoke execute on function public.request_return(
  bigint, bigint, double precision, double precision, uuid
) from public, anon;
grant execute on function public.request_return(
  bigint, bigint, double precision, double precision, uuid
) to authenticated;

revoke execute on function private.enforce_rental_deadlines()
from public, anon;
grant execute on function private.enforce_rental_deadlines() to authenticated;
revoke execute on function public.sweep_rental_deadlines() from public, anon;
grant execute on function public.sweep_rental_deadlines() to authenticated;

revoke execute on function private.extend_rental(bigint) from public, anon;
grant execute on function private.extend_rental(bigint) to authenticated;
revoke execute on function public.extend_rental(bigint) from public, anon;
grant execute on function public.extend_rental(bigint) to authenticated;
