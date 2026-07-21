-- Run this in Supabase SQL Editor.
-- Extend the users table with role-based access and add common admin tables.

alter table public.users add column if not exists role text not null default 'customer';

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  opening_hours text,
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.foods (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price numeric not null default 0,
  discount numeric not null default 0,
  available boolean not null default true,
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.tables (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  status text not null default 'available',
  capacity integer not null default 4,
  created_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  customer_name text,
  rating numeric not null default 5,
  comment text,
  reply text,
  created_at timestamptz not null default now()
);

alter table public.branches enable row level security;
alter table public.foods enable row level security;
alter table public.banners enable row level security;
alter table public.tables enable row level security;
alter table public.reviews enable row level security;

create policy if not exists branches_select_all on public.branches for select to authenticated using (true);
create policy if not exists branches_modify_admin on public.branches for all to authenticated using (true) with check (true);
create policy if not exists foods_select_all on public.foods for select to authenticated using (true);
create policy if not exists foods_modify_admin on public.foods for all to authenticated using (true) with check (true);
create policy if not exists banners_select_all on public.banners for select to authenticated using (true);
create policy if not exists banners_modify_admin on public.banners for all to authenticated using (true) with check (true);
create policy if not exists tables_select_all on public.tables for select to authenticated using (true);
create policy if not exists tables_modify_admin on public.tables for all to authenticated using (true) with check (true);
create policy if not exists reviews_select_all on public.reviews for select to authenticated using (true);
create policy if not exists reviews_modify_admin on public.reviews for all to authenticated using (true) with check (true);
