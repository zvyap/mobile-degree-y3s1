-- Migration to order existing rentals descending in reserve_rental_session
-- Ensures that the most recent active/blocking rental is evaluated first.

create or replace function private.reserve_rental_session(p_qr_token uuid)
returns public.rentals
language plpgsql
security definer
set search_path = public, pg_temp
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
  order by rental.id desc
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
      and v_existing.bike_id = v_candidate_id then
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
    else
      raise exception using errcode = 'P0001', message = 'bike_reserved';
    end if;
  end if;

  if v_bike.battery_percent < 10 then
    raise exception using errcode = 'P0001', message = 'bike_low_battery';
  end if;

  if v_bike.status = 'maintenance' then
    raise exception using errcode = 'P0001', message = 'bike_maintenance';
  end if;

  if v_bike.status = 'in_use' then
    raise exception using errcode = 'P0001', message = 'bike_in_use';
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
    start_station_id,
    status,
    currency,
    unlock_fee,
    per_minute_rate,
    hold_amount,
    reservation_expires_at,
    payment_required
  ) values (
    v_user_id,
    v_bike.id,
    v_plan.id,
    v_bike.current_station_id,
    'reserved',
    v_plan.currency,
    v_plan.unlock_fee,
    v_plan.per_minute_rate,
    v_plan.hold_amount,
    now() + interval '15 minutes',
    false
  )
  returning * into v_rental;

  update public.bikes
  set status = 'reserved'
  where id = v_bike.id;

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'reserved'
  );

  return v_rental;
end;
$$;
