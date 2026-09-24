-- Estrela da Sorte — Motor de cenários econômicos V0.4
-- Simulação בלבד. Não cria saldo, saque ou movimentação financeira real.

insert into public.economy_policies
(name,status,platform_pct,host_pct,agency_pct,adm_official_pct,bd_pct,super_adm_pct,events_pct,reserve_pct,notes)
values
('V0.4 — Cenário 40/60','simulation',40,32,11,8,5,2,1,1,'Comparação de incentivo; não é regra oficial.'),
('V0.4 — Cenário 50/50','simulation',50,28,9,6,4,1,1,1,'Comparação de margem; não é regra oficial.')
on conflict do nothing;

create or replace function public.simulate_economy_scenario(
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
  total_hosts integer;
  total_production numeric;
  result jsonb;
begin
  if p_agencies < 1 or p_hosts_per_agency < 1 or p_monthly_production_per_host < 0 then
    raise exception 'Invalid scenario inputs';
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

  result := jsonb_build_object(
    'policy',p.name,
    'agencies',p_agencies,
    'hosts',total_hosts,
    'monthly_production',total_production,
    'platform',round(total_production*p.platform_pct/100,2),
    'host',round(total_production*p.host_pct/100,2),
    'agency',round(total_production*p.agency_pct/100,2),
    'adm_official_pool',round(total_production*p.adm_official_pct/100,2),
    'bd',round(total_production*p.bd_pct/100,2),
    'super_adm',round(total_production*p.super_adm_pct/100,2),
    'events',round(total_production*p.events_pct/100,2),
    'reserve',round(total_production*p.reserve_pct/100,2),
    'total',total_production
  );

  insert into public.economy_simulations(policy_id,base_amount,result)
  values(p.id,total_production,result);

  return result;
end;
$$;

-- Exemplos de teste:
-- select public.simulate_economy_scenario('V0.4 — Cenário 40/60',10,20,500);
-- select public.simulate_economy_scenario('V0.2 — Base 45/55',10,20,500);
-- select public.simulate_economy_scenario('V0.4 — Cenário 50/50',10,20,500);
