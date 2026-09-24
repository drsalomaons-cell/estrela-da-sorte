-- V1.4 — auditoria econômica
create or replace function public.audit_economy_stack()
returns jsonb language plpgsql security definer set search_path=public as $$
declare roles_count integer; gifts_count integer;
begin
 select count(*) into roles_count from public.ecosystem_roles;
 select count(*) into gifts_count from public.gift_catalog;
 return jsonb_build_object('roles',roles_count,'gifts',gifts_count,'simulation_only',true);
end; $$;
