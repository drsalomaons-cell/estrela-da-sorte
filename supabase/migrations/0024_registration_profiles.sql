-- V2.12 — cadastro base
create table if not exists public.user_profiles (
 user_id uuid primary key,
 display_name text not null,
 country_code text not null default 'BR',
 language_code text not null default 'pt-BR',
 role_code text not null default 'USER',
 created_at timestamptz not null default now()
);
alter table public.user_profiles enable row level security;
create policy "profile own read" on public.user_profiles for select to authenticated using(user_id=auth.uid());
create policy "profile own insert" on public.user_profiles for insert to authenticated with check(user_id=auth.uid());
