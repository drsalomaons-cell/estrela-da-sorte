-- V2.1 — catálogo inicial de 20 slots para integração
create table if not exists public.slot_catalog (
 id uuid primary key default gen_random_uuid(),
 slot_key text unique not null,
 name text not null,
 provider_source text not null,
 license_note text not null,
 status text not null default 'candidate' check(status in ('candidate','integrated','disabled')),
 demo_only boolean not null default true,
 metadata jsonb not null default '{}'::jsonb
);
alter table public.slot_catalog enable row level security;
create policy "slot catalog public read" on public.slot_catalog for select using (status<>'disabled');
insert into public.slot_catalog(slot_key,name,provider_source,license_note) values
('STAR_01','Estrela Cósmica','original','motor interno; arte própria'),
('STAR_02','Órbita Dourada','original','motor interno; arte própria'),
('STAR_03','Lua Violeta','original','motor interno; arte própria'),
('STAR_04','Nebulosa','original','motor interno; arte própria'),
('STAR_05','Supernova','original','motor interno; arte própria'),
('STAR_06','Cometa','original','motor interno; arte própria'),
('STAR_07','Galáxia','original','motor interno; arte própria'),
('STAR_08','Buraco Negro','original','motor interno; arte própria'),
('STAR_09','Constelação','original','motor interno; arte própria'),
('STAR_10','Tesouro Estelar','original','motor interno; arte própria'),
('STAR_11','Zeus Cósmico','original','nome interno; validar marca antes de publicar'),
('STAR_12','Cleópatra Cósmica','original','nome interno; validar marca antes de publicar'),
('STAR_13','Gelo Estelar','original','motor interno; arte própria'),
('STAR_14','Foguete','original','motor interno; arte própria'),
('STAR_15','Ovo da Sorte','original','motor interno; arte própria'),
('STAR_16','Trem Cósmico','original','motor interno; arte própria'),
('STAR_17','Caçador Estelar','original','nome interno; validar marca antes de publicar'),
('STAR_18','Creme Cósmico','original','nome interno; validar marca antes de publicar'),
('STAR_19','Yumi Estelar','original','nome interno; validar marca antes de publicar'),
('STAR_20','Feijão Estelar','original','motor interno; arte própria')
on conflict(slot_key) do nothing;
