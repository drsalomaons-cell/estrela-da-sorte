-- V2.13 — preços virtuais configuráveis e regra de remuneração
-- Nenhum valor representa dinheiro real.

alter table public.gift_catalog
  add column if not exists virtual_cost_credits bigint;

update public.gift_catalog
set virtual_cost_credits = case gift_key
  when 'LUCKY_STAR' then 100
  when 'UNLUCKY_STAR' then 50
  when 'BR_INDEPENDENCE_STAR' then 250
  else null
end
where virtual_cost_credits is null;

create table if not exists public.virtual_economy_config (
  config_key text primary key,
  worker_share_bps integer not null check (worker_share_bps between 0 and 10000),
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

insert into public.virtual_economy_config(config_key,worker_share_bps)
values ('default',7000)
on conflict(config_key) do nothing;

alter table public.virtual_economy_config enable row level security;
create policy "virtual economy config authenticated read"
  on public.virtual_economy_config for select to authenticated using (active=true);

create or replace function public.transfer_virtual_gift(
  p_room_id uuid,
  p_sender_user_id uuid,
  p_recipient_member_id uuid,
  p_gift_id uuid
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance bigint;
  v_transfer_id uuid;
  v_earnings bigint;
  v_cost bigint;
  v_share_bps integer;
begin
  if auth.uid() is null or p_sender_user_id <> auth.uid() then
    raise exception 'Sender must match authenticated user';
  end if;

  select virtual_cost_credits into v_cost
  from public.gift_catalog
  where id = p_gift_id and active = true;

  if v_cost is null or v_cost <= 0 then
    raise exception 'Gift has no active virtual price';
  end if;

  perform 1 from public.room_sessions
  where id = p_room_id and status = 'live';
  if not found then
    raise exception 'Room is not live';
  end if;

  if p_recipient_member_id is not null then
    perform 1
    from public.room_participants rp
    join public.ecosystem_members em on em.id = rp.member_id
    where rp.room_id = p_room_id
      and rp.member_id = p_recipient_member_id
      and rp.left_at is null
      and em.status = 'active';
    if not found then
      raise exception 'Recipient is not an active participant in the room';
    end if;
  end if;

  select worker_share_bps into v_share_bps
  from public.virtual_economy_config
  where config_key='default' and active=true;

  if v_share_bps is null then
    raise exception 'Virtual economy configuration is inactive';
  end if;

  insert into public.user_wallets(user_id,balance)
  values (p_sender_user_id,0)
  on conflict (user_id) do nothing;

  update public.user_wallets
  set balance = balance - v_cost, updated_at = now()
  where user_id = p_sender_user_id and balance >= v_cost
  returning balance into v_balance;

  if not found then
    raise exception 'Insufficient virtual credits';
  end if;

  insert into public.gift_transfers(
    room_id,sender_user_id,recipient_member_id,gift_id,cost_credits
  ) values (p_room_id,p_sender_user_id,p_recipient_member_id,p_gift_id,v_cost)
  returning id into v_transfer_id;

  insert into public.wallet_ledger(
    user_id,event_type,amount,balance_after,reference_id
  ) values (p_sender_user_id,'gift_sent',-v_cost,v_balance,v_transfer_id);

  v_earnings := floor(v_cost * v_share_bps / 10000.0);

  if p_recipient_member_id is not null then
    insert into public.worker_earnings_ledger(
      worker_member_id,source_gift_transfer_id,credits
    ) values (p_recipient_member_id,v_transfer_id,v_earnings);
  end if;

  insert into public.gift_events(
    room_id,gift_id,sender_user_id,recipient_member_id,lucky_result
  ) values (
    p_room_id,p_gift_id,p_sender_user_id,p_recipient_member_id,null
  );

  return jsonb_build_object(
    'transfer_id',v_transfer_id,
    'sender_balance',v_balance,
    'worker_credits',v_earnings,
    'gift_cost_credits',v_cost,
    'virtual_only',true
  );
end;
$$;

revoke execute on function public.transfer_virtual_gift(uuid,uuid,uuid,uuid,bigint) from public, anon, authenticated;
grant execute on function public.transfer_virtual_gift(uuid,uuid,uuid,uuid) to authenticated;
