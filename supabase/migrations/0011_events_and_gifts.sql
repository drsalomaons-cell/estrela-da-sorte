-- V1.3 — calendário regional e catálogo de presentes
create table if not exists public.ecosystem_events (
 id uuid primary key default gen_random_uuid(),
 event_key text unique not null,
 name text not null,
 region_code text not null,
 event_date date not null,
 recurring_month smallint,
 recurring_day smallint,
 active boolean not null default true,
 metadata jsonb not null default '{}'::jsonb
);
create table if not exists public.gift_catalog (
 id uuid primary key default gen_random_uuid(),
 gift_key text unique not null,
 name text not null,
 category text not null check (category in ('normal','afortunado','desafortunado')),
 rarity text not null default 'common' check (rarity in ('common','rare','epic','legendary')),
 event_key text references public.ecosystem_events(event_key) on delete set null,
 active boolean not null default true,
 metadata jsonb not null default '{}'::jsonb
);
create table if not exists public.gift_rules (
 id uuid primary key default gen_random_uuid(),
 gift_id uuid not null references public.gift_catalog(id) on delete cascade,
 lucky boolean not null default false,
 animation_key text,
 drop_weight integer not null default 100 check (drop_weight>0),
 enabled boolean not null default true
);
alter table public.ecosystem_events enable row level security;
alter table public.gift_catalog enable row level security;
alter table public.gift_rules enable row level security;
create policy "events public read" on public.ecosystem_events for select using (active=true);
create policy "gifts public read" on public.gift_catalog for select using (active=true);
create policy "gift rules public read" on public.gift_rules for select using (enabled=true);

insert into public.ecosystem_events(event_key,name,region_code,event_date,recurring_month,recurring_day) values
('BR_INDEPENDENCE','Independência do Brasil','BR','2026-09-07',9,7),
('BR_NEW_YEAR','Ano Novo','BR','2027-01-01',1,1),
('LATAM_NEW_YEAR','Ano Novo LATAM','LATAM','2027-01-01',1,1),
('GLOBAL_VALENTINE','Dia dos Namorados / Valentine','GLOBAL','2027-02-14',2,14),
('BR_CHILDREN','Dia das Crianças','BR','2026-10-12',10,12)
on conflict(event_key) do nothing;

insert into public.gift_catalog(gift_key,name,category,rarity,event_key,metadata) values
('LUCKY_STAR','Presente da Sorte','afortunado','rare',null,'{"theme":"star","limited":false}'),
('UNLUCKY_STAR','Presente Desafortunado','desafortunado','common',null,'{"theme":"cosmic","limited":false}'),
('BR_INDEPENDENCE_STAR','Estrela 7 de Setembro','afortunado','epic','BR_INDEPENDENCE','{"theme":"brasil","limited":true}')
on conflict(gift_key) do nothing;

insert into public.gift_rules(gift_id,lucky,animation_key,drop_weight)
select id,category='afortunado',case when category='afortunado' then 'star-burst' else 'cosmic-fall' end,
case when category='afortunado' then 15 else 85 end
from public.gift_catalog
where gift_key in ('LUCKY_STAR','UNLUCKY_STAR','BR_INDEPENDENCE_STAR')
and not exists (select 1 from public.gift_rules gr where gr.gift_id=gift_catalog.id);
