-- Estrela da Sorte — Motor de simulação econômica V0.3
-- Somente simulação. Não gera saldo sacável nem movimentação financeira real.

create or replace function public.simulate_economy(
  p_base_amount numeric,
  p_policy_name text default 'V0.2 — Base 45/55'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.economy_policies%rowtype;
  result jsonb;
begin
  if p_base_amount < 0 then
    raise exception 'p_base_amount must be >= 0';
  end if;

  select * into p
  from public.economy_policies
  where name = p_policy_name and status = 'simulation'
  limit 1;

  if not found then
    raise exception 'Simulation policy not found: %', p_policy_name;
  end if;

  if round(
    p.platform_pct+p.host_pct+p.agency_pct+p.adm_official_pct+
    p.bd_pct+p.super_adm_pct+p.events_pct+p.reserve_pct,2
  ) <> 100 then
    raise exception 'Policy percentages must total 100%%';
  end if;

  result := jsonb_build_object(
    'policy', p.name,
    'base_amount', round(p_base_amount,2),
    'platform', round(p_base_amount*p.platform_pct/100,2),
    'host', round(p_base_amount*p.host_pct/100,2),
    'agency', round(p_base_amount*p.agency_pct/100,2),
    'adm_official_pool', round(p_base_amount*p.adm_official_pct/100,2),
    'bd', round(p_base_amount*p.bd_pct/100,2),
    'super_adm', round(p_base_amount*p.super_adm_pct/100,2),
    'events', round(p_base_amount*p.events_pct/100,2),
    'reserve', round(p_base_amount*p.reserve_pct/100,2)
  );

  insert into public.economy_simulations(policy_id,base_amount,result)
  values(p.id,p_base_amount,result);

  return result;
end;
$$;

-- Example:
-- select public.simulate_economy(10000);
