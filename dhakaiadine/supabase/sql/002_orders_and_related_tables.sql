-- Run this in Supabase SQL Editor after 001_users_table_and_policies.sql

-- ── Orders ────────────────────────────────────────────────────────────────────
create table if not exists public.orders (
  id            bigserial primary key,
  user_id       uuid references auth.users(id) on delete set null,
  token_number  text not null,
  status        text not null default 'received',
  total         numeric(10,2) not null default 0,
  delivery_fee  numeric(10,2) not null default 0,
  grand_total   numeric(10,2) not null default 0,
  delivery_method text not null default 'home',
  payment_method  text not null default 'cash',
  branch        text,
  table_number  text,
  created_at    timestamptz not null default now()
);

alter table public.orders enable row level security;

drop policy if exists "orders_insert_own" on public.orders;
create policy "orders_insert_own"
  on public.orders for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "orders_select_own" on public.orders;
create policy "orders_select_own"
  on public.orders for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "orders_update_own" on public.orders;
create policy "orders_update_own"
  on public.orders for update to authenticated
  using (auth.uid() = user_id);

-- ── Order Items ───────────────────────────────────────────────────────────────
create table if not exists public.order_items (
  id          bigserial primary key,
  order_id    bigint references public.orders(id) on delete cascade,
  food_id     text not null,
  name        text not null,
  image_url   text,
  unit_price  numeric(10,2) not null,
  quantity    int not null,
  total_price numeric(10,2) not null
);

alter table public.order_items enable row level security;

drop policy if exists "order_items_insert_own" on public.order_items;
create policy "order_items_insert_own"
  on public.order_items for insert to authenticated
  with check (
    exists (
      select 1 from public.orders
      where id = order_id and user_id = auth.uid()
    )
  );

drop policy if exists "order_items_select_own" on public.order_items;
create policy "order_items_select_own"
  on public.order_items for select to authenticated
  using (
    exists (
      select 1 from public.orders
      where id = order_id and user_id = auth.uid()
    )
  );

-- ── Favorites ─────────────────────────────────────────────────────────────────
create table if not exists public.favorites (
  id       bigserial primary key,
  user_id  uuid not null references auth.users(id) on delete cascade,
  food_id  text not null,
  unique (user_id, food_id)
);

alter table public.favorites enable row level security;

drop policy if exists "favorites_all_own" on public.favorites;
create policy "favorites_all_own"
  on public.favorites for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ── Reviews ───────────────────────────────────────────────────────────────────
create table if not exists public.reviews (
  id         bigserial primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  food_id    text not null,
  rating     int not null check (rating between 1 and 5),
  comment    text,
  created_at timestamptz not null default now()
);

alter table public.reviews enable row level security;

drop policy if exists "reviews_all_own" on public.reviews;
create policy "reviews_all_own"
  on public.reviews for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Enable realtime for order status tracking
alter publication supabase_realtime add table public.orders;
