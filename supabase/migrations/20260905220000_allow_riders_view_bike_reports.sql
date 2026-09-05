-- Allow authenticated users to select bike reports for bike condition checks
drop policy if exists bike_reports_select_own_or_admin on public.bike_reports;

create policy bike_reports_select_authenticated
on public.bike_reports
for select
to authenticated
using (true);

-- RPC for securely querying bike reports for a bike
create or replace function public.get_bike_reports_for_bike(p_bike_id bigint)
returns table (
  id bigint,
  bike_id bigint,
  reporter_id uuid,
  category text,
  description text,
  status text,
  review_note text,
  reviewed_by uuid,
  reviewed_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  return query
  select
    br.id,
    br.bike_id,
    br.reporter_id,
    br.category,
    br.description,
    br.status,
    br.review_note,
    br.reviewed_by,
    br.reviewed_at,
    br.created_at,
    br.updated_at
  from public.bike_reports br
  where br.bike_id = p_bike_id
  order by br.created_at desc;
end;
$$;

grant execute on function public.get_bike_reports_for_bike(bigint) to authenticated;
