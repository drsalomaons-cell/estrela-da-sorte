-- V1.8 — métricas do painel, sem expor dados financeiros individuais
create or replace function public.ecosystem_dashboard_metrics()
returns jsonb language plpgsql security definer set search_path=public as $$
declare active_members integer; live_rooms integer; active_agencies integer; active_hosts integer; messages_today integer; gifts_today integer;
begin
 select count(*) into active_members from public.ecosystem_members where status='active';
 select count(*) into live_rooms from public.room_sessions where status='live';
 select count(*) into active_agencies from public.ecosystem_members where role_code='AGENCIA' and status='active';
 select count(*) into active_hosts from public.ecosystem_members where role_code='HOST' and status='active';
 select count(*) into messages_today from public.room_chat_messages where created_at>=current_date;
 select count(*) into gifts_today from public.gift_events where created_at>=current_date;
 return jsonb_build_object(
  'active_members',active_members,'live_rooms',live_rooms,'active_agencies',active_agencies,
  'active_hosts',active_hosts,'messages_today',messages_today,'gifts_today',gifts_today,
  'financial_payouts',false
 );
end; $$;
