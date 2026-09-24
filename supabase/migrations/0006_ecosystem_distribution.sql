-- V0.6/V0.7 — Distribuição do ecossistema e controles de sustentabilidade
-- SIMULAÇÃO: não cria saldo real, saque ou pagamento.
create or replace function public.simulate_ecosystem_distribution(
  p_policy_name text,
  p_monthly_production numeric,
  p_adm_level text default 'Liderança'
) returns jsonb
language plpgsql security definer set search_path=public as $$
declare p public.economy_policies%rowtype; pool numeric; adm_share numeric; result jsonb;
begin
 if p_monthly_production < 0 then raise exception 'Invalid production'; end if;
 select * into p from public.economy_policies where name=p_policy_name and status='simulation' limit 1;
 if not found then raise exception 'Policy not found'; end if;
 if round(p.platform_pct+p.host_pct+p.agency_pct+p.adm_official_pct+p.bd_pct+p.super_adm_pct+p.events_pct+p.reserve_pct,2)<>100 then raise exception 'Policy must total 100%%'; end if;
 pool:=round(p_monthly_production*p.adm_official_pct/100,2);
 adm_share:=case p_adm_level when 'Desenvolvimento' then 0.03 when 'Expansão' then 0.05 when 'Consolidação' then 0.07 when 'Liderança' then 0.08 else 0 end;
 result:=jsonb_build_object(
  'policy',p.name,'production',round(p_monthly_production,2),
  'platform',round(p_monthly_production*p.platform_pct/100,2),
  'host',round(p_monthly_production*p.host_pct/100,2),
  'agency',round(p_monthly_production*p.agency_pct/100,2),
  'adm_pool',pool,
  'adm_level',p_adm_level,
  'adm_level_rate_reference',adm_share,
  'adm_level_reference_amount',round(p_monthly_production*adm_share/100,2),
  'bd',round(p_monthly_production*p.bd_pct/100,2),
  'super_adm',round(p_monthly_production*p.super_adm_pct/100,2),
  'events',round(p_monthly_production*p.events_pct/100,2),
  'reserve',round(p_monthly_production*p.reserve_pct/100,2),
  'unallocated_adm_pool_after_reference',greatest(0,round(pool-p_monthly_production*adm_share/100,2)),
  'warning','Reference commission is bounded by the ADM pool; final multi-ADM allocation requires explicit active members.'
 );
 insert into public.economy_simulations(policy_id,base_amount,result) values(p.id,p_monthly_production,result);
 return result;
end; $$;

create or replace function public.validate_economy_policy(p_policy_name text)
returns jsonb language plpgsql security definer set search_path=public as $$
declare p public.economy_policies%rowtype; total numeric;
begin
 select * into p from public.economy_policies where name=p_policy_name limit 1;
 if not found then raise exception 'Policy not found'; end if;
 total:=round(p.platform_pct+p.host_pct+p.agency_pct+p.adm_official_pct+p.bd_pct+p.super_adm_pct+p.events_pct+p.reserve_pct,2);
 return jsonb_build_object('policy',p.name,'total_pct',total,'valid',total=100,'has_platform_margin',p.platform_pct>0,'has_ecosystem_margin',(100-p.platform_pct)>0);
end; $$;

-- V0.7 controles: as simulações acima são deliberadamente separadas de saldos financeiros reais.
