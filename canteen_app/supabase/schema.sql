-- ============================================================
-- CampusCanteen — Supabase schema
-- Run this whole file in the Supabase SQL editor.
-- ============================================================

-- ---------- TABLES ----------

-- User profiles (one row per auth user)
-- role: student | college_staff | canteen_staff
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text not null default '',
  email       text not null,
  roll_number text not null default '',
  role        text not null default 'student'
    check (role in ('student', 'college_staff', 'canteen_staff')),
  created_at  timestamptz not null default now()
);

-- For databases created before this three-role split: widen the existing
-- constraint so college_staff/canteen_staff are accepted.
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('student', 'college_staff', 'canteen_staff'));

-- Menu items
create table if not exists public.menu_items (
  id                       uuid primary key default gen_random_uuid(),
  name                     text not null,
  description              text not null default '',
  price                    numeric(10, 2) not null,
  category                 text not null check (category in ('breakfast', 'lunch', 'snacks', 'drinks')),
  image_url                text not null default '',
  is_available             boolean not null default true,
  preparation_time_minutes int not null default 10,
  created_at               timestamptz not null default now()
);

-- Orders
create table if not exists public.orders (
  id             uuid primary key default gen_random_uuid(),
  order_number   text not null unique,
  user_id        uuid not null references public.profiles (id) on delete cascade,
  status         text not null default 'paidPendingApproval' check (status in ('paidPendingApproval', 'preparing', 'readyForPickup', 'completed', 'cancelled')),
  total_amount   numeric(10, 2) not null,
  pickup_start   timestamptz not null,
  pickup_end     timestamptz not null,
  transaction_id text,
  created_at     timestamptz not null default now()
);

create index if not exists orders_user_idx   on public.orders (user_id);
create index if not exists orders_status_idx on public.orders (status);
create index if not exists orders_pickup_idx on public.orders (pickup_start);

-- Order line items
create table if not exists public.order_items (
  id             bigint generated always as identity primary key,
  order_id       uuid not null references public.orders (id) on delete cascade,
  menu_item_id   uuid references public.menu_items (id),
  menu_item_name text not null,
  quantity       int not null check (quantity > 0),
  unit_price     numeric(10, 2) not null
);

create index if not exists order_items_order_idx on public.order_items (order_id);

-- Notifications
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  title      text not null,
  body       text not null default '',
  type       text not null default 'general',
  order_id   uuid references public.orders (id) on delete set null,
  is_read    boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_idx on public.notifications (user_id, is_read);

-- ---------- HELPER FUNCTIONS ----------

-- Whether the current user is any kind of staff (college or canteen)
create or replace function public.is_staff()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('college_staff', 'canteen_staff')
  );
$$;

-- Whether the current user is canteen staff (only they can manage the menu)
create or replace function public.is_canteen_staff()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'canteen_staff'
  );
$$;

-- Auto-create profile row when a user signs up (via Supabase Auth)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email, roll_number, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'roll_number', ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'student')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- ORDER DETAILS VIEW ----------

create or replace view public.order_details as
select
  o.id,
  o.order_number,
  o.user_id,
  o.status,
  o.total_amount,
  o.created_at,
  o.pickup_start as pickup_start_time,
  o.pickup_end   as pickup_end_time,
  o.transaction_id,
  coalesce(jsonb_agg(
    jsonb_build_object(
      'menuItemId',   oi.menu_item_id::text,
      'menuItemName', oi.menu_item_name,
      'quantity',     oi.quantity,
      'unitPrice',    to_char(oi.unit_price, 'FM999999999.99')::numeric
    ) order by oi.id
  ) filter (where oi.id is not null), '[]'::jsonb) as items
from public.orders o
left join public.order_items oi on oi.order_id = o.id
group by o.id;

-- ---------- RPC: place an order ----------

create or replace function public.place_order(
  p_items           jsonb,
  p_transaction_id  text,
  p_pickup_start    timestamptz,
  p_pickup_end      timestamptz
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id    uuid := auth.uid();
  v_order_id   uuid;
  v_item       jsonb;
  v_menu       record;
  v_total      numeric := 0;
  v_count      int;
  v_order_no   text;
  v_staff      record;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Serialise slot booking so two concurrent bookings can't overshoot capacity
  perform pg_advisory_xact_lock(hashtext('canteen_slot:' || p_pickup_start::text || ':' || p_pickup_end::text));

  select count(*) into v_count
  from public.orders
  where pickup_start = p_pickup_start
    and pickup_end   = p_pickup_end
    and status      <> 'cancelled';

  if v_count >= 30 then
    raise exception 'This time slot is full. Please choose another.';
  end if;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    select id, name, price, is_available
      into v_menu
      from public.menu_items
      where id = (v_item ->> 'menuItemId')::uuid;

    if v_menu.id is null then
      raise exception 'Item not found on the menu';
    end if;
    if not v_menu.is_available then
      raise exception '% is no longer available', v_menu.name;
    end if;

    v_total := v_total + ((v_item ->> 'quantity')::int * v_menu.price);
  end loop;

  v_order_no := 'ORD-' || upper(substr(md5(random()::text), 1, 6));

  insert into public.orders (order_number, user_id, status, total_amount, pickup_start, pickup_end, transaction_id)
  values (v_order_no, v_user_id, 'paidPendingApproval', v_total, p_pickup_start, p_pickup_end, p_transaction_id)
  returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    select name, price into v_menu from public.menu_items where id = (v_item ->> 'menuItemId')::uuid;
    insert into public.order_items (order_id, menu_item_id, menu_item_name, quantity, unit_price)
    values (v_order_id, (v_item ->> 'menuItemId')::uuid, v_menu.name, (v_item ->> 'quantity')::int, v_menu.price);
  end loop;

  -- Notify the student
  insert into public.notifications (user_id, title, body, type, order_id)
  values (v_user_id, 'Order placed successfully',
          'Your order ' || v_order_no || ' has been placed and is awaiting approval.', 'order_placed', v_order_id);

  -- Notify all staff members
  for v_staff in select id from public.profiles where role in ('college_staff', 'canteen_staff')
  loop
    insert into public.notifications (user_id, title, body, type, order_id)
    values (v_staff.id, 'New order received',
            'New order ' || v_order_no || ' is waiting for approval.', 'new_order', v_order_id);
  end loop;

  return (select to_jsonb(od) from public.order_details od where od.id = v_order_id);
end;
$$;

-- ---------- RPC: update order status ----------

create or replace function public.update_order_status(
  p_order_id  uuid,
  p_new_status text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_prev text;
  v_user_id uuid;
  v_order_no text;
  v_title text;
  v_body text;
  v_type text;
begin
  if not public.is_staff() then
    raise exception 'Only staff can update order status';
  end if;

  if p_new_status not in ('paidPendingApproval', 'preparing', 'readyForPickup', 'completed', 'cancelled') then
    raise exception 'Invalid status';
  end if;

  select status, order_number, user_id into v_prev, v_order_no, v_user_id
  from public.orders where id = p_order_id;

  if v_prev is null then
    raise exception 'Order not found';
  end if;

  if v_prev = p_new_status then
    return (select to_jsonb(od) from public.order_details od where od.id = p_order_id);
  end if;

  update public.orders set status = p_new_status where id = p_order_id;

  case p_new_status
    when 'preparing' then
      v_title := 'Order accepted'; v_body := 'Your order ' || v_order_no || ' is now being prepared.'; v_type := 'order_status';
    when 'readyForPickup' then
      v_title := 'Ready for pickup'; v_body := 'Your order ' || v_order_no || ' is ready. Please collect it from the counter.'; v_type := 'order_status';
    when 'completed' then
      v_title := 'Order completed'; v_body := 'Your order ' || v_order_no || ' has been collected. Enjoy your meal!'; v_type := 'order_status';
    when 'cancelled' then
      v_title := 'Order cancelled'; v_body := 'Your order ' || v_order_no || ' was cancelled. Your payment will be refunded.'; v_type := 'order_status';
    else
      v_title := 'Order updated'; v_body := 'Your order ' || v_order_no || ' status changed.'; v_type := 'order_status';
  end case;

  insert into public.notifications (user_id, title, body, type, order_id)
  values (v_user_id, v_title, v_body, v_type, p_order_id);

  return (select to_jsonb(od) from public.order_details od where od.id = p_order_id);
end;
$$;

-- ---------- ROW LEVEL SECURITY ----------

alter table public.profiles enable row level security;
alter table public.menu_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.notifications enable row level security;

-- profiles
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select to authenticated using (true);

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert on public.profiles
  for insert to authenticated with check (id = auth.uid());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
  for update to authenticated using (id = auth.uid() or public.is_staff());

-- menu_items (any logged-in user can read; only canteen staff can manage)
drop policy if exists menu_items_select on public.menu_items;
create policy menu_items_select on public.menu_items
  for select to authenticated using (true);

drop policy if exists menu_items_insert on public.menu_items;
create policy menu_items_insert on public.menu_items
  for insert to authenticated with check (public.is_canteen_staff());

drop policy if exists menu_items_update on public.menu_items;
create policy menu_items_update on public.menu_items
  for update to authenticated using (public.is_canteen_staff());

drop policy if exists menu_items_delete on public.menu_items;
create policy menu_items_delete on public.menu_items
  for delete to authenticated using (public.is_canteen_staff());

-- orders (users see their own; staff see everything). Inserts only happen via the place_order RPC.
drop policy if exists orders_select on public.orders;
create policy orders_select on public.orders
  for select to authenticated using (user_id = auth.uid() or public.is_staff());

drop policy if exists orders_update on public.orders;
create policy orders_update on public.orders
  for update to authenticated using (public.is_staff());

-- order_items
drop policy if exists order_items_select on public.order_items;
create policy order_items_select on public.order_items
  for select to authenticated
  using (
    exists (select 1 from public.orders o where o.id = order_id)
    and (public.is_staff() or exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()))
  );

-- notifications (users see/mark their own; staff can also manage)
drop policy if exists notifications_select on public.notifications;
create policy notifications_select on public.notifications
  for select to authenticated using (user_id = auth.uid() or public.is_staff());

drop policy if exists notifications_insert on public.notifications;
create policy notifications_insert on public.notifications
  for insert to authenticated with check (public.is_staff() or user_id = auth.uid());

drop policy if exists notifications_update on public.notifications;
create policy notifications_update on public.notifications
  for update to authenticated using (user_id = auth.uid() or public.is_staff());

-- ---------- REALTIME ----------

do $$
begin
  alter publication supabase_realtime add table public.orders;
  alter publication supabase_realtime add table public.menu_items;
  alter publication supabase_realtime add table public.notifications;
exception
  when duplicate_object then null;
end $$;

-- NOTE: There is intentionally NO seed menu data. Staff add menu items
-- from inside the app (Menu Management tab). The menu stays empty until
-- a staff member adds the first item.