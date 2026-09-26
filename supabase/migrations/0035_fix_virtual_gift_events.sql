-- V2.16 — correção de ordem/consistência da economia virtual
-- Somente créditos virtuais internos. Sem pagamento, saque ou conversão em dinheiro.
-- 0027 usa public.gift_events; esta migração garante que a tabela exista antes
-- da função transfer_virtual_gift ser recriada em ambientes novos.

create table if not exists public.gift_events (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.room_sessions(id) on delete cascade,
  gift_id uuid not null references public.gift_catalog(id),
  sender_user_id uuid not null,
  recipient_member_id uuid references public.ecosystem_members(id) on delete set null,
  lucky_result text,
  created_at timestamptz not null default now()
);

create index if not exists gift_events_room_id_idx
  on public.gift_events(room_id);

create index if not exists gift_events_created_at_idx
  on public.gift_events(created_at desc);

alter table public.gift_events enable row level security;

drop policy if exists "gift events authenticated read" on public.gift_events;
create policy "gift events authenticated read"
  on public.gift_events
  for select to authenticated
  using (true);

revoke insert, update, delete on public.gift_events from authenticated;
