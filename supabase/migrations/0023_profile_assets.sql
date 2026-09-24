-- V2.11 — perfil, molduras e carro de entrada
create table if not exists public.profile_assets (
 id uuid primary key default gen_random_uuid(),
 asset_key text unique not null,
 asset_type text not null check(asset_type in ('avatar_frame','entry_car','badge','title')),
 asset_name text not null,
 asset_url text,
 active boolean not null default true
);
insert into public.profile_assets(asset_key,asset_type,asset_name) values
('frame_star_gold','avatar_frame','Moldura Estrela Dourada'),
('frame_cosmic_violet','avatar_frame','Moldura Cósmica Violeta'),
('entry_car_star','entry_car','Carro Estrela'),
('badge_founder','badge','Distintivo Fundador'),
('title_super_adm','title','Título Super ADM')
on conflict(asset_key) do nothing;
alter table public.profile_assets enable row level security;
create policy "profile assets active read" on public.profile_assets for select to authenticated using(active=true);
