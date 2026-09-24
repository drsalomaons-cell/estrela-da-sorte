create extension if not exists pgcrypto;

create type public.app_role as enum ('super_adm','adm_central','adm_oficial','adm_regional','bd','agencia','host','user');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role public.app_role not null default 'user',
  created_at timestamptz not null default now()
);

create table if not exists public.agencies (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  name text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.hosts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  agency_id uuid references public.agencies(id) on delete set null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(user_id)
);

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid references public.profiles(id),
  max_seats integer not null default 30 check (max_seats between 1 and 30),
  video_enabled boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.room_seats (
  room_id uuid not null references public.rooms(id) on delete cascade,
  seat_no integer not null check (seat_no between 1 and 30),
  user_id uuid references public.profiles(id) on delete set null,
  joined_at timestamptz,
  primary key(room_id,seat_no)
);

create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  room_id uuid references public.rooms(id) on delete set null,
  user_id uuid references public.profiles(id) on delete set null,
  category text not null,
  severity text not null default 'warning',
  action text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.agencies enable row level security;
alter table public.hosts enable row level security;
alter table public.rooms enable row level security;
alter table public.room_seats enable row level security;
alter table public.incidents enable row level security;

create policy "profiles own read" on public.profiles for select using (auth.uid() = id);
create policy "rooms public read active" on public.rooms for select using (active = true);
create policy "seats public read" on public.room_seats for select using (true);
create policy "incidents admin read" on public.incidents for select using (
  exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in ('super_adm','adm_central','adm_oficial','adm_regional'))
);

-- Economia 50/50 permanece deliberadamente fora desta migration até auditoria das regras existentes.
