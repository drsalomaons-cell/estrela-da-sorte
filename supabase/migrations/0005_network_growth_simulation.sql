-- Estrela da Sorte — V0.5 crescimento do ecossistema
-- Simulação בלבד. Não cria saldo, saque ou movimentação financeira real.
-- Objetivo: testar a escada ADM Oficial sem transformar percentuais em regra ativa.

create or replace function public.simulate_network_growth(
  p_policy_name text,
  p_agencies integer,
  p_hosts_per_agency integer,
  p_monthly_production_per_host numeric
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.economy_policies%rowtype;
  lvl public.adm_official_levels%rowtype;
  total_hosts integer;
  total_production numeric;
  adm_rate numeric;
  adm_reference_amount numeric;
  result jsonb;
begin
  if p_agencies < 1 or p_hosts_per_agency < 1 or p_monthly_production_per_host < 0 then
    raise exception 'Invalid network inputs';
  end if;

  select * into p from public.economy_policies
  where name = p_policy_name and status = 'simulation'
  limit 1;

  if not found then
    raise exception 'Simulation policy not found: %', p_policy_name;
  end if;

  if round(p.platform_pct+p.host_pct+p.agency_pct+p.adm_official_pct+p.bd_pct+p.super_adm_pct+p.events_pct+p.reserve_pct,2) <> 100 then
    raise exception 'Policy percentages must total 100%%';
  end if;

  total_hosts := p_agencies * p_hosts_per_agency;
  total_production := round(total_hosts * p_monthly_production_per_host,2);

  select * into lvl
  from public.adm_official_levels
  where active = true
    and min_active_agencies <= p_agencies
    and min_monthly_production <= total_production
  order by level_no desc
  limit 1;

  if not found then
    adm_rate := 0;
    adm_reference_amount := 0;
  else
    adm_rate := lvl.commission_pct;
    adm_reference_amount := round(total_production * adm_rate / 100,2);
  end if;

  result := jsonb_build_object(
    'policy',p.name,
    'agencies',p_agencies,
    'hosts',total_hosts,
    'monthly_production',total_production,
    'adm_level',coalesce(lvl.name,'Sem nível'),
    'adm_level_no',coalesce(lvl.level_no,0),
    'adm_commission_rate_pct',adm_rate,
    'adm_commission_reference_amount',adm_reference_amount,
    'adm_pool_pct',p.adm_official_pct,
    'adm_pool_amount',round(total_production*p.adm_official_pct/100,2),
    'platform_amount',round(total_production*p.platform_pct/100,2),
    'host_amount',round(total_production*p.host_pct/100,2),
    'agency_amount',round(total_production*p.agency_pct/100,2),
    'bd_amount',round(total_production*p.bd_pct/100,2),
    'super_adm_amount',round(total_production*p.super_adm_pct/100,2),
    'events_amount',round(total_production*p.events_pct/100,2),
    'reserve_amount',round(total_production*p.reserve_pct/100,2),
    'total',total_production
  );

  insert into public.economy_simulations(policy_id,base_amount,result)
  values(p.id,total_production,result);

  return result;
end;
$$;

-- Cenários de validação previstos:
-- 10 agências x 20 hosts x R$500 = R$100.000/mês
-- 50 agências x 20 hosts x R$500 = R$500.000/mês
-- 100 agências x 20 hosts x R$500 = R$1.000.000/mês
-- 500 agências x 20 hosts x R$500 = R$5.000.000/mês
-- 1000 agências x 20 hosts x R$500 = R$10.000.000/mês
--
-- Exemplo:
-- select public.simulate_network_growth('V0.2 — Base 45/55',100,20,500);
