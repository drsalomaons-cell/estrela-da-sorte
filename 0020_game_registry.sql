-- V2.2 — registro unificado de jogos
create table if not exists public.game_registry (
 game_key text primary key,
 name text not null,
 category text not null check(category in ('slot','room','board','casual')),
 slot_id uuid references public.slot_catalog(id) on delete set null,
 status text not null default 'planned' check(status in ('planned','prototype','integrated','tested','disabled')),
 free_mode boolean not null default true,
 coin_mode boolean not null default false,
 metadata jsonb not null default '{}'::jsonb
);
alter table public.game_registry enable row level security;
create policy "games public read" on public.game_registry for select using (status<>'disabled');
insert into public.game_registry(game_key,name,category,slot_id,status,free_mode,coin_mode)
select s.slot_key,s.name,'slot',s.id,'planned',true,false from public.slot_catalog s
on conflict(game_key) do nothing;
