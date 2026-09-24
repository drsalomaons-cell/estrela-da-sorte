-- V2.10 — revenda de moedas
create table if not exists public.reseller_profiles (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null unique,
 enabled boolean not null default false,
 status text not null default 'pending' check(status in ('pending','approved','suspended','rejected')),
 display_name text not null,
 created_at timestamptz not null default now(),
 approved_at timestamptz
);
create table if not exists public.reseller_packages (
 id uuid primary key default gen_random_uuid(),
 package_key text unique not null,
 coin_amount bigint not null check(coin_amount>0),
 base_price numeric(18,2) not null check(base_price>=0),
 reseller_price numeric(18,2) not null check(reseller_price>=0),
 active boolean not null default true
);
create table if not exists public.reseller_orders (
 id uuid primary key default gen_random_uuid(),
 reseller_id uuid not null references public.reseller_profiles(id),
 package_id uuid not null references public.reseller_packages(id),
 status text not null default 'pending' check(status in ('pending','paid','fulfilled','cancelled')),
 created_at timestamptz not null default now()
);
alter table public.reseller_profiles enable row level security;
alter table public.reseller_packages enable row level security;
alter table public.reseller_orders enable row level security;
create policy "reseller own profile" on public.reseller_profiles for select to authenticated using (user_id=auth.uid());
create policy "reseller active packages" on public.reseller_packages for select to authenticated using (active=true);
create policy "reseller own orders" on public.reseller_orders for select to authenticated using (reseller_id in (select id from public.reseller_profiles where user_id=auth.uid()));
