-- V3.8 — cadastro funcional, membro USER automático e sala de teste
-- Não cria pagamentos reais. Apenas habilita o fluxo social básico após cadastro.

insert into public.ecosystem_roles(code,name,parent_code,entry_requirements)
values ('USER','Usuário',null,'{"room_access":true,"free_games":true}')
on conflict(code) do nothing;

create or replace function public.ensure_user_social_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
begin
  v_name := coalesce(
    nullif(new.raw_user_meta_data->>'display_name',''),
    nullif(new.raw_user_meta_data->>'name',''),
    split_part(coalesce(new.email,''),'@',1),
    'Usuário'
  );

  insert into public.user_profiles(user_id,display_name)
  values(new.id,v_name)
  on conflict(user_id) do nothing;

  insert into public.ecosystem_members(
    user_id,role_code,display_name,status,metadata
  )
  values(
    new.id,'USER',v_name,'active','{"source":"auth_signup","auto_created":true}'::jsonb
  )
  on conflict do nothing;

  insert into public.user_wallets(user_id,balance)
  values(new.id,1000)
  on conflict(user_id) do nothing;

  insert into public.wallet_ledger(
    user_id,event_type,amount,balance_after,metadata
  )
  select new.id,'welcome_credits',1000,1000,'{"source":"auth_signup"}'::jsonb
  where not exists(
    select 1 from public.wallet_ledger
    where user_id=new.id and event_type='welcome_credits'
  );

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_estreladasorte on auth.users;
create trigger on_auth_user_created_estreladasorte
after insert on auth.users
for each row execute function public.ensure_user_social_profile();

insert into public.user_profiles(user_id,display_name)
select au.id,
       coalesce(
         nullif(au.raw_user_meta_data->>'display_name',''),
         nullif(au.raw_user_meta_data->>'name',''),
         split_part(coalesce(au.email,''),'@',1),
         'Usuário'
       )
from auth.users au
where not exists(select 1 from public.user_profiles up where up.user_id=au.id);

insert into public.ecosystem_members(user_id,role_code,display_name,status,metadata)
select up.user_id,'USER',up.display_name,'active','{"source":"migration_backfill"}'::jsonb
from public.user_profiles up
where not exists(
  select 1 from public.ecosystem_members em
  where em.user_id=up.user_id
);

insert into public.user_wallets(user_id,balance)
select up.user_id,1000
from public.user_profiles up
where not exists(select 1 from public.user_wallets w where w.user_id=up.user_id);

insert into public.room_sessions(
  room_key,title,status,seats,video_enabled,chat_enabled
)
select 'sala-principal','Estrela da Sorte — Sala Principal','live',30,true,true
where not exists(
  select 1 from public.room_sessions where room_key='sala-principal'
);

alter table public.user_profiles enable row level security;
drop policy if exists "profile own update" on public.user_profiles;
create policy "profile own update"
  on public.user_profiles for update to authenticated
  using(user_id=auth.uid())
  with check(user_id=auth.uid());

alter table public.ecosystem_members enable row level security;
drop policy if exists "ecosystem member own read" on public.ecosystem_members;
create policy "ecosystem member own read"
  on public.ecosystem_members for select to authenticated
  using(user_id=auth.uid() or public.my_ecosystem_role() in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));

alter table public.room_sessions enable row level security;
drop policy if exists "room sessions authenticated read" on public.room_sessions;
create policy "room sessions authenticated read"
  on public.room_sessions for select to authenticated using(true);
