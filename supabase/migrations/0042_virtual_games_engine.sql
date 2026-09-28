-- V4.2 — motor de jogos virtuais para teste: 20 slots + 20 jogos de sala
-- Não representa dinheiro real, saque ou conversão financeira.

create table if not exists public.game_rounds (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null, room_id uuid references public.room_sessions(id) on delete set null,
  game_key text not null references public.game_registry(game_key),
  mode text not null check(mode in ('free','virtual')),
  wager bigint not null default 0 check(wager>=0),
  payout bigint not null default 0 check(payout>=0),
  result jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
alter table public.game_rounds enable row level security;
drop policy if exists "game rounds own read" on public.game_rounds;
create policy "game rounds own read" on public.game_rounds for select to authenticated using(user_id=auth.uid());
drop policy if exists "game rounds admin read" on public.game_rounds;
create policy "game rounds admin read" on public.game_rounds for select to authenticated using(coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
create index if not exists game_rounds_user_time_idx on public.game_rounds(user_id,created_at desc);
create index if not exists game_rounds_game_time_idx on public.game_rounds(game_key,created_at desc);

update public.game_registry set status='integrated',free_mode=true,coin_mode=true,monetization_mode='virtual' where slot_id is not null;
update public.game_registry set status='integrated',free_mode=true,coin_mode=true,monetization_mode='virtual' where slot_id is null and game_key not like 'STAR_%' and status<>'disabled';
update public.slot_catalog set status='integrated',demo_only=false where status<>'disabled';

create or replace function public.play_virtual_slot(p_game_key text,p_wager bigint,p_room_id uuid default null) returns jsonb language plpgsql security definer set search_path=public as $$
declare v_user uuid:=auth.uid(); v_after_bet bigint; v_after_win bigint; v_round uuid; v_a int; v_b int; v_c int; v_multiplier int:=0; v_payout bigint:=0;
begin
 if v_user is null then raise exception 'Login necessário'; end if;
 if p_wager not in(10,50,100,500,1000,5000) then raise exception 'Aposta virtual inválida'; end if;
 perform 1 from public.game_registry where game_key=p_game_key and slot_id is not null and status in('integrated','tested') and coin_mode=true and monetization_mode='virtual';
 if not found then raise exception 'Slot não está habilitado para teste'; end if;
 if p_room_id is not null then perform 1 from public.room_sessions where id=p_room_id and status='live'; if not found then raise exception 'Sala não está ao vivo'; end if; end if;
 insert into public.user_wallets(user_id,balance) values(v_user,0) on conflict(user_id) do nothing;
 update public.user_wallets set balance=balance-p_wager,updated_at=now() where user_id=v_user and balance>=p_wager returning balance into v_after_bet;
 if not found then raise exception 'Saldo virtual insuficiente'; end if;
 v_a=floor(random()*8)::int+1; v_b=floor(random()*8)::int+1; v_c=floor(random()*8)::int+1;
 if v_a=v_b and v_b=v_c then if v_a=8 then v_multiplier=50; else v_multiplier=12; end if; elsif v_a=v_b or v_b=v_c or v_a=v_c then v_multiplier=2; end if;
 v_payout=p_wager*v_multiplier;
 if v_payout>0 then update public.user_wallets set balance=balance+v_payout,updated_at=now() where user_id=v_user returning balance into v_after_win; else v_after_win=v_after_bet; end if;
 insert into public.wallet_ledger(user_id,event_type,amount,balance_after,metadata) values(v_user,'game_wager',-p_wager,v_after_bet,jsonb_build_object('game_key',p_game_key,'virtual_only',true));
 if v_payout>0 then insert into public.wallet_ledger(user_id,event_type,amount,balance_after,metadata) values(v_user,'game_payout',v_payout,v_after_win,jsonb_build_object('game_key',p_game_key,'multiplier',v_multiplier,'virtual_only',true)); end if;
 insert into public.game_rounds(user_id,room_id,game_key,mode,wager,payout,result) values(v_user,p_room_id,p_game_key,'virtual',p_wager,v_payout,jsonb_build_object('reels',jsonb_build_array(v_a,v_b,v_c),'multiplier',v_multiplier,'virtual_only',true)) returning id into v_round;
 return jsonb_build_object('round_id',v_round,'game_key',p_game_key,'mode','virtual','wager',p_wager,'payout',v_payout,'balance',v_after_win,'result',jsonb_build_object('reels',jsonb_build_array(v_a,v_b,v_c),'multiplier',v_multiplier),'virtual_only',true);
end; $$;

create or replace function public.play_virtual_room_game(p_game_key text,p_wager bigint,p_success boolean,p_room_id uuid default null) returns jsonb language plpgsql security definer set search_path=public as $$
declare v_user uuid:=auth.uid(); v_after_bet bigint; v_after_win bigint; v_payout bigint:=case when p_success then p_wager*2 else 0 end; v_round uuid;
begin
 if v_user is null then raise exception 'Login necessário'; end if;
 if p_wager not in(10,50,100,500,1000,5000) then raise exception 'Aposta virtual inválida'; end if;
 perform 1 from public.game_registry where game_key=p_game_key and slot_id is null and status in('integrated','tested') and coin_mode=true and monetization_mode='virtual';
 if not found then raise exception 'Jogo de sala não está habilitado'; end if;
 if p_room_id is not null then perform 1 from public.room_sessions where id=p_room_id and status='live'; if not found then raise exception 'Sala não está ao vivo'; end if; end if;
 insert into public.user_wallets(user_id,balance) values(v_user,0) on conflict(user_id) do nothing;
 update public.user_wallets set balance=balance-p_wager,updated_at=now() where user_id=v_user and balance>=p_wager returning balance into v_after_bet;
 if not found then raise exception 'Saldo virtual insuficiente'; end if;
 if v_payout>0 then update public.user_wallets set balance=balance+v_payout,updated_at=now() where user_id=v_user returning balance into v_after_win; else v_after_win=v_after_bet; end if;
 insert into public.wallet_ledger(user_id,event_type,amount,balance_after,metadata) values(v_user,'room_game_wager',-p_wager,v_after_bet,jsonb_build_object('game_key',p_game_key,'virtual_only',true,'success',p_success));
 if v_payout>0 then insert into public.wallet_ledger(user_id,event_type,amount,balance_after,metadata) values(v_user,'room_game_payout',v_payout,v_after_win,jsonb_build_object('game_key',p_game_key,'virtual_only',true,'success',p_success)); end if;
 insert into public.game_rounds(user_id,room_id,game_key,mode,wager,payout,result) values(v_user,p_room_id,p_game_key,'virtual',p_wager,v_payout,jsonb_build_object('success',p_success,'multiplier',case when p_success then 2 else 0 end,'virtual_only',true)) returning id into v_round;
 return jsonb_build_object('round_id',v_round,'game_key',p_game_key,'mode','virtual','wager',p_wager,'payout',v_payout,'balance',v_after_win,'result',jsonb_build_object('success',p_success,'multiplier',case when p_success then 2 else 0 end),'virtual_only',true);
end; $$;
revoke execute on function public.play_virtual_slot(text,bigint,uuid) from public,anon;
revoke execute on function public.play_virtual_room_game(text,bigint,boolean,uuid) from public,anon;
grant execute on function public.play_virtual_slot(text,bigint,uuid) to authenticated;
grant execute on function public.play_virtual_room_game(text,bigint,boolean,uuid) to authenticated;