-- Add cardholder_name to payment_methods
alter table public.payment_methods
  add column if not exists cardholder_name text;

-- Trigger: ensure only one default payment method per user by resetting previous defaults
create or replace function private.handle_payment_method_default()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.is_default then
    update public.payment_methods
    set is_default = false
    where user_id = new.user_id
      and id <> coalesce(new.id, -1)
      and is_default = true;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_payment_methods_default on public.payment_methods;
create trigger trg_payment_methods_default
before insert or update of is_default on public.payment_methods
for each row
when (new.is_default = true)
execute function private.handle_payment_method_default();

-- Trigger: prevent deleting payment methods attached to active rental sessions
create or replace function private.prevent_active_rental_payment_method_delete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (
    select 1 from public.rentals
    where payment_method_id = old.id
      and status in (
        'pending_authorization',
        'authorized',
        'active',
        'returning',
        'payment_pending',
        'payment_failed'
      )
  ) then
    raise exception using errcode = 'P0001', message = 'payment_method_in_use';
  end if;
  return old;
end;
$$;

drop trigger if exists trg_prevent_active_rental_payment_method_delete on public.payment_methods;
create trigger trg_prevent_active_rental_payment_method_delete
before delete on public.payment_methods
for each row
execute function private.prevent_active_rental_payment_method_delete();

-- Grant permissions for authenticated users
grant select, insert, update, delete on public.payment_methods to authenticated;
