-- V1.4 — auditoria cruzada da economia
create or replace function public.audit_economy_stack()
returns jsonb language plpgsql security definer set search_path=public as $$
declare total_policies integer; total_roles integer; total_guardrails integer; total_gifts integer;
begin
 select count(*) into total_policies from public.economy_policies;
 select count(*) into total_roles from public.ecosystem_roles;
 select count(*) into total_guardrails from public.economy_guardrails;
 select count(*) into total_gifts from public.gift_catalog;
 return jsonb_build_object(
  'policies',total_policies,'roles',total_roles,'guardrails',total_guardrails,'gifts',total_gifts,
  'economy_tables_present',to_regclass('public.economy_policies') is not null,
  'role_tables_present',to_regclass('public.ecosystem_roles') is not null,
  'gift_tables_present',to_regclass('public.gift_catalog') is not null,
  'simulation_only',true
 );
end; $$;
