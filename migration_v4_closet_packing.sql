-- Move HQ V4.1 migration
-- Run this once in an EXISTING Move HQ Supabase project that started on V3.
-- It is safe to run repeatedly.
create extension if not exists pgcrypto;

create table if not exists public.containers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null default 'Box',
  status text not null default 'Planned',
  length numeric,
  width numeric,
  height numeric,
  dimension_unit text default 'in',
  weight_limit numeric,
  weight_unit text default 'lb',
  location text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.closet_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  category text not null default 'Other',
  quantity integer default 1,
  season text default 'All',
  keep_action text default 'Decide',
  status text default 'Planned',
  container_id uuid references public.containers(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.container_contents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  container_id uuid not null references public.containers(id) on delete cascade,
  inventory_id uuid references public.inventory(id) on delete set null,
  closet_item_id uuid references public.closet_items(id) on delete set null,
  source_type text default 'Manual',
  name text not null,
  quantity integer default 1,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.containers enable row level security;
alter table public.closet_items enable row level security;
alter table public.container_contents enable row level security;

drop policy if exists "containers own" on public.containers;
drop policy if exists "closet own" on public.closet_items;
drop policy if exists "container contents own" on public.container_contents;

create policy "containers own" on public.containers
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "closet own" on public.closet_items
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "container contents own" on public.container_contents
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Backfill nothing automatically: existing V3 data is intentionally preserved.
-- After this migration, refresh the app. Closet items can then be assigned to
-- physical containers through Packing Helper -> Add content -> Closet.
