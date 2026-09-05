-- Admin function to force-end an active rental session
create or replace function private.force_end_rental(p_rental_id bigint)
returns public.rentals
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_admin_id uuid := auth.uid();
  v_rental public.rentals%rowtype;
  v_duration integer := 0;
  v_minutes integer := 0;
  v_fare numeric(10, 2) := 0.00;
begin
  if v_admin_id is null then
    raise exception using errcode = 'P0001', message = 'not_authenticated';
  end if;

  if not private.is_admin() then
    raise exception using errcode = 'P0001', message = 'not_authorized';
  end if;

  select rental.*
  into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id
  for update;

  if v_rental.id is null then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;

  if v_rental.status in ('completed', 'cancelled', 'lost') then
    raise exception using errcode = 'P0001', message = 'rental_already_ended';
  end if;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_rental.bike_id
  for update;

  -- Cancel any pending rental payment
  update public.rental_payments
  set status = 'cancelled',
      processed_at = now()
  where rental_id = v_rental.id
    and status = 'pending';

  -- Free the bike back to available at current/end/start station
  update public.bikes
  set status = 'available',
      current_station_id = coalesce(v_rental.end_station_id, v_rental.start_station_id)
  where id = v_rental.bike_id;

  if v_rental.started_at is not null then
    v_duration := greatest(
      1,
      floor(extract(epoch from (now() - v_rental.started_at)))::integer
    );
    v_minutes := greatest(1, ceil(v_duration / 60.0)::integer);
    v_fare := round(v_rental.unlock_fee + (v_minutes * v_rental.per_minute_rate), 2);

    update public.rentals
    set status = 'completed',
        ended_at = now(),
        duration_seconds = v_duration,
        charged_minutes = v_minutes,
        final_fare = v_fare,
        failure_reason = 'force_ended_by_admin'
    where id = v_rental.id
    returning * into v_rental;
  else
    update public.rentals
    set status = 'cancelled',
        cancelled_at = now(),
        duration_seconds = 0,
        charged_minutes = 0,
        final_fare = 0.00,
        failure_reason = 'force_ended_by_admin'
    where id = v_rental.id
    returning * into v_rental;
  end if;

  perform private.add_rental_event(
    v_rental.id,
    v_rental.user_id,
    'admin_force_ended',
    jsonb_build_object(
      'admin_id', v_admin_id,
      'reason', 'force_ended_by_admin',
      'ended_at', now(),
      'duration_seconds', v_duration,
      'final_fare', v_fare
    )
  );

  return v_rental;
end;
$$;

create or replace function public.force_end_rental(p_rental_id bigint)
returns public.rentals
language sql
security invoker
set search_path = public, pg_temp
as $$
  select private.force_end_rental(p_rental_id);
$$;

revoke execute on function private.force_end_rental(bigint) from public, anon;
grant execute on function private.force_end_rental(bigint) to authenticated;
revoke execute on function public.force_end_rental(bigint) from public, anon;
grant execute on function public.force_end_rental(bigint) to authenticated;

-- Add rentals table to realtime publication if not already added
do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'rentals'
  ) then
    alter publication supabase_realtime add table public.rentals;
  end if;
end;
$$;
