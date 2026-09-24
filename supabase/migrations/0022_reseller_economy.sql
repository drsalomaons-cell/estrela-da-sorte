-- V2.10 — Revenda de moedas
-- Estrutura preparada; não libera dinheiro real por si só.
create table if not exists public.reseller_profiles (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null,
 status text not null default 'pending' check(status in ('pending','active','suspended','rejected')),
 display_name text not null,
 region_code text,
 currency_code text not null default 'BRL',
 price_list_version text not null default 'V1',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create unique index if not exists reseller_profiles_user_uidx on public.reseller_profiles(user_id);

create table if not exists public.reseller_price_lists (
 id uuid primary key default gen_random_uuid(),
 reseller_id uuid not null references public.reseller_profiles(id) on delete cascade,
 coin_quantity bigint not null check(coin_quantity > 0),
 sale_price numeric(14,2) not null check(sale_price >= 0),
 currency_code text not null default 'BRL',
 active boolean not null default true,
 created_at timestamptz not null default now()
);

create table if not exists public.reseller_orders (
 id uuid primary key default gen_random_uuid(),
 reseller_id uuid not null references public.reseller_profiles(id),
 buyer_user_id uuid,
 coin_quantity bigint not null check(coin_quantity > 0),
 amount numeric(14,2) not null check(amount >= 0),
 currency_code text not null,
 status text not null default 'pending' check(status in ('pending','paid','fulfilled','cancelled','refunded')),
 payment_reference text,
 created_at timestamptz not null default now(),
 fulfilled_at timestamptz
);

create table if not exists public.reseller_ledger_simulation (
 id uuid primary key default gen_random_uuid(),
 reseller_id uuid not null references public.reseller_profiles(id),
 event_type text not null,
 coin_quantity bigint not null default 0,
 gross_amount numeric(14,2) not null default 0,
 platform_fee numeric(14,2) not null default 0,
 reseller_margin numeric(14,2) not null default 0,
 currency_code text not null default 'BRL',
 simulation_only boolean not null default true,
 created_at timestamptz not null default now()
);

alter table public.reseller_profiles enable row level security;
alter table public.reseller_price_lists enable row level security;
alter table public.reseller_orders enable row level security;
alter table public.reseller_ledger_simulation enable row level security;

-- A ativação real deve depender de autorização administrativa no backend.
-- Nenhuma política de saque/pagamento real é criada nesta migration.
