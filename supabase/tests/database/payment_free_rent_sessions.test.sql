begin;

select plan(22);

select has_column(
  'public',
  'rentals',
  'payment_required',
  'rentals records whether a provider payment is required'
);
select has_index(
  'public',
  'rentals',
  'rentals_one_blocking_per_user_idx',
  'one blocking rental per rider remains enforced'
);
select has_function(
  'public',
  'reserve_rental_session',
  array['uuid'],
  'payment-free reservation RPC exists'
);

insert into auth.users (id, email, raw_user_meta_data)
values
  (
    '71000000-0000-4000-8000-000000000001',
    'payment-free-one@example.test',
    '{"display_name":"Payment Free One"}'::jsonb
  ),
  (
    '72000000-0000-4000-8000-000000000002',
    'payment-free-two@example.test',
    '{"display_name":"Payment Free Two"}'::jsonb
  );

insert into public.stations (
  code, name, address, latitude, longitude, capacity
)
values
  ('pf-origin', 'Payment Free Origin', 'Origin', 3.1, 101.6, 8),
  ('pf-return', 'Payment Free Return', 'Return', 3.2, 101.7, 8),
  ('pf-full', 'Payment Free Full', 'Full', 3.3, 101.8, 1);

insert into public.bikes (
  code, qr_token, current_station_id, battery_percent, status
)
select fixture.code, fixture.qr_token, station.id, 90, fixture.status
from (
  values
    ('BIKE-PF-EXPIRE', '73000000-0000-4000-8000-000000000003'::uuid, 'pf-origin', 'available'),
    ('BIKE-PF-RIDE', '74000000-0000-4000-8000-000000000004'::uuid, 'pf-origin', 'available'),
    ('BIKE-PF-CANCEL', '75000000-0000-4000-8000-000000000005'::uuid, 'pf-origin', 'available'),
    ('BIKE-PF-FULL-CHECK', '76000000-0000-4000-8000-000000000006'::uuid, 'pf-origin', 'available'),
    ('BIKE-PF-OCCUPIED', '77000000-0000-4000-8000-000000000007'::uuid, 'pf-full', 'maintenance')
) as fixture(code, qr_token, station_code, status)
join public.stations as station on station.code = fixture.station_code;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"71000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select lives_ok(
  $$select public.reserve_rental_session(
    '73000000-0000-4000-8000-000000000003'::uuid
  )$$,
  'rider reserves an available test bike'
);

select is(
  (
    select first_rental.id
    from public.rentals as first_rental
    where first_rental.status = 'reserved'
  ),
  (
    select repeated.id
    from public.reserve_rental_session(
      '73000000-0000-4000-8000-000000000003'::uuid
    ) as repeated
  ),
  'repeated scan returns the existing reservation'
);

select throws_ok(
  $$select public.reserve_rental_session(
    '74000000-0000-4000-8000-000000000004'::uuid
  )$$,
  'P0001',
  'active_rental_exists',
  'one rider cannot reserve a second bike'
);

reset role;
update public.rentals
set reservation_expires_at = now() - interval '1 second'
where status = 'reserved';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"71000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select lives_ok(
  $$select public.reserve_rental_session(
    '74000000-0000-4000-8000-000000000004'::uuid
  )$$,
  'expired reservation is cleaned before reserving another bike'
);
select is(
  (select status from public.bikes where code = 'BIKE-PF-EXPIRE'),
  'available',
  'expiry restores the old bike'
);
select lives_ok(
  $$select public.start_rental(
    (select id from public.rentals where status = 'reserved')
  )$$,
  'payment-free reservation starts without authorization'
);
select lives_ok(
  $$select public.request_return(
    (select id from public.rentals where status = 'active'),
    (select id from public.stations where code = 'pf-return')
  )$$,
  'rider requests a return station'
);
select lives_ok(
  $$select public.resume_rental(
    (select id from public.rentals where status = 'returning')
  )$$,
  'rider resumes after selecting a station'
);
select public.request_return(
  (select id from public.rentals where status = 'active'),
  (select id from public.stations where code = 'pf-return')
);

reset role;
update public.rentals
set created_at = now() - interval '2 minutes',
    started_at = now() - interval '61 seconds'
where status = 'returning';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"71000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.complete_return(
  (select id from public.rentals where status = 'returning'),
  1.250
);

select is(
  (
    select status from public.rentals
    where user_id = '71000000-0000-4000-8000-000000000001'
      and bike_id = (select id from public.bikes where code = 'BIKE-PF-RIDE')
  ),
  'completed',
  'docked payment-free ride completes immediately'
);
select is(
  (
    select payment_required from public.rentals
    where bike_id = (select id from public.bikes where code = 'BIKE-PF-RIDE')
  ),
  false,
  'completed test ride remains payment-free'
);
select is(
  (
    select final_fare from public.rentals
    where bike_id = (select id from public.bikes where code = 'BIKE-PF-RIDE')
  ),
  0.70::numeric,
  'server calculates fare from two started minutes'
);
select is(
  (
    select distance_km from public.rentals
    where bike_id = (select id from public.bikes where code = 'BIKE-PF-RIDE')
  ),
  1.250::numeric,
  'submitted test distance is stored'
);
select is(
  (
    select count(*)::bigint
    from public.rental_payments as payment
    join public.rentals as rental on rental.id = payment.rental_id
    where rental.user_id = '71000000-0000-4000-8000-000000000001'
      and not rental.payment_required
  ),
  0::bigint,
  'payment-free sessions create no payment ledger rows'
);
select is(
  (select status from public.bikes where code = 'BIKE-PF-RIDE'),
  'available',
  'completed return restores bike availability'
);

select public.reserve_rental_session(
  '75000000-0000-4000-8000-000000000005'::uuid
);
select public.cancel_rental(
  (select id from public.rentals where status = 'reserved')
);
select is(
  (select status from public.bikes where code = 'BIKE-PF-CANCEL'),
  'available',
  'cancelling a reservation restores the bike'
);

select public.reserve_rental_session(
  '76000000-0000-4000-8000-000000000006'::uuid
);
select public.start_rental(
  (select id from public.rentals where status = 'reserved')
);
select throws_ok(
  $$select public.request_return(
    (select id from public.rentals where status = 'active'),
    (select id from public.stations where code = 'pf-full')
  )$$,
  'P0001',
  'station_full',
  'full station rejects return request'
);
select ok(
  (
    select count(*) >= 7
    from public.rental_events
    where user_id = '71000000-0000-4000-8000-000000000001'
  ),
  'rental lifecycle writes audit events'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"72000000-0000-4000-8000-000000000002","role":"authenticated"}',
  true
);
select is(
  (select count(*)::bigint from public.rentals),
  0::bigint,
  'RLS hides another rider rentals'
);
select throws_ok(
  $$update public.rentals set status = 'completed'$$,
  '42501',
  'permission denied for table rentals',
  'rider cannot directly mutate the rental ledger'
);

select * from finish();
rollback;
