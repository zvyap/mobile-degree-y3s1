create table public.notifications (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  rental_id bigint references public.rentals (id) on delete cascade,
  rental_event_id bigint unique references public.rental_events (id) on delete cascade,
  type text not null,
  data jsonb not null default '{}'::jsonb
    constraint notifications_data_object_check
    check (jsonb_typeof(data) = 'object'),
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_user_created_at_idx
  on public.notifications (user_id, created_at desc);
create index notifications_user_unread_idx
  on public.notifications (user_id, created_at desc)
  where read_at is null;
create function private.create_rental_notification()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.user_id is null then
    return new;
  end if;

  insert into public.notifications (
    user_id,
    rental_id,
    rental_event_id,
    type,
    data,
    created_at
  )
  values (
    new.user_id,
    new.rental_id,
    new.id,
    new.event_type,
    new.payload,
    new.created_at
  )
  on conflict (rental_event_id) do nothing;

  return new;
end;
$$;
create trigger rental_events_create_notification
after insert on public.rental_events
for each row execute function private.create_rental_notification();
alter table public.notifications enable row level security;
create policy notifications_select_own
on public.notifications for select
to authenticated
using (user_id = (select auth.uid()));
create policy notifications_update_own
on public.notifications for update
to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));
revoke all on table public.notifications from public, anon, authenticated;
grant select on public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;
revoke all on sequence public.notifications_id_seq
from public, anon, authenticated;
revoke execute on function private.create_rental_notification()
from public, anon, authenticated, service_role;
do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;
end;
$$;
