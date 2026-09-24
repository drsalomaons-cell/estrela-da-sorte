-- V1.9 — ledger econômico somente para simulação
create table if not exists public.economy_ledger_simulation (
 id uuid primary key default gen_random_uuid(),
 event_type text not null,
 user_id uuid,
 role_code text references public.ecosystem_roles(code),
 amount numeric(18,2) not null default 0,
 currency text not null default 'COIN',
 source text not null,
 metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
create index if not exists economy_ledger_sim_time_idx on public.economy_ledger_simulation(created_at);
alter table public.economy_ledger_simulation enable row level security;
create policy "economy simulation admin read" on public.economy_ledger_simulation for select to authenticated
using (public.my_ecosystem_role() in ('SUPER_ADM','ADM_OFICIAL','BD'));
