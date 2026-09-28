-- V4.0 — políticas RLS mínimas para tabelas administrativas e de ecossistema
drop policy if exists "agencies scoped read" on public.agencies;
create policy "agencies scoped read" on public.agencies for select to authenticated
using (owner_id=auth.uid() or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
drop policy if exists "hosts scoped read" on public.hosts;
create policy "hosts scoped read" on public.hosts for select to authenticated
using (user_id=auth.uid() or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
drop policy if exists "economy guardrails admin read" on public.economy_guardrails;
create policy "economy guardrails admin read" on public.economy_guardrails for select to authenticated
using (coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL'));
drop policy if exists "economy ledger simulation admin read" on public.economy_ledger_simulation;
create policy "economy ledger simulation admin read" on public.economy_ledger_simulation for select to authenticated
using (coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD'));
drop policy if exists "mobile release checks authenticated read" on public.mobile_release_checks;
create policy "mobile release checks authenticated read" on public.mobile_release_checks for select to authenticated using (true);
drop policy if exists "reseller profiles scoped read" on public.reseller_profiles;
create policy "reseller profiles scoped read" on public.reseller_profiles for select to authenticated
using (user_id=auth.uid() or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
drop policy if exists "reseller price lists scoped read" on public.reseller_price_lists;
create policy "reseller price lists scoped read" on public.reseller_price_lists for select to authenticated
using (exists(select 1 from public.reseller_profiles rp where rp.id=reseller_id and (rp.user_id=auth.uid() or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'))));
drop policy if exists "reseller orders scoped read" on public.reseller_orders;
create policy "reseller orders scoped read" on public.reseller_orders for select to authenticated
using (buyer_user_id=auth.uid() or exists(select 1 from public.reseller_profiles rp where rp.id=reseller_id and rp.user_id=auth.uid()) or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
drop policy if exists "reseller ledger scoped read" on public.reseller_ledger_simulation;
create policy "reseller ledger scoped read" on public.reseller_ledger_simulation for select to authenticated
using (exists(select 1 from public.reseller_profiles rp where rp.id=reseller_id and rp.user_id=auth.uid()) or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
drop policy if exists "worker earnings own read" on public.worker_earnings_ledger;
create policy "worker earnings own read" on public.worker_earnings_ledger for select to authenticated
using (exists(select 1 from public.ecosystem_members em where em.id=worker_member_id and em.user_id=auth.uid()) or coalesce(public.my_ecosystem_role(),'') in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
revoke execute on function public.approve_ecosystem_role(uuid) from public; grant execute on function public.approve_ecosystem_role(uuid) to authenticated;
revoke execute on function public.audit_economy_stack() from public; grant execute on function public.audit_economy_stack() to authenticated;
revoke execute on function public.can_manage_ecosystem_member(uuid) from public; grant execute on function public.can_manage_ecosystem_member(uuid) to authenticated;
revoke execute on function public.claim_room_seat(uuid,uuid) from public; grant execute on function public.claim_room_seat(uuid,uuid) to authenticated;
revoke execute on function public.ecosystem_dashboard_metrics() from public; grant execute on function public.ecosystem_dashboard_metrics() to authenticated;
revoke execute on function public.ensure_user_social_profile() from public; grant execute on function public.ensure_user_social_profile() to authenticated;
revoke execute on function public.leave_room_seat(uuid,uuid) from public; grant execute on function public.leave_room_seat(uuid,uuid) to authenticated;
revoke execute on function public.my_ecosystem_role() from public; grant execute on function public.my_ecosystem_role() to authenticated;
revoke execute on function public.request_ecosystem_role(text,uuid,text) from public; grant execute on function public.request_ecosystem_role(text,uuid,text) to authenticated;
revoke execute on function public.resolve_gift_simulation(uuid) from public; grant execute on function public.resolve_gift_simulation(uuid) to authenticated;
revoke execute on function public.rls_auto_enable() from public;
revoke execute on function public.send_room_chat_message(uuid,text) from public; grant execute on function public.send_room_chat_message(uuid,text) to authenticated;
revoke execute on function public.simulate_economy(numeric,text) from public; grant execute on function public.simulate_economy(numeric,text) to authenticated;
revoke execute on function public.simulate_economy_scenario(text,integer,integer,numeric) from public; grant execute on function public.simulate_economy_scenario(text,integer,integer,numeric) to authenticated;
revoke execute on function public.simulate_ecosystem_distribution(text,numeric,text) from public; grant execute on function public.simulate_ecosystem_distribution(text,numeric,text) to authenticated;
revoke execute on function public.simulate_network_growth(text,integer,integer,numeric) from public; grant execute on function public.simulate_network_growth(text,integer,integer,numeric) to authenticated;
revoke execute on function public.simulate_role_chain(numeric) from public; grant execute on function public.simulate_role_chain(numeric) to authenticated;
revoke execute on function public.transfer_virtual_gift(uuid,uuid,uuid,uuid) from public; grant execute on function public.transfer_virtual_gift(uuid,uuid,uuid,uuid) to authenticated;
revoke execute on function public.validate_economy_guardrails(text) from public; grant execute on function public.validate_economy_guardrails(text) to authenticated;
revoke execute on function public.validate_economy_policy(text) from public; grant execute on function public.validate_economy_policy(text) to authenticated;