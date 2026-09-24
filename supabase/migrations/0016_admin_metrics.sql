-- V1.8 — métricas administrativas
create or replace function public.ecosystem_dashboard_metrics()
returns jsonb language plpgsql security definer set search_path=public as $$
declare active_members integer; live_rooms integer; active_agencies integer; active_hosts integer;
begin
 select count(*) into active_members from public.ecosystem_members where status='active';
 select count(*) into live_rooms from public.room_sessions where status='live';
 select count(*) into active_agencies from public.ecosystem_members where role_code='AGENCIA' and status='active';
 select count(*) into active_hosts from public.ecosystem_members where role_code='HOST' and status='active';
 return jsonb_build_object('active_members',active_members,'live_rooms',live_rooms,'active_agencies',active_agencies,'active_hosts',active_hosts);
end; $$;
