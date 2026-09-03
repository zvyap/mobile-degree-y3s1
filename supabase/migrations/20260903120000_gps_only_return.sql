-- Migration: 20260903120000_gps_only_return.sql
-- Enables GPS-only return by making p_station_qr_token optional in request_return.

create or replace function private.request_return(
  p_rental_id bigint,
  p_station_id bigint,
  p_latitude double precision,
  p_longitude double precision,
  p_station_qr_token uuid default null
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

  -- If QR token is explicitly provided AND station has a QR token, check it;
  -- otherwise, GPS geofence check is the primary return verification mechanism.
  if p_station_qr_token is not null and v_station.qr_token is not null
    and p_station_qr_token <> v_station.qr_token then
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

create or replace function public.request_return(
  p_rental_id bigint,
  p_station_id bigint,
  p_latitude double precision,
  p_longitude double precision,
  p_station_qr_token uuid default null
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
