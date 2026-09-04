-- =============================================================================
-- BIKE REPORTS
-- =============================================================================

create table public.bike_reports (
  id bigint generated always as identity primary key,

  bike_id bigint not null
    references public.bikes (id)
    on delete restrict,

  reporter_id uuid
    references auth.users (id)
    on delete set null,

  category text not null
    constraint bike_reports_category_check
    check (
      category in (
        'brakes',
        'tyres',
        'chain_gears',
        'seat_frame',
        'bell_lights',
        'qr_lock',
        'other'
      )
    ),

  description text not null
    constraint bike_reports_description_check
    check (btrim(description) <> ''),

  status text not null default 'pending'
    constraint bike_reports_status_check
    check (
      status in (
        'pending',
        'approved',
        'rejected'
      )
    ),

  review_note text,

  reviewed_by uuid
    references auth.users (id)
    on delete set null,

  reviewed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint bike_reports_review_state_check
  check (
    (
      status = 'pending'
      and reviewed_by is null
      and reviewed_at is null
    )
    or
    (
      status in ('approved', 'rejected')
      and reviewed_by is not null
      and reviewed_at is not null
    )
  )
);


-- =============================================================================
-- INDEXES
-- =============================================================================

create index bike_reports_bike_created_at_idx
  on public.bike_reports (bike_id, created_at desc);

create index bike_reports_reporter_created_at_idx
  on public.bike_reports (reporter_id, created_at desc);

create index bike_reports_status_created_at_idx
  on public.bike_reports (status, created_at desc);


-- =============================================================================
-- UPDATED_AT TRIGGER
-- Existing public.set_updated_at() function is reused.
-- =============================================================================

create trigger bike_reports_set_updated_at
before update on public.bike_reports
for each row
execute function public.set_updated_at();


-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

alter table public.bike_reports enable row level security;


-- Rider can view reports submitted by themselves.
-- Admin can view every report.
create policy bike_reports_select_own_or_admin
on public.bike_reports
for select
to authenticated
using (
  reporter_id = (select auth.uid())
  or (select private.is_admin())
);


-- Authenticated user may only create a report as themselves.
create policy bike_reports_insert_own
on public.bike_reports
for insert
to authenticated
with check (
  reporter_id = (select auth.uid())
  and status = 'pending'
  and reviewed_by is null
  and reviewed_at is null
);


-- Only administrators may review/update reports.
create policy bike_reports_admin_update
on public.bike_reports
for update
to authenticated
using (
  (select private.is_admin())
)
with check (
  (select private.is_admin())
);


-- =============================================================================
-- PRIVILEGES
-- =============================================================================

revoke all on table public.bike_reports
from public, anon, authenticated;

grant select, insert, update
on public.bike_reports
to authenticated;


-- =============================================================================
-- IDENTITY SEQUENCE
-- =============================================================================

revoke all on sequence public.bike_reports_id_seq
from public, anon, authenticated;

grant usage on sequence public.bike_reports_id_seq
to authenticated;