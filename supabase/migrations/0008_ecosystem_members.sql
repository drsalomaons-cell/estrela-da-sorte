-- V1.0 — membros reais da cadeia do ecossistema
create table if not exists public.ecosystem_members (
 id uuid primary key default gen_random_uuid(),
 user_id uuid,
 role_code text not null references public.ecosystem_roles(code),
 parent_member_id uuid references public.ecosystem_members(id) on delete set null,
 display_name text not null,
 status text not null default 'pending' check (status in ('pending','active','suspended','rejected')),
 agency_name text,
 region_code text,
 metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists ecosystem_members_user_idx on public.ecosystem_members(user_id);
create index if not exists ecosystem_members_parent_idx on public.ecosystem_members(parent_member_id);
create index if not exists ecosystem_members_role_idx on public.ecosystem_members(role_code,status);
alter table public.ecosystem_members enable row level security;
-- A função my_ecosystem_role é criada na migration V1.1; a política é recriada nela.
drop policy if exists "ecosystem members scoped read" on public.ecosystem_members;
using (user_id=auth.uid() or public.my_ecosystem_role() in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
