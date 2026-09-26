-- Move HQ V4: run this entire file in Supabase SQL Editor.
-- V4 adds a real packing-container model and a dedicated closet inventory.
create extension if not exists pgcrypto;

create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade, display_name text, move_date date, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.rooms (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, budget numeric default 0, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.tasks (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, title text not null, category text default 'Move', due_date date, priority text default 'Medium', done boolean default false, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.inventory (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, room_id uuid references public.rooms(id) on delete set null, name text not null, quantity integer default 1, action text default 'Bring', status text default 'Planned', price numeric default 0, product_url text, photo_path text, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.wishlist (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, room_id uuid references public.rooms(id) on delete set null, name text not null, price numeric default 0, priority text default 'Nice to have', status text default 'Considering', product_url text, photo_path text, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.moodboard (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, room_id uuid references public.rooms(id) on delete set null, title text not null, image_path text, image_url text, notes text, created_at timestamptz default now(), updated_at timestamptz default now());

-- Physical things used to pack: boxes, suitcases, bags, bins, etc.
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

-- Dedicated closet inventory so clothes/shoes/accessories can be managed
-- separately from furniture and household inventory.
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


-- The exact contents of each physical container. Contents can be linked to an
-- inventory item, closet item, or entered manually (e.g. "Shoes A").
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

-- The container_contents table references closet_items, so create the table
-- first on a brand-new database if the parser requires dependency ordering.
-- If your Supabase project errors because the two tables were created in the
-- opposite order, run the following two statements after creating both:
-- alter table public.container_contents add constraint container_contents_closet_fk foreign key (closet_item_id) references public.closet_items(id) on delete set null;

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.tasks enable row level security;
alter table public.inventory enable row level security;
alter table public.wishlist enable row level security;
alter table public.moodboard enable row level security;
alter table public.containers enable row level security;
alter table public.container_contents enable row level security;
alter table public.closet_items enable row level security;

drop policy if exists "profiles own" on public.profiles;
drop policy if exists "rooms own" on public.rooms;
drop policy if exists "tasks own" on public.tasks;
drop policy if exists "inventory own" on public.inventory;
drop policy if exists "wishlist own" on public.wishlist;
drop policy if exists "moodboard own" on public.moodboard;
drop policy if exists "containers own" on public.containers;
drop policy if exists "container contents own" on public.container_contents;
drop policy if exists "closet own" on public.closet_items;

create policy "profiles own" on public.profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "rooms own" on public.rooms for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "tasks own" on public.tasks for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "inventory own" on public.inventory for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "wishlist own" on public.wishlist for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "moodboard own" on public.moodboard for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "containers own" on public.containers for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "container contents own" on public.container_contents for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "closet own" on public.closet_items for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "media read own" on storage.objects;
drop policy if exists "media upload own" on storage.objects;
drop policy if exists "media update own" on storage.objects;
drop policy if exists "media delete own" on storage.objects;
insert into storage.buckets (id, name, public) values ('move-hq-media','move-hq-media',false) on conflict (id) do nothing;
create policy "media read own" on storage.objects for select to authenticated using (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "media upload own" on storage.objects for insert to authenticated with check (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "media update own" on storage.objects for update to authenticated using (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "media delete own" on storage.objects for delete to authenticated using (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,display_name) values(new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1))) on conflict (id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
