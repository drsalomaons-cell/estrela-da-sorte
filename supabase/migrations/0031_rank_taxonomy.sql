-- V3.1 — taxonomy extensible de ranks sociais, sem valores inventados
create table if not exists public.rank_types (
  rank_key text primary key,
  name text not null,
  domain text not null check(domain in ('room','vip','wealth','charm','cp','task','other')),
  description text,
  active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.member_ranks (
  member_id uuid not null references public.ecosystem_members(id) on delete cascade,
  rank_key text not null references public.rank_types(rank_key) on delete cascade,
  level integer not null default 0 check(level >= 0),
  progress numeric not null default 0 check(progress >= 0),
  updated_at timestamptz not null default now(),
  primary key(member_id, rank_key)
);

alter table public.rank_types enable row level security;
alter table public.member_ranks enable row level security;

create policy "rank types active read"
on public.rank_types for select to authenticated using(active=true);

create policy "member ranks own read"
on public.member_ranks for select to authenticated
using(member_id in (select id from public.ecosystem_members where user_id=auth.uid()));
