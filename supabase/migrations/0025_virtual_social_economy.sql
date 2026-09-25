-- V2.11 — economia social interna, atômica e auditável
-- Apenas créditos virtuais internos. Sem pagamento, saque ou conversão em dinheiro.

create table if not exists public.user_wallets (
  user_id uuid primary key,
  balance bigint not null default 0 check (balance >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.wallet_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  event_type text not null,
  amount bigint not null,
  balance_after bigint not null check (balance_after >= 0),
  reference_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.gift_transfers (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.room_sessions(id) on delete cascade,
  sender_user_id uuid not null,
  recipient_member_id uuid references public.ecosystem_members(id) on delete set null,
  gift_id uuid not null references public.gift_catalog(id),
  cost_credits bigint not null check (cost_credits > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.worker_earnings_ledger (
  id uuid primary key default gen_random_uuid(),
  worker_member_id uuid not null references public.ecosystem_members(id) on delete cascade,
  source_gift_transfer_id uuid references public.gift_transfers(id) on delete set null,
  credits bigint not null check (credits >= 0),
  status text not null default 'pending' check (status in ('pending','approved','cancelled')),
  created_at timestamptz not null default now()
);

alter table public.user_wallets enable row level security;
alter table public.wallet_ledger enable row level security;
alter table public.gift_transfers enable row level security;
alter table public.worker_earnings_ledger enable row level security;

create policy "wallet own read" on public.user_wallets
  for select to authenticated using (user_id = auth.uid());

create policy "wallet ledger own read" on public.wallet_ledger
  for select to authenticated using (user_id = auth.uid());

create policy "gift transfers sender read" on public.gift_transfers
  for select to authenticated using (sender_user_id = auth.uid());

revoke insert, update, delete on public.user_wallets from authenticated;
revoke insert, update, delete on public.wallet_ledger from authenticated;
revoke insert, update, delete on public.gift_transfers from authenticated;
revoke insert, update, delete on public.worker_earnings_ledger from authenticated;

create or replace function public.grant_virtual_credits(
  p_user_id uuid,
  p_amount bigint,
  p_event_type text default 'manual_grant',
  p_reference_id uuid default null,
  p_metadata jsonb default '{}'::jsonb
) returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance bigint;
begin
  if p_amount <= 0 then
    raise exception 'Credit amount must be positive';
  end if;

  insert into public.user_wallets(user_id, balance)
  values (p_user_id, p_amount)
  on conflict (user_id)
  do update set balance = public.user_wallets.balance + excluded.balance,
                updated_at = now()
  returning balance into v_balance;

  insert into public.wallet_ledger(user_id,event_type,amount,balance_after,reference_id,metadata)
  values (p_user_id,p_event_type,p_amount,v_balance,p_reference_id,p_metadata);

  return v_balance;
end;
$$;

create or replace function public.transfer_virtual_gift(
  p_room_id uuid,
  p_sender_user_id uuid,
  p_recipient_member_id uuid,
  p_gift_id uuid,
  p_cost_credits bigint
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance bigint;
  v_transfer_id uuid;
  v_earnings bigint;
begin
  if auth.uid() is null or p_sender_user_id <> auth.uid() then
    raise exception 'Sender must match authenticated user';
  end if;

  if p_cost_credits <= 0 then
    raise exception 'Gift cost must be positive';
  end if;

  perform 1 from public.room_sessions
  where id = p_room_id and status = 'live';
  if not found then
    raise exception 'Room is not live';
  end if;

  perform 1 from public.gift_catalog
  where id = p_gift_id and active = true;
  if not found then
    raise exception 'Gift not found or inactive';
  end if;

  insert into public.user_wallets(user_id,balance)
  values (p_sender_user_id,0)
  on conflict (user_id) do nothing;

  update public.user_wallets
  set balance = balance - p_cost_credits,
      updated_at = now()
  where user_id = p_sender_user_id
    and balance >= p_cost_credits
  returning balance into v_balance;

  if not found then
    raise exception 'Insufficient virtual credits';
  end if;

  insert into public.gift_transfers(
    room_id,sender_user_id,recipient_member_id,gift_id,cost_credits
  ) values (
    p_room_id,p_sender_user_id,p_recipient_member_id,p_gift_id,p_cost_credits
  ) returning id into v_transfer_id;

  insert into public.wallet_ledger(
    user_id,event_type,amount,balance_after,reference_id
  ) values (
    p_sender_user_id,'gift_sent',-p_cost_credits,v_balance,v_transfer_id
  );

  v_earnings := floor(p_cost_credits * 0.70);

  if p_recipient_member_id is not null then
    insert into public.worker_earnings_ledger(
      worker_member_id,source_gift_transfer_id,credits
    ) values (
      p_recipient_member_id,v_transfer_id,v_earnings
    );
  end if;

  return jsonb_build_object(
    'transfer_id',v_transfer_id,
    'sender_balance',v_balance,
    'worker_credits',v_earnings,
    'virtual_only',true
  );
end;
$$;

revoke execute on function public.grant_virtual_credits(uuid,bigint,text,uuid,jsonb) from public, anon, authenticated;
grant execute on function public.transfer_virtual_gift(uuid,uuid,uuid,uuid,bigint) to authenticated;
