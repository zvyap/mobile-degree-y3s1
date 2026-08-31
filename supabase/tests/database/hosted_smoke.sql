begin;

insert into auth.users (id, email, raw_user_meta_data)
values
  (
    '91000000-0000-4000-8000-000000000001',
    'hosted-smoke-one@example.test',
    '{"display_name":"Hosted Smoke One"}'::jsonb
  ),
  (
    '92000000-0000-4000-8000-000000000002',
    'hosted-smoke-two@example.test',
    '{"display_name":"Hosted Smoke Two"}'::jsonb
  );

insert into public.stations (
  code, name, address, latitude, longitude, capacity
)
values
  ('hosted-smoke-origin', 'Hosted Smoke Origin', 'Origin', 3.1, 101.6, 2),
  ('hosted-smoke-return', 'Hosted Smoke Return', 'Return', 3.2, 101.7, 2);

insert into public.bikes (
  code, qr_token, current_station_id, battery_percent, status
)
select
  'BIKE-HOSTED-SMOKE',
  '93000000-0000-4000-8000-000000000003'::uuid,
  station.id,
  90,
  'available'
from public.stations as station
where station.code = 'hosted-smoke-origin';

insert into public.payment_methods (
  user_id, provider, provider_token, brand, last_four, is_default
)
values (
  '91000000-0000-4000-8000-000000000001',
  'hosted-smoke-provider',
  'hosted-smoke-token',
  'Visa',
  '4242',
  true
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select public.reserve_bike(
  '93000000-0000-4000-8000-000000000003'::uuid,
  (select id from public.payment_methods where is_default)
);

do $$
begin
  begin
    perform public.reserve_bike(
      '93000000-0000-4000-8000-000000000003'::uuid,
      (select id from public.payment_methods where is_default)
    );
    raise exception 'duplicate reservation unexpectedly succeeded';
  exception
    when raise_exception then
      if sqlerrm <> 'active_rental_exists' then
        raise;
      end if;
  end;
end;
$$;

reset role;

select public.record_authorization_result(
  (
    select payment.id
    from public.rental_payments as payment
    where payment.kind = 'authorization'
      and payment.user_id = '91000000-0000-4000-8000-000000000001'
  ),
  true,
  'hosted-smoke-authorization'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.start_rental(
  (select id from public.rentals where status = 'authorized')
);

reset role;
update public.rentals
set created_at = now() - interval '2 minutes',
    started_at = now() - interval '61 seconds'
where user_id = '91000000-0000-4000-8000-000000000001';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.request_return(
  (select id from public.rentals where status = 'active'),
  (select id from public.stations where code = 'hosted-smoke-return')
);
select public.complete_return(
  (select id from public.rentals where status = 'returning'),
  0.125
);

reset role;

select public.record_payment_result(
  (
    select payment.id
    from public.rental_payments as payment
    where payment.kind = 'capture' and payment.status = 'pending'
    order by payment.id desc
    limit 1
  ),
  false,
  'hosted-smoke-capture-failed',
  'card_declined',
  'Hosted smoke decline'
);

do $$
begin
  if not exists (
    select 1 from public.rentals where status = 'payment_failed'
  ) then
    raise exception 'capture failure did not mark rental payment_failed';
  end if;
end;
$$;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.request_payment_retry(
  (select id from public.rentals where status = 'payment_failed')
);
reset role;

select public.record_payment_result(
  (
    select payment.id
    from public.rental_payments as payment
    where payment.kind = 'capture' and payment.status = 'pending'
    order by payment.id desc
    limit 1
  ),
  true,
  'hosted-smoke-capture-succeeded'
);

insert into public.bikes (
  code, qr_token, current_station_id, battery_percent, status
)
select seed.code, seed.qr_token, station.id, 80, 'available'
from (
  values
    ('BIKE-HOSTED-CANCEL', '94000000-0000-4000-8000-000000000004'::uuid),
    ('BIKE-HOSTED-EXPIRE', '95000000-0000-4000-8000-000000000005'::uuid),
    ('BIKE-HOSTED-ACTIVE', '96000000-0000-4000-8000-000000000006'::uuid)
) as seed(code, qr_token)
cross join public.stations as station
where station.code = 'hosted-smoke-origin';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.reserve_bike(
  '94000000-0000-4000-8000-000000000004'::uuid,
  (select id from public.payment_methods where is_default)
);
select public.cancel_rental(
  (
    select id from public.rentals
    where status = 'pending_authorization'
    order by id desc limit 1
  )
);
reset role;

do $$
begin
  if (
    select status from public.bikes where code = 'BIKE-HOSTED-CANCEL'
  ) <> 'available' then
    raise exception 'cancellation did not restore bike availability';
  end if;
end;
$$;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.reserve_bike(
  '95000000-0000-4000-8000-000000000005'::uuid,
  (select id from public.payment_methods where is_default)
);
reset role;

update public.rentals
set reservation_expires_at = now() - interval '1 second'
where status = 'pending_authorization';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.reserve_bike(
  '96000000-0000-4000-8000-000000000006'::uuid,
  (select id from public.payment_methods where is_default)
);

do $$
begin
  begin
    perform public.start_rental(
      (select id from public.rentals where status = 'pending_authorization')
    );
    raise exception 'unauthorized rental unexpectedly started';
  exception
    when raise_exception then
      if sqlerrm <> 'invalid_rental_transition' then
        raise;
      end if;
  end;
end;
$$;

reset role;

do $$
begin
  if (
    select status from public.bikes where code = 'BIKE-HOSTED-EXPIRE'
  ) <> 'available' then
    raise exception 'expired reservation did not restore bike';
  end if;
end;
$$;

select public.record_authorization_result(
  (
    select payment.id
    from public.rental_payments as payment
    join public.rentals as rental on rental.id = payment.rental_id
    where payment.kind = 'authorization'
      and payment.status = 'pending'
      and rental.status = 'pending_authorization'
    order by payment.id desc
    limit 1
  ),
  true,
  'hosted-smoke-second-authorization'
);

insert into public.stations (
  code, name, address, latitude, longitude, capacity
)
values ('hosted-smoke-full', 'Hosted Smoke Full', 'Full', 3.3, 101.8, 1);

insert into public.bikes (
  code, qr_token, current_station_id, battery_percent, status
)
select
  'BIKE-HOSTED-OCCUPIED',
  '97000000-0000-4000-8000-000000000007'::uuid,
  station.id,
  50,
  'maintenance'
from public.stations as station
where station.code = 'hosted-smoke-full';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select public.start_rental(
  (select id from public.rentals where status = 'authorized')
);

do $$
begin
  begin
    perform public.request_return(
      (select id from public.rentals where status = 'active'),
      (select id from public.stations where code = 'hosted-smoke-full')
    );
    raise exception 'full station unexpectedly accepted return';
  exception
    when raise_exception then
      if sqlerrm <> 'station_full' then
        raise;
      end if;
  end;
end;
$$;

reset role;

do $$
declare
  v_fare numeric(10, 2);
  v_bike_status text;
  v_event_count integer;
begin
  select rental.final_fare into v_fare
  from public.rentals as rental
  where rental.user_id = '91000000-0000-4000-8000-000000000001'
    and rental.final_fare is not null
  order by rental.id
  limit 1;
  if v_fare <> 0.70 then
    raise exception 'unexpected fare: %', v_fare;
  end if;

  select bike.status into v_bike_status
  from public.bikes as bike
  where bike.code = 'BIKE-HOSTED-SMOKE';
  if v_bike_status <> 'available' then
    raise exception 'bike was not restored: %', v_bike_status;
  end if;

  select count(*)::integer into v_event_count
  from public.rental_events as event
  where event.user_id = '91000000-0000-4000-8000-000000000001';
  if v_event_count < 5 then
    raise exception 'missing rental audit events: %', v_event_count;
  end if;
end;
$$;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"92000000-0000-4000-8000-000000000002","role":"authenticated"}',
  true
);

do $$
begin
  if (select count(*) from public.rentals) <> 0 then
    raise exception 'RLS exposed another rider rental';
  end if;

  begin
    update public.rentals set status = 'completed';
    raise exception 'direct rental update unexpectedly succeeded';
  exception
    when insufficient_privilege then null;
  end;
end;
$$;

reset role;
rollback;
