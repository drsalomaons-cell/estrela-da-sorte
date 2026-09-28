-- V4.7 — Programa de homologação: 10 participantes x 500.000 créditos virtuais
-- Créditos exclusivamente virtuais de teste. Não representam dinheiro, depósito ou saldo sacável.

create table if not exists public.test_programs (
  id uuid primary key default gen_random_uuid(),
  program_key text unique not null,
  name text not null,
  initial_credits bigint not null check (initial_credits > 0),
  max_participants integer not null check (max_participants > 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.test_program_participants (
  id uuid primary key default gen_random_uuid(),
  program_id uuid not null references public.test_programs(id) on delete cascade,
  user_id uuid not null,
  initial_credits bigint not null,
  enrolled_at timestamptz not null default now(),
  unique(program_id,user_id)
);

insert into public.test_programs(program_key,name,initial_credits,max_participants,active)
values('TEST10_500K','Homologação Estrela da Sorte — 10 usuários',500000,10,true)
on conflict(program_key) do update
set initial_credits=excluded.initial_credits,
    max_participants=excluded.max_participants,
    active=excluded.active;

create or replace function public.enroll_test_user(p_user_id uuid)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_program public.test_programs%rowtype; v_count integer; v_balance bigint; v_before bigint; v_grant bigint; v_participant_id uuid;
begin
  perform pg_advisory_xact_lock(hashtext('estrela_test_program_TEST10_500K'));
  select * into v_program from public.test_programs where program_key='TEST10_500K' and active=true for update;
  if not found then raise exception 'Programa de teste inativo'; end if;
  if exists(select 1 from public.test_program_participants where program_id=v_program.id and user_id=p_user_id) then
    select id into v_participant_id from public.test_program_participants where program_id=v_program.id and user_id=p_user_id;
    select balance into v_balance from public.user_wallets where user_id=p_user_id;
    return jsonb_build_object('enrolled',true,'already_enrolled',true,'participant_id',v_participant_id,'balance',v_balance);
  end if;
  select count(*) into v_count from public.test_program_participants where program_id=v_program.id;
  if v_count >= v_program.max_participants then raise exception 'Programa de teste já atingiu o limite'; end if;
  insert into public.user_wallets(user_id,balance) values(p_user_id,0) on conflict(user_id) do nothing;
  select balance into v_before from public.user_wallets where user_id=p_user_id for update;
  v_grant:=greatest(v_program.initial_credits-v_before,0);
  update public.user_wallets set balance=balance+v_grant,updated_at=now() where user_id=p_user_id returning balance into v_balance;
  insert into public.test_program_participants(program_id,user_id,initial_credits) values(v_program.id,p_user_id,v_program.initial_credits) returning id into v_participant_id;
  if v_grant>0 then
    insert into public.wallet_ledger(user_id,event_type,amount,balance_after,metadata)
    values(p_user_id,'test_program_initial_credits',v_grant,v_balance,jsonb_build_object('program_key',v_program.program_key,'target_balance',v_program.initial_credits,'virtual_only',true));
  end if;
  return jsonb_build_object('enrolled',true,'participant_id',v_participant_id,'balance',v_balance,'credits_granted',v_grant);
end; $$;

create or replace function public.auto_enroll_test_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  begin perform public.enroll_test_user(new.id); exception when others then null; end;
  return new;
end; $$;

drop trigger if exists on_auth_user_test_program on auth.users;
create trigger on_auth_user_test_program after insert on auth.users for each row execute function public.auto_enroll_test_user();

create or replace function public.admin_grant_test_credits(p_user_id uuid,p_amount bigint,p_reason text default 'Reposição de homologação')
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_role text; v_balance bigint;
begin
  v_role:=coalesce(public.my_ecosystem_role(),'');
  if v_role not in ('SUPER_ADM','ADM_CENTRAL','ADM_REGIONAL','ADM_OFICIAL','BD') then raise exception 'Sem permissão'; end if;
  if p_amount <= 0 or p_amount > 10000000 then raise exception 'Quantidade inválida'; end if;
  insert into public.user_wallets(user_id,balance) values(p_user_id,0) on conflict(user_id) do nothing;
  update public.user_wallets set balance=balance+p_amount,updated_at=now() where user_id=p_user_id returning balance into v_balance;
  insert into public.wallet_ledger(user_id,event_type,amount,balance_after,metadata)
  values(p_user_id,'test_program_admin_replenishment',p_amount,v_balance,jsonb_build_object('reason',p_reason,'granted_by',auth.uid(),'virtual_only',true));
  return jsonb_build_object('success',true,'credits_granted',p_amount,'balance',v_balance);
end; $$;

create or replace function public.test_program_status()
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_role text; v_program public.test_programs%rowtype; v_count integer;
begin
  v_role:=coalesce(public.my_ecosystem_role(),'');
  if v_role not in ('SUPER_ADM','ADM_CENTRAL','ADM_REGIONAL','ADM_OFICIAL','BD') then raise exception 'Sem permissão'; end if;
  select * into v_program from public.test_programs where program_key='TEST10_500K';
  select count(*) into v_count from public.test_program_participants where program_id=v_program.id;
  return jsonb_build_object('program_key',v_program.program_key,'initial_credits',v_program.initial_credits,'max_participants',v_program.max_participants,'participants',v_count,'remaining_slots',greatest(v_program.max_participants-v_count,0),'active',v_program.active);
end; $$;

revoke execute on function public.enroll_test_user(uuid) from public,anon,authenticated;
revoke execute on function public.admin_grant_test_credits(uuid,bigint,text) from public,anon,authenticated;
revoke execute on function public.test_program_status() from public,anon,authenticated;
grant execute on function public.admin_grant_test_credits(uuid,bigint,text) to authenticated;
grant execute on function public.test_program_status() to authenticated;
