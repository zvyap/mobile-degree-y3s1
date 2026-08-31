begin;

select plan(29);

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'stations', 'stations table exists');
select has_table('public', 'bikes', 'bikes table exists');
select has_table('public', 'rental_plans', 'rental plans table exists');
select has_table('public', 'payment_methods', 'payment methods table exists');
select has_table('public', 'rentals', 'rentals table exists');
select has_table('public', 'rental_payments', 'rental payments table exists');
select has_table('public', 'rental_events', 'rental events table exists');
select has_view('public', 'station_availability', 'availability view exists');

select ok(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  'profiles has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.stations'::regclass),
  'stations has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.bikes'::regclass),
  'bikes has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.rental_plans'::regclass),
  'rental plans has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.payment_methods'::regclass),
  'payment methods has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.rentals'::regclass),
  'rentals has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.rental_payments'::regclass),
  'rental payments has RLS'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.rental_events'::regclass),
  'rental events has RLS'
);

select has_index(
  'public',
  'rentals',
  'rentals_one_blocking_per_user_idx',
  'one blocking rental per rider is enforced'
);
select has_index(
  'public',
  'rentals',
  'rentals_one_engaged_per_bike_idx',
  'one engaged rental per bike is enforced'
);
select has_index(
  'public',
  'payment_methods',
  'payment_methods_one_default_per_user_idx',
  'one default payment method is enforced'
);

insert into auth.users (id, email, raw_user_meta_data)
values
  (
    '10000000-0000-4000-8000-000000000001',
    'rider-one@example.test',
    '{"display_name":"Rider One"}'::jsonb
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    'rider-two@example.test',
    '{"display_name":"Rider Two"}'::jsonb
  );

select is(
  (
    select display_name
    from public.profiles
    where id = '10000000-0000-4000-8000-000000000001'
  ),
  'Rider One',
  'auth trigger creates a profile'
);

insert into public.stations (
  code, name, address, latitude, longitude, capacity
)
values
  ('test-origin', 'Test Origin', 'Origin', 3.1, 101.6, 2),
  ('test-return', 'Test Return', 'Return', 3.2, 101.7, 2);

insert into public.bikes (
  code, qr_token, current_station_id, battery_percent, status
)
select
  'BIKE-TEST-1',
  '30000000-0000-4000-8000-000000000003'::uuid,
  station.id,
  90,
  'available'
from public.stations as station
where station.code = 'test-origin';

insert into public.payment_methods (
  user_id, provider, provider_token, brand, last_four, is_default
)
values (
  '10000000-0000-4000-8000-000000000001',
  'test-provider',
  'test-token-one',
  'Visa',
  '4242',
  true
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select lives_ok(
  $$
    select public.reserve_bike(
      '30000000-0000-4000-8000-000000000003'::uuid,
      (select id from public.payment_methods where is_default)
    )
  $$,
  'rider can reserve an available bike'
);

select throws_ok(
  $$
    select public.reserve_bike(
      '30000000-0000-4000-8000-000000000003'::uuid,
      (select id from public.payment_methods where is_default)
    )
  $$,
  'P0001',
  'active_rental_exists',
  'duplicate blocking rental is rejected'
);

select throws_ok(
  $$update public.rentals set status = 'completed'$$,
  '42501',
  'permission denied for table rentals',
  'rider cannot directly update rental ledger'
);

reset role;

select is(
  (
    select status
    from public.rentals
    where user_id = '10000000-0000-4000-8000-000000000001'
  ),
  'pending_authorization',
  'reservation starts pending authorization'
);

select public.record_authorization_result(
  (
    select payment.id
    from public.rental_payments as payment
    where payment.kind = 'authorization'
      and payment.user_id = '10000000-0000-4000-8000-000000000001'
  ),
  true,
  'authorization-test-reference'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select lives_ok(
  $$
    select public.start_rental(
      (select id from public.rentals where status = 'authorized')
    )
  $$,
  'authorized rental can start'
);

reset role;
update public.rentals
set created_at = now() - interval '2 minutes',
    started_at = now() - interval '61 seconds'
where user_id = '10000000-0000-4000-8000-000000000001';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select public.request_return(
  (select id from public.rentals where status = 'active'),
  (select id from public.stations where code = 'test-return')
);
select public.complete_return(
  (select id from public.rentals where status = 'returning'),
  0.125
);

reset role;

select is(
  (
    select final_fare
    from public.rentals
    where user_id = '10000000-0000-4000-8000-000000000001'
  ),
  0.70::numeric,
  'fare rounds by started minute using pricing snapshot'
);

select is(
  (
    select status
    from public.bikes
    where code = 'BIKE-TEST-1'
  ),
  'available',
  'completed return restores bike availability'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}',
  true
);

select is(
  (select count(*)::bigint from public.rentals),
  0::bigint,
  'RLS hides another rider rentals'
);

select * from finish();
rollback;
