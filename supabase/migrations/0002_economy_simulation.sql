-- Estrela da Sorte — Economia V0.2
-- Status: estrutura técnica implantada para simulação.
-- IMPORTANTE: percentuais são parâmetros de simulação e NÃO liberam saque real.

create table if not exists public.economy_policies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  status text not null default 'simulation' check (status in ('simulation','approved','active','archived')),
  platform_pct numeric(5,2) not null check (platform_pct >= 0 and platform_pct <= 100),
  host_pct numeric(5,2) not null check (host_pct >= 0 and host_pct <= 100),
  agency_pct numeric(5,2) not null check (agency_pct >= 0 and agency_pct <= 100),
  adm_official_pct numeric(5,2) not null check (adm_official_pct >= 0 and adm_official_pct <= 100),
  bd_pct numeric(5,2) not null check (bd_pct >= 0 and bd_pct <= 100),
  super_adm_pct numeric(5,2) not null check (super_adm_pct >= 0 and super_adm_pct <= 100),
  events_pct numeric(5,2) not null check (events_pct >= 0 and events_pct <= 100),
  reserve_pct numeric(5,2) not null check (reserve_pct >= 0 and reserve_pct <= 100),
  created_at timestamptz not null default now(),
  notes text
);

create table if not exists public.adm_official_levels (
  id uuid primary key default gen_random_uuid(),
  level_no integer not null unique check (level_no between 1 and 4),
  name text not null,
  commission_pct numeric(5,2) not null check (commission_pct >= 0 and commission_pct <= 100),
  min_active_agencies integer not null default 0 check (min_active_agencies >= 0),
  min_monthly_production numeric(18,2) not null default 0 check (min_monthly_production >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.economy_simulations (
  id uuid primary key default gen_random_uuid(),
  policy_id uuid not null references public.economy_policies(id),
  base_amount numeric(18,2) not null check (base_amount >= 0),
  result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

insert into public.economy_policies
(name,status,platform_pct,host_pct,agency_pct,adm_official_pct,bd_pct,super_adm_pct,events_pct,reserve_pct,notes)
select 'V0.2 — Base 45/55','simulation',45,30,9,8,4,2,1,1,
'Modelo de referência para testes. Não é regra oficial e não permite saque real.'
where not exists (select 1 from public.economy_policies where name='V0.2 — Base 45/55');

insert into public.adm_official_levels(level_no,name,commission_pct,min_active_agencies,min_monthly_production)
select * from (values
  (1,'Desenvolvimento',3.00,3,0.00),
  (2,'Expansão',5.00,6,5000.00),
  (3,'Consolidação',7.00,10,15000.00),
  (4,'Liderança',8.00,20,30000.00)
) v(level_no,name,commission_pct,min_active_agencies,min_monthly_production)
where not exists (select 1 from public.adm_official_levels);

alter table public.economy_policies enable row level security;
alter table public.adm_official_levels enable row level security;
alter table public.economy_simulations enable row level security;

create policy "economy policies public read" on public.economy_policies for select using (true);
create policy "adm levels public read" on public.adm_official_levels for select using (active = true);
create policy "simulations admin read" on public.economy_simulations for select using (
  exists(select 1 from public.profiles p where p.id=auth.uid() and p.role in ('super_adm','adm_central','adm_oficial','adm_regional','bd'))
);

-- Regra de segurança: nenhuma porcentagem aqui autoriza saque.
-- A ativação econômica definitiva exigirá aprovação explícita e uma migration posterior.
