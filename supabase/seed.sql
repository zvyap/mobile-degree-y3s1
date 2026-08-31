-- Local development data only. `supabase db push` does not apply this file.
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
  seed.code,
  seed.qr_token,
  station.id,
  seed.battery_percent,
  'available'
from (
  values
    ('BIKE-C042', '00000000-0000-4000-8000-000000000042'::uuid, 'central', 86),
    ('BIKE-R017', '00000000-0000-4000-8000-000000000017'::uuid, 'riverside', 72),
    ('BIKE-M008', '00000000-0000-4000-8000-000000000008'::uuid, 'market', 91),
    ('BIKE-U031', '00000000-0000-4000-8000-000000000031'::uuid, 'university', 64)
) as seed(code, qr_token, station_code, battery_percent)
join public.stations as station on station.code = seed.station_code
on conflict (code) do nothing;
