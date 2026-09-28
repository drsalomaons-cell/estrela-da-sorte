-- V3.9 — endurecimento de acesso e leitura segura dos catálogos
-- Funções SECURITY DEFINER não devem ser públicas para anon.
revoke execute on function public.approve_ecosystem_role(uuid) from anon;
revoke execute on function public.audit_economy_stack() from anon;
revoke execute on function public.can_manage_ecosystem_member(uuid) from anon;
revoke execute on function public.claim_room_seat(uuid,uuid) from anon;
revoke execute on function public.ecosystem_dashboard_metrics() from anon;
revoke execute on function public.ensure_user_social_profile() from anon;
revoke execute on function public.leave_room_seat(uuid,uuid) from anon;
revoke execute on function public.my_ecosystem_role() from anon;
revoke execute on function public.request_ecosystem_role(text,uuid,text) from anon;
revoke execute on function public.resolve_gift_simulation(uuid) from anon;
revoke execute on function public.rls_auto_enable() from anon;
revoke execute on function public.send_room_chat_message(uuid,text) from anon;
revoke execute on function public.simulate_economy(numeric,text) from anon;
revoke execute on function public.simulate_economy_scenario(text,integer,integer,numeric) from anon;
revoke execute on function public.simulate_ecosystem_distribution(text,numeric,text) from anon;
revoke execute on function public.simulate_network_growth(text,integer,integer,numeric) from anon;
revoke execute on function public.simulate_role_chain(numeric) from anon;
revoke execute on function public.transfer_virtual_gift(uuid,uuid,uuid,uuid) from anon;
revoke execute on function public.validate_economy_guardrails(text) from anon;
revoke execute on function public.validate_economy_policy(text) from anon;

alter table public.game_registry enable row level security;
drop policy if exists "game registry authenticated read" on public.game_registry;
create policy "game registry authenticated read" on public.game_registry for select to authenticated using (true);

alter table public.slot_catalog enable row level security;
drop policy if exists "slot catalog authenticated read" on public.slot_catalog;
create policy "slot catalog authenticated read" on public.slot_catalog for select to authenticated using (true);

alter table public.gift_catalog enable row level security;
drop policy if exists "gift catalog authenticated read" on public.gift_catalog;
create policy "gift catalog authenticated read" on public.gift_catalog for select to authenticated using (true);

alter table public.gift_rules enable row level security;
drop policy if exists "gift rules authenticated read" on public.gift_rules;
create policy "gift rules authenticated read" on public.gift_rules for select to authenticated using (true);

alter table public.ecosystem_roles enable row level security;
drop policy if exists "ecosystem roles authenticated read" on public.ecosystem_roles;
create policy "ecosystem roles authenticated read" on public.ecosystem_roles for select to authenticated using (true);

alter table public.user_profiles enable row level security;
drop policy if exists "user profiles own read" on public.user_profiles;
create policy "user profiles own read" on public.user_profiles for select to authenticated using (user_id=auth.uid());

alter table public.user_wallets enable row level security;
drop policy if exists "wallet own read" on public.user_wallets;
create policy "wallet own read" on public.user_wallets for select to authenticated using (user_id=auth.uid());

alter table public.wallet_ledger enable row level security;
drop policy if exists "wallet ledger own read" on public.wallet_ledger;
create policy "wallet ledger own read" on public.wallet_ledger for select to authenticated using (user_id=auth.uid());
