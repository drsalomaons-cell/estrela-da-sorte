-- V0.8 — cadeia de cargos e regras de comissão (simulação)
create table if not exists public.ecosystem_roles (
 id bigserial primary key,
 code text unique not null,
 name text not null,
 parent_code text,
 entry_requirements jsonb not null default '{}'::jsonb,
 active boolean not null default true
);
insert into public.ecosystem_roles(code,name,parent_code,entry_requirements) values
('SUPER_ADM','Super ADM',null,'{"creates_official_adms":true,"requires_approval":true}'),
('ADM_OFICIAL','ADM Oficial','SUPER_ADM','{"requires_bd_validation":true,"min_active_agencies":3}'),
('BD','BD','ADM_OFICIAL','{"manages_agencies":true}'),
('AGENCIA','Agência','BD','{"recruits_hosts":true}'),
('HOST','Host','AGENCIA','{"room_production":true}')
on conflict(code) do nothing;

create or replace function public.simulate_role_chain(p_monthly_production numeric)
returns jsonb language plpgsql security definer set search_path=public as $$
begin
 if p_monthly_production<0 then raise exception 'Invalid production'; end if;
 return jsonb_build_object(
  'production',round(p_monthly_production,2),
  'chain',jsonb_build_array(
   jsonb_build_object('role','SUPER_ADM','pool_pct',2,'reference_amount',round(p_monthly_production*.02,2)),
   jsonb_build_object('role','ADM_OFICIAL','pool_pct',8,'reference_amount',round(p_monthly_production*.08,2)),
   jsonb_build_object('role','BD','pool_pct',4,'reference_amount',round(p_monthly_production*.04,2)),
   jsonb_build_object('role','AGENCIA','pool_pct',9,'reference_amount',round(p_monthly_production*.09,2)),
   jsonb_build_object('role','HOST','pool_pct',30,'reference_amount',round(p_monthly_production*.30,2))
  ),
  'note','Valores são pools de simulação; não são promessa individual e não liberam saque.'
 );
end; $$;

-- V0.9 — guardrails de sustentabilidade
create table if not exists public.economy_guardrails (
 id bigserial primary key,
 name text unique not null,
 rule jsonb not null,
 active boolean not null default true
);
insert into public.economy_guardrails(name,rule) values
('TOTAL_MUST_BE_100','{"max_total_pct":100,"min_total_pct":100}'),
('ADM_POOL_CAP','{"adm_reference_cannot_exceed_pool":true}'),
('NO_REAL_PAYOUT','{"simulation_only":true}'),
('RESERVE_REQUIRED','{"reserve_min_pct":1}'),
('PLATFORM_MARGIN_REQUIRED','{"platform_min_pct":1}')
on conflict(name) do nothing;

create or replace function public.validate_economy_guardrails(p_policy_name text)
returns jsonb language plpgsql security definer set search_path=public as $$
declare p public.economy_policies%rowtype; total numeric;
begin
 select * into p from public.economy_policies where name=p_policy_name limit 1;
 if not found then raise exception 'Policy not found'; end if;
 total:=round(p.platform_pct+p.host_pct+p.agency_pct+p.adm_official_pct+p.bd_pct+p.super_adm_pct+p.events_pct+p.reserve_pct,2);
 return jsonb_build_object(
  'policy',p.name,
  'total_is_100',total=100,
  'platform_margin_ok',p.platform_pct>=1,
  'reserve_ok',p.reserve_pct>=1,
  'simulation_only',true,
  'valid',total=100 and p.platform_pct>=1 and p.reserve_pct>=1
 );
end; $$;