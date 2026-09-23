-- Move HQ V3: run this entire file in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade, display_name text, move_date date, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.rooms (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, budget numeric default 0, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.tasks (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, title text not null, category text default 'Move', due_date date, priority text default 'Medium', done boolean default false, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.inventory (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, room_id uuid references public.rooms(id) on delete set null, name text not null, quantity integer default 1, action text default 'Bring', status text default 'Planned', price numeric default 0, product_url text, photo_path text, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.wishlist (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, room_id uuid references public.rooms(id) on delete set null, name text not null, price numeric default 0, priority text default 'Nice to have', status text default 'Considering', product_url text, photo_path text, notes text, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.moodboard (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, room_id uuid references public.rooms(id) on delete set null, title text not null, image_path text, image_url text, notes text, created_at timestamptz default now(), updated_at timestamptz default now());

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.tasks enable row level security;
alter table public.inventory enable row level security;
alter table public.wishlist enable row level security;
alter table public.moodboard enable row level security;

create policy "profiles own" on public.profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "rooms own" on public.rooms for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "tasks own" on public.tasks for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "inventory own" on public.inventory for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "wishlist own" on public.wishlist for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "moodboard own" on public.moodboard for all using (user_id = auth.uid()) with check (user_id = auth.uid());

insert into storage.buckets (id, name, public) values ('move-hq-media','move-hq-media',false) on conflict (id) do nothing;
create policy "media read own" on storage.objects for select to authenticated using (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "media upload own" on storage.objects for insert to authenticated with check (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "media update own" on storage.objects for update to authenticated using (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "media delete own" on storage.objects for delete to authenticated using (bucket_id='move-hq-media' and (storage.foldername(name))[1] = auth.uid()::text);

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,display_name) values(new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1))) on conflict (id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
