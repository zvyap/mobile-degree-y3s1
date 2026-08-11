create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated, service_role;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  phone text,
  avatar_url text,
  role text not null default 'rider'
    constraint profiles_role_check check (role in ('rider', 'admin')),
  account_status text not null default 'active'
    constraint profiles_account_status_check
    check (account_status in ('active', 'suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.stations (
  id bigint generated always as identity primary key,
  code text not null unique,
  name text not null,
  address text not null,
  latitude double precision not null
    constraint stations_latitude_check check (latitude between -90 and 90),
  longitude double precision not null
    constraint stations_longitude_check check (longitude between -180 and 180),
  capacity smallint not null
    constraint stations_capacity_check check (capacity > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.bikes (
  id bigint generated always as identity primary key,
  code text not null unique,
  qr_token uuid not null default gen_random_uuid() unique,
  current_station_id bigint references public.stations (id) on delete restrict,
  battery_percent smallint not null default 100
    constraint bikes_battery_percent_check check (battery_percent between 0 and 100),
  status text not null default 'available'
    constraint bikes_status_check
    check (status in ('available', 'reserved', 'in_use', 'maintenance', 'retired')),
  last_service_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bikes_available_station_check check (
    status not in ('available', 'reserved') or current_station_id is not null
  ),
  constraint bikes_in_use_station_check check (
    status <> 'in_use' or current_station_id is null
  )
);

create table public.rental_plans (
  id bigint generated always as identity primary key,
  code text not null unique,
  currency text not null
    constraint rental_plans_currency_check check (currency ~ '^[A-Z]{3}$'),
  unlock_fee numeric(10, 2) not null
    constraint rental_plans_unlock_fee_check check (unlock_fee >= 0),
  per_minute_rate numeric(10, 2) not null
    constraint rental_plans_per_minute_rate_check check (per_minute_rate >= 0),
  hold_amount numeric(10, 2) not null
    constraint rental_plans_hold_amount_check check (hold_amount >= 0),
  is_active boolean not null default false,
  valid_from timestamptz not null default now(),
  valid_until timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rental_plans_valid_window_check
    check (valid_until is null or valid_until > valid_from)
);

create table public.payment_methods (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  provider text not null,
  provider_token text not null,
  brand text not null,
  last_four text not null
    constraint payment_methods_last_four_check check (last_four ~ '^[0-9]{4}$'),
  expiry_month smallint
    constraint payment_methods_expiry_month_check check (expiry_month between 1 and 12),
  expiry_year smallint
    constraint payment_methods_expiry_year_check check (expiry_year >= 2000),
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payment_methods_provider_token_unique unique (provider, provider_token)
);

create table public.rentals (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  user_id uuid references auth.users (id) on delete set null,
  bike_id bigint not null references public.bikes (id) on delete restrict,
  rental_plan_id bigint not null references public.rental_plans (id) on delete restrict,
  payment_method_id bigint references public.payment_methods (id) on delete set null,
  start_station_id bigint not null references public.stations (id) on delete restrict,
  end_station_id bigint references public.stations (id) on delete restrict,
  status text not null default 'pending_authorization'
    constraint rentals_status_check check (
      status in (
        'pending_authorization',
        'authorized',
        'active',
        'returning',
        'payment_pending',
        'payment_failed',
        'completed',
        'cancelled'
      )
    ),
  currency text not null
    constraint rentals_currency_check check (currency ~ '^[A-Z]{3}$'),
  unlock_fee numeric(10, 2) not null
    constraint rentals_unlock_fee_check check (unlock_fee >= 0),
  per_minute_rate numeric(10, 2) not null
    constraint rentals_per_minute_rate_check check (per_minute_rate >= 0),
  hold_amount numeric(10, 2) not null
    constraint rentals_hold_amount_check check (hold_amount >= 0),
  reservation_expires_at timestamptz,
  authorized_at timestamptz,
  started_at timestamptz,
  return_requested_at timestamptz,
  ended_at timestamptz,
  cancelled_at timestamptz,
  duration_seconds integer not null default 0
    constraint rentals_duration_seconds_check check (duration_seconds >= 0),
  distance_km numeric(10, 3) not null default 0
    constraint rentals_distance_km_check check (distance_km >= 0),
  charged_minutes integer not null default 0
    constraint rentals_charged_minutes_check check (charged_minutes >= 0),
  final_fare numeric(10, 2)
    constraint rentals_final_fare_check check (final_fare is null or final_fare >= 0),
  failure_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rentals_time_order_check check (
    (started_at is null or started_at >= created_at)
    and (ended_at is null or started_at is not null)
    and (ended_at is null or ended_at >= started_at)
  )
);

create table public.rental_payments (
  id bigint generated always as identity primary key,
  rental_id bigint not null references public.rentals (id) on delete restrict,
  user_id uuid references auth.users (id) on delete set null,
  kind text not null
    constraint rental_payments_kind_check
    check (kind in ('authorization', 'capture', 'release', 'refund')),
  status text not null default 'pending'
    constraint rental_payments_status_check
    check (status in ('pending', 'succeeded', 'failed', 'cancelled')),
  amount numeric(10, 2) not null
    constraint rental_payments_amount_check check (amount >= 0),
  currency text not null
    constraint rental_payments_currency_check check (currency ~ '^[A-Z]{3}$'),
  provider text not null,
  provider_reference text,
  failure_code text,
  failure_message text,
  processed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.rental_events (
  id bigint generated always as identity primary key,
  rental_id bigint not null references public.rentals (id) on delete restrict,
  user_id uuid references auth.users (id) on delete set null,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb
    constraint rental_events_payload_object_check
    check (jsonb_typeof(payload) = 'object'),
  created_at timestamptz not null default now()
);

create unique index rental_plans_one_active_idx
  on public.rental_plans (is_active)
  where is_active;
create unique index payment_methods_one_default_per_user_idx
  on public.payment_methods (user_id)
  where is_default;
create unique index rentals_one_blocking_per_user_idx
  on public.rentals (user_id)
  where user_id is not null
    and status in (
      'pending_authorization', 'authorized', 'active', 'returning',
      'payment_pending', 'payment_failed'
    );
create unique index rentals_one_engaged_per_bike_idx
  on public.rentals (bike_id)
  where status in ('pending_authorization', 'authorized', 'active', 'returning');
create unique index rental_payments_one_pending_kind_idx
  on public.rental_payments (rental_id, kind)
  where status = 'pending';

create index bikes_current_station_status_idx
  on public.bikes (current_station_id, status);
create index rentals_user_created_at_idx
  on public.rentals (user_id, created_at desc);
create index rentals_bike_id_idx on public.rentals (bike_id);
create index rentals_rental_plan_id_idx on public.rentals (rental_plan_id);
create index rentals_payment_method_id_idx on public.rentals (payment_method_id);
create index rentals_start_station_id_idx on public.rentals (start_station_id);
create index rentals_end_station_id_idx on public.rentals (end_station_id);
create index payment_methods_user_id_idx on public.payment_methods (user_id);
create index rental_payments_rental_created_at_idx
  on public.rental_payments (rental_id, created_at);
create index rental_payments_user_id_idx on public.rental_payments (user_id);
create index rental_events_rental_created_at_idx
  on public.rental_events (rental_id, created_at);
create index rental_events_user_id_idx on public.rental_events (user_id);

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

create function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();
create trigger stations_set_updated_at
before update on public.stations
for each row execute function public.set_updated_at();
create trigger bikes_set_updated_at
before update on public.bikes
for each row execute function public.set_updated_at();
create trigger rental_plans_set_updated_at
before update on public.rental_plans
for each row execute function public.set_updated_at();
create trigger payment_methods_set_updated_at
before update on public.payment_methods
for each row execute function public.set_updated_at();
create trigger rentals_set_updated_at
before update on public.rentals
for each row execute function public.set_updated_at();
create trigger rental_payments_set_updated_at
before update on public.rental_payments
for each row execute function public.set_updated_at();

create function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'display_name', ''),
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      ''
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_user();

insert into public.profiles (id, display_name)
select
  auth_user.id,
  coalesce(
    nullif(auth_user.raw_user_meta_data ->> 'display_name', ''),
    nullif(auth_user.raw_user_meta_data ->> 'full_name', ''),
    ''
  )
from auth.users as auth_user
on conflict (id) do nothing;

insert into public.rental_plans (
  code,
  currency,
  unlock_fee,
  per_minute_rate,
  hold_amount,
  is_active
)
values ('standard-my', 'MYR', 0.50, 0.10, 20.00, true);

create function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (
      select profile.role = 'admin' and profile.account_status = 'active'
      from public.profiles as profile
      where profile.id = (select auth.uid())
    ),
    false
  );
$$;

create function private.add_rental_event(
  p_rental_id bigint,
  p_user_id uuid,
  p_event_type text,
  p_payload jsonb default '{}'::jsonb
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.rental_events (rental_id, user_id, event_type, payload)
  values (p_rental_id, p_user_id, p_event_type, coalesce(p_payload, '{}'::jsonb));
$$;

create function private.reserve_bike(
  p_qr_token uuid,
  p_payment_method_id bigint
)
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
  v_method public.payment_methods%rowtype;
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
      'pending_authorization', 'authorized', 'active', 'returning',
      'payment_pending', 'payment_failed'
    )
  order by rental.id
  limit 1;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_candidate_id
     or bike.id = v_existing.bike_id
  order by bike.id
  for update;

  if v_existing.id is not null then
    select rental.*
    into v_existing
    from public.rentals as rental
    where rental.id = v_existing.id
    for update;

    if v_existing.status = 'pending_authorization'
      and v_existing.reservation_expires_at <= now() then
      update public.rentals
      set status = 'cancelled',
          cancelled_at = now(),
          failure_reason = 'reservation_expired'
      where id = v_existing.id;

      update public.rental_payments
      set status = 'cancelled', processed_at = now()
      where rental_id = v_existing.id
        and kind = 'authorization'
        and status = 'pending';

      update public.bikes
      set status = 'available', current_station_id = v_existing.start_station_id
      where id = v_existing.bike_id;

      perform private.add_rental_event(
        v_existing.id,
        v_user_id,
        'reservation_expired'
      );
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
      and rental.status = 'pending_authorization'
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
      where rental_id = v_candidate_rental.id
        and kind = 'authorization'
        and status = 'pending';

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

  select method.*
  into v_method
  from public.payment_methods as method
  where method.id = p_payment_method_id and method.user_id = v_user_id;

  if v_method.id is null then
    raise exception using errcode = 'P0001', message = 'payment_method_not_found';
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
    v_method.id,
    v_bike.current_station_id,
    'pending_authorization',
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

  insert into public.rental_payments (
    rental_id,
    user_id,
    kind,
    status,
    amount,
    currency,
    provider
  )
  values (
    v_rental.id,
    v_user_id,
    'authorization',
    'pending',
    v_rental.hold_amount,
    v_rental.currency,
    v_method.provider
  );

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'bike_reserved',
    jsonb_build_object(
      'bike_id', v_bike.id,
      'reservation_expires_at', v_rental.reservation_expires_at
    )
  );

  return v_rental;
end;
$$;

create function private.record_authorization_result(
  p_payment_id bigint,
  p_succeeded boolean,
  p_provider_reference text default null,
  p_failure_code text default null,
  p_failure_message text default null
)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_payment public.rental_payments%rowtype;
  v_rental public.rentals%rowtype;
begin
  select payment.*
  into v_payment
  from public.rental_payments as payment
  where payment.id = p_payment_id and payment.kind = 'authorization';

  if v_payment.id is null then
    raise exception using errcode = 'P0001', message = 'payment_not_found';
  end if;

  select rental.*
  into v_rental
  from public.rentals as rental
  where rental.id = v_payment.rental_id;

  perform bike.id
  from public.bikes as bike
  where bike.id = v_rental.bike_id
  for update;

  select rental.*
  into v_rental
  from public.rentals as rental
  where rental.id = v_payment.rental_id
  for update;

  select payment.*
  into v_payment
  from public.rental_payments as payment
  where payment.id = p_payment_id
  for update;

  if v_payment.status <> 'pending'
    or v_rental.status <> 'pending_authorization' then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;

  if p_succeeded then
    update public.rental_payments
    set status = 'succeeded',
        provider_reference = p_provider_reference,
        processed_at = now(),
        failure_code = null,
        failure_message = null
    where id = v_payment.id;

    update public.rentals
    set status = 'authorized', authorized_at = now(), failure_reason = null
    where id = v_rental.id
    returning * into v_rental;

    perform private.add_rental_event(
      v_rental.id,
      v_rental.user_id,
      'authorization_succeeded'
    );
  else
    update public.rental_payments
    set status = 'failed',
        provider_reference = p_provider_reference,
        processed_at = now(),
        failure_code = p_failure_code,
        failure_message = p_failure_message
    where id = v_payment.id;

    update public.rentals
    set status = 'cancelled',
        cancelled_at = now(),
        failure_reason = coalesce(p_failure_code, 'authorization_failed')
    where id = v_rental.id
    returning * into v_rental;

    update public.bikes
    set status = 'available', current_station_id = v_rental.start_station_id
    where id = v_rental.bike_id;

    perform private.add_rental_event(
      v_rental.id,
      v_rental.user_id,
      'authorization_failed',
      jsonb_build_object('failure_code', p_failure_code)
    );
  end if;

  return v_rental;
end;
$$;

create function private.start_rental(p_rental_id bigint)
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

  perform bike.id from public.bikes as bike
  where bike.id = v_bike_id for update;

  select rental.* into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if v_rental.status <> 'authorized' then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;
  if not exists (
    select 1 from public.rental_payments as payment
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

create function private.cancel_rental(p_rental_id bigint)
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
  if v_rental.status not in ('pending_authorization', 'authorized') then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;

  update public.rental_payments
  set status = 'cancelled', processed_at = now()
  where rental_id = v_rental.id and status = 'pending';

  if exists (
    select 1 from public.rental_payments as payment
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

create function private.request_return(
  p_rental_id bigint,
  p_station_id bigint
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

create function private.resume_rental(p_rental_id bigint)
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
  if v_rental.status <> 'returning' then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;

  update public.rentals
  set status = 'active', end_station_id = null, return_requested_at = null
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(v_rental.id, v_user_id, 'rental_resumed');
  return v_rental;
end;
$$;

create function private.complete_return(
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
  from public.rentals as rental where rental.id = p_rental_id;
  perform bike.id from public.bikes as bike
  where bike.id = v_bike_id for update;
  select rental.* into v_rental
  from public.rentals as rental
  where rental.id = p_rental_id for update;

  if v_rental.id is null or v_rental.user_id <> v_user_id then
    raise exception using errcode = 'P0001', message = 'rental_not_found';
  end if;
  if v_rental.status <> 'returning' or v_rental.end_station_id is null then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;

  select station.* into v_station
  from public.stations as station
  where station.id = v_rental.end_station_id for update;

  if v_station.id is null or not v_station.is_active then
    raise exception using errcode = 'P0001', message = 'station_unavailable';
  end if;

  select count(*)::integer into v_occupied
  from public.bikes as bike
  where bike.current_station_id = v_station.id and bike.status <> 'retired';

  if v_occupied >= v_station.capacity then
    raise exception using errcode = 'P0001', message = 'station_full';
  end if;

  select method.* into v_method
  from public.payment_methods as method
  where method.id = v_rental.payment_method_id;

  if v_method.id is null then
    raise exception using errcode = 'P0001', message = 'payment_method_not_found';
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

  perform private.add_rental_event(
    v_rental.id,
    v_user_id,
    'bike_returned',
    jsonb_build_object(
      'station_id', v_station.id,
      'duration_seconds', v_duration,
      'charged_minutes', v_minutes,
      'final_fare', v_fare
    )
  );
  return v_rental;
end;
$$;

create function private.request_payment_retry(p_rental_id bigint)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_bike_id bigint;
  v_rental public.rentals%rowtype;
  v_method public.payment_methods%rowtype;
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
  if v_rental.status <> 'payment_failed' or v_rental.final_fare is null then
    raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
  end if;
  if exists (
    select 1 from public.rental_payments as payment
    where payment.rental_id = v_rental.id
      and payment.kind = 'capture'
      and payment.status = 'pending'
  ) then
    raise exception using errcode = 'P0001', message = 'payment_already_pending';
  end if;

  select method.* into v_method
  from public.payment_methods as method
  where method.id = v_rental.payment_method_id;

  insert into public.rental_payments (
    rental_id, user_id, kind, status, amount, currency, provider
  )
  values (
    v_rental.id, v_user_id, 'capture', 'pending', v_rental.final_fare,
    v_rental.currency, v_method.provider
  );

  update public.rentals
  set status = 'payment_pending', failure_reason = null
  where id = v_rental.id
  returning * into v_rental;

  perform private.add_rental_event(v_rental.id, v_user_id, 'payment_retry_requested');
  return v_rental;
end;
$$;

create function private.record_payment_result(
  p_payment_id bigint,
  p_succeeded boolean,
  p_provider_reference text default null,
  p_failure_code text default null,
  p_failure_message text default null
)
returns public.rentals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_payment public.rental_payments%rowtype;
  v_rental public.rentals%rowtype;
begin
  select payment.* into v_payment
  from public.rental_payments as payment
  where payment.id = p_payment_id;
  if v_payment.id is null or v_payment.kind = 'authorization' then
    raise exception using errcode = 'P0001', message = 'payment_not_found';
  end if;

  select rental.* into v_rental
  from public.rentals as rental where rental.id = v_payment.rental_id;
  perform bike.id from public.bikes as bike
  where bike.id = v_rental.bike_id for update;
  select rental.* into v_rental
  from public.rentals as rental
  where rental.id = v_payment.rental_id for update;
  select payment.* into v_payment
  from public.rental_payments as payment
  where payment.id = p_payment_id for update;

  if v_payment.status <> 'pending' then
    raise exception using errcode = 'P0001', message = 'invalid_payment_transition';
  end if;

  update public.rental_payments
  set status = case when p_succeeded then 'succeeded' else 'failed' end,
      provider_reference = p_provider_reference,
      failure_code = case when p_succeeded then null else p_failure_code end,
      failure_message = case when p_succeeded then null else p_failure_message end,
      processed_at = now()
  where id = v_payment.id;

  if v_payment.kind = 'capture' then
    if v_rental.status <> 'payment_pending' then
      raise exception using errcode = 'P0001', message = 'invalid_rental_transition';
    end if;

    update public.rentals
    set status = case when p_succeeded then 'completed' else 'payment_failed' end,
        failure_reason = case
          when p_succeeded then null
          else coalesce(p_failure_code, 'payment_failed')
        end
    where id = v_rental.id
    returning * into v_rental;
  end if;

  perform private.add_rental_event(
    v_rental.id,
    v_rental.user_id,
    case when p_succeeded then 'payment_succeeded' else 'payment_failed' end,
    jsonb_build_object('kind', v_payment.kind, 'failure_code', p_failure_code)
  );
  return v_rental;
end;
$$;

create function public.reserve_bike(
  p_qr_token uuid,
  p_payment_method_id bigint
)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.reserve_bike(p_qr_token, p_payment_method_id);
$$;

create function public.record_authorization_result(
  p_payment_id bigint,
  p_succeeded boolean,
  p_provider_reference text default null,
  p_failure_code text default null,
  p_failure_message text default null
)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.record_authorization_result(
    p_payment_id,
    p_succeeded,
    p_provider_reference,
    p_failure_code,
    p_failure_message
  );
$$;

create function public.start_rental(p_rental_id bigint)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.start_rental(p_rental_id);
$$;

create function public.cancel_rental(p_rental_id bigint)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.cancel_rental(p_rental_id);
$$;

create function public.request_return(p_rental_id bigint, p_station_id bigint)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.request_return(p_rental_id, p_station_id);
$$;

create function public.resume_rental(p_rental_id bigint)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.resume_rental(p_rental_id);
$$;

create function public.complete_return(
  p_rental_id bigint,
  p_distance_km numeric default 0
)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.complete_return(p_rental_id, p_distance_km);
$$;

create function public.request_payment_retry(p_rental_id bigint)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.request_payment_retry(p_rental_id);
$$;

create function public.record_payment_result(
  p_payment_id bigint,
  p_succeeded boolean,
  p_provider_reference text default null,
  p_failure_code text default null,
  p_failure_message text default null
)
returns public.rentals
language sql
security invoker
set search_path = ''
as $$
  select private.record_payment_result(
    p_payment_id,
    p_succeeded,
    p_provider_reference,
    p_failure_code,
    p_failure_message
  );
$$;

alter table public.profiles enable row level security;
alter table public.stations enable row level security;
alter table public.bikes enable row level security;
alter table public.rental_plans enable row level security;
alter table public.payment_methods enable row level security;
alter table public.rentals enable row level security;
alter table public.rental_payments enable row level security;
alter table public.rental_events enable row level security;

create policy profiles_select_own_or_admin
on public.profiles for select
to authenticated
using (id = (select auth.uid()) or (select private.is_admin()));

create policy profiles_update_own
on public.profiles for update
to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

create policy stations_authenticated_select
on public.stations for select
to authenticated
using (true);

create policy stations_admin_insert
on public.stations for insert
to authenticated
with check ((select private.is_admin()));

create policy stations_admin_update
on public.stations for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy bikes_authenticated_select
on public.bikes for select
to authenticated
using (true);

create policy bikes_admin_insert
on public.bikes for insert
to authenticated
with check ((select private.is_admin()));

create policy bikes_admin_update
on public.bikes for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy rental_plans_authenticated_select
on public.rental_plans for select
to authenticated
using (true);

create policy rental_plans_admin_insert
on public.rental_plans for insert
to authenticated
with check ((select private.is_admin()));

create policy rental_plans_admin_update
on public.rental_plans for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy payment_methods_select_own
on public.payment_methods for select
to authenticated
using (user_id = (select auth.uid()));

create policy payment_methods_insert_own
on public.payment_methods for insert
to authenticated
with check (user_id = (select auth.uid()));

create policy payment_methods_update_own
on public.payment_methods for update
to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy payment_methods_delete_own
on public.payment_methods for delete
to authenticated
using (user_id = (select auth.uid()));

create policy rentals_select_own_or_admin
on public.rentals for select
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

create policy rental_payments_select_own_or_admin
on public.rental_payments for select
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

create policy rental_events_select_own_or_admin
on public.rental_events for select
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

revoke all on table
  public.profiles,
  public.stations,
  public.bikes,
  public.rental_plans,
  public.payment_methods,
  public.rentals,
  public.rental_payments,
  public.rental_events,
  public.station_availability
from public, anon, authenticated;

grant select on public.profiles to authenticated;
grant update (display_name, phone, avatar_url) on public.profiles to authenticated;

grant select, insert, update on public.stations to authenticated;
grant select, insert, update on public.bikes to authenticated;
grant select, insert, update on public.rental_plans to authenticated;
grant select on public.station_availability to authenticated;

grant select (
  id, user_id, provider, brand, last_four, expiry_month, expiry_year,
  is_default, created_at, updated_at
) on public.payment_methods to authenticated;
grant insert (
  user_id, provider, provider_token, brand, last_four, expiry_month,
  expiry_year, is_default
) on public.payment_methods to authenticated;
grant update (
  provider_token, brand, last_four, expiry_month, expiry_year, is_default
) on public.payment_methods to authenticated;
grant delete on public.payment_methods to authenticated;

grant select on public.rentals to authenticated;
grant select on public.rental_payments to authenticated;
grant select on public.rental_events to authenticated;

revoke all on sequence
  public.stations_id_seq,
  public.bikes_id_seq,
  public.rental_plans_id_seq,
  public.payment_methods_id_seq,
  public.rentals_id_seq,
  public.rental_payments_id_seq,
  public.rental_events_id_seq
from public, anon, authenticated;
grant usage on sequence
  public.stations_id_seq,
  public.bikes_id_seq,
  public.rental_plans_id_seq,
  public.payment_methods_id_seq
to authenticated;

revoke execute on function public.set_updated_at() from public, anon, authenticated;
revoke execute on function private.handle_new_user() from public, anon, authenticated, service_role;
revoke execute on function private.add_rental_event(bigint, uuid, text, jsonb)
from public, anon, authenticated, service_role;

revoke execute on function private.is_admin() from public, anon;
grant execute on function private.is_admin() to authenticated, service_role;

revoke execute on function private.reserve_bike(uuid, bigint) from public, anon;
revoke execute on function private.start_rental(bigint) from public, anon;
revoke execute on function private.cancel_rental(bigint) from public, anon;
revoke execute on function private.request_return(bigint, bigint) from public, anon;
revoke execute on function private.resume_rental(bigint) from public, anon;
revoke execute on function private.complete_return(bigint, numeric) from public, anon;
revoke execute on function private.request_payment_retry(bigint) from public, anon;
grant execute on function private.reserve_bike(uuid, bigint) to authenticated;
grant execute on function private.start_rental(bigint) to authenticated;
grant execute on function private.cancel_rental(bigint) to authenticated;
grant execute on function private.request_return(bigint, bigint) to authenticated;
grant execute on function private.resume_rental(bigint) to authenticated;
grant execute on function private.complete_return(bigint, numeric) to authenticated;
grant execute on function private.request_payment_retry(bigint) to authenticated;

revoke execute on function private.record_authorization_result(
  bigint, boolean, text, text, text
) from public, anon, authenticated;
revoke execute on function private.record_payment_result(
  bigint, boolean, text, text, text
) from public, anon, authenticated;
grant execute on function private.record_authorization_result(
  bigint, boolean, text, text, text
) to service_role;
grant execute on function private.record_payment_result(
  bigint, boolean, text, text, text
) to service_role;

revoke execute on function public.reserve_bike(uuid, bigint)
from public, anon;
revoke execute on function public.start_rental(bigint)
from public, anon;
revoke execute on function public.cancel_rental(bigint)
from public, anon;
revoke execute on function public.request_return(bigint, bigint)
from public, anon;
revoke execute on function public.resume_rental(bigint)
from public, anon;
revoke execute on function public.complete_return(bigint, numeric)
from public, anon;
revoke execute on function public.request_payment_retry(bigint)
from public, anon;
grant execute on function public.reserve_bike(uuid, bigint) to authenticated;
grant execute on function public.start_rental(bigint) to authenticated;
grant execute on function public.cancel_rental(bigint) to authenticated;
grant execute on function public.request_return(bigint, bigint) to authenticated;
grant execute on function public.resume_rental(bigint) to authenticated;
grant execute on function public.complete_return(bigint, numeric) to authenticated;
grant execute on function public.request_payment_retry(bigint) to authenticated;

revoke execute on function public.record_authorization_result(
  bigint, boolean, text, text, text
) from public, anon, authenticated;
revoke execute on function public.record_payment_result(
  bigint, boolean, text, text, text
) from public, anon, authenticated;
grant execute on function public.record_authorization_result(
  bigint, boolean, text, text, text
) to service_role;
grant execute on function public.record_payment_result(
  bigint, boolean, text, text, text
) to service_role;
