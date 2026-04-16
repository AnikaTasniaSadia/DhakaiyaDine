-- Run this in Supabase SQL Editor.
-- Creates users profile table and RLS policies for authenticated users.

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  phone text,
  created_at timestamptz not null default now()
);

alter table public.users enable row level security;

-- Users can insert only their own profile row.
drop policy if exists "users_insert_own_profile" on public.users;
create policy "users_insert_own_profile"
  on public.users
  for insert
  to authenticated
  with check (auth.uid() = id);

-- Users can read only their own profile row.
drop policy if exists "users_select_own_profile" on public.users;
create policy "users_select_own_profile"
  on public.users
  for select
  to authenticated
  using (auth.uid() = id);

-- Optional safety: users can update only their own row.
drop policy if exists "users_update_own_profile" on public.users;
create policy "users_update_own_profile"
  on public.users
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);
