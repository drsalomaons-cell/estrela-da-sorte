-- V3.3 — preencher o registry com os 20 slots já catalogados.
-- Isto cadastra o catálogo e mantém os jogos como planned; não declara motores executáveis.
insert into public.game_registry(game_key,name,category,slot_id,status,free_mode,coin_mode,monetization_mode)
select
  sc.slot_key,
  sc.name,
  'catalog',
  sc.id,
  'planned',
  true,
  false,
  'none'
from public.slot_catalog sc
where sc.slot_key like 'STAR_%'
  and not exists (
    select 1 from public.game_registry gr where gr.game_key=sc.slot_key
  );
