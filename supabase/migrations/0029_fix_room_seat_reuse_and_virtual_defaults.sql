-- V2.14 — corrigir reutilização de cadeiras e remover parâmetros econômicos inventados
-- A capacidade escolhida pela sala continua sendo a autoridade; 30 é apenas o teto.

alter table public.room_participants
  drop constraint if exists room_participants_room_id_seat_no_key;

create unique index if not exists room_participants_active_seat_uq
  on public.room_participants(room_id, seat_no)
  where left_at is null;

-- Preços e percentuais devem vir de configuração/documentação aprovada.
-- Não manter valores de exemplo como regra operacional.
update public.gift_catalog
set virtual_cost_credits = null
where gift_key in ('LUCKY_STAR','UNLUCKY_STAR','BR_INDEPENDENCE_STAR');

delete from public.virtual_economy_config
where config_key = 'default';
