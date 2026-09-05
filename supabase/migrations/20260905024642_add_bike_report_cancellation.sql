-- =============================================================================
-- BIKE REPORT CANCELLATION
-- =============================================================================
-- Riders may cancel only their own pending reports.
-- Reports are soft-cancelled instead of physically deleted.
-- =============================================================================


-- =============================================================================
-- 1. ALLOW "cancelled" STATUS
-- =============================================================================

alter table public.bike_reports
drop constraint if exists bike_reports_status_check;

alter table public.bike_reports
add constraint bike_reports_status_check
check (
  status in (
    'pending',
    'approved',
    'rejected',
    'cancelled'
  )
);


-- =============================================================================
-- 2. UPDATE REVIEW STATE CONSTRAINT
-- =============================================================================
-- Pending and cancelled reports have not been reviewed.
-- Approved/rejected reports must have reviewer information.
-- =============================================================================

alter table public.bike_reports
drop constraint if exists bike_reports_review_state_check;

alter table public.bike_reports
add constraint bike_reports_review_state_check
check (
  (
    status in ('pending', 'cancelled')
    and reviewed_by is null
    and reviewed_at is null
  )
  or
  (
    status in ('approved', 'rejected')
    and reviewed_by is not null
    and reviewed_at is not null
  )
);


-- =============================================================================
-- 3. CANCEL REPORT FUNCTION
-- =============================================================================
-- Using a database function instead of giving riders general UPDATE access
-- prevents them from modifying bike_id, category, description, etc.
-- =============================================================================

create or replace function public.cancel_bike_report(
  p_report_id bigint
)
returns public.bike_reports
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_report public.bike_reports;
begin
  v_user_id := auth.uid();

  if v_user_id is null then
    raise exception 'You must be signed in to cancel a report.';
  end if;

  select *
  into v_report
  from public.bike_reports
  where id = p_report_id;

  if not found then
    raise exception 'Report not found.';
  end if;

  if v_report.reporter_id is distinct from v_user_id then
    raise exception 'You can only cancel your own reports.';
  end if;

  if v_report.status <> 'pending' then
    raise exception 'Only pending reports can be cancelled.';
  end if;

  update public.bike_reports
  set status = 'cancelled'
  where id = p_report_id
    and reporter_id = v_user_id
    and status = 'pending'
  returning *
  into v_report;

  if not found then
    raise exception 'Report could not be cancelled.';
  end if;

  return v_report;
end;
$$;


-- =============================================================================
-- 4. FUNCTION PERMISSIONS
-- =============================================================================

revoke all
on function public.cancel_bike_report(bigint)
from public, anon;

grant execute
on function public.cancel_bike_report(bigint)
to authenticated;