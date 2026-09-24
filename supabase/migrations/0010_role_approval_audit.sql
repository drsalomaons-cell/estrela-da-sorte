-- V1.2 — aprovação de cargos e trilha de auditoria
create table if not exists public.ecosystem_role_requests (
 id uuid primary key default gen_random_uuid(),
 requester_user_id uuid not null,
 requested_role_code text not null references public.ecosystem_roles(code),
 parent_member_id uuid references public.ecosystem_members(id) on delete set null,
 reason text,
 status text not null default 'pending' check (status in ('pending','approved','rejected','cancelled')),
 reviewed_by uuid,
 reviewed_at timestamptz,
 created_at timestamptz not null default now()
);
create table if not exists public.ecosystem_audit_log (
 id bigserial primary key,
 actor_user_id uuid,
 action text not null,
 entity_type text not null,
 entity_id uuid,
 before_data jsonb,
 after_data jsonb,
 created_at timestamptz not null default now()
);
alter table public.ecosystem_role_requests enable row level security;
alter table public.ecosystem_audit_log enable row level security;
create policy "role requests own or admin read" on public.ecosystem_role_requests for select to authenticated
using (requester_user_id=auth.uid() or public.my_ecosystem_role() in ('SUPER_ADM','ADM_OFICIAL','BD'));
create policy "audit admin read" on public.ecosystem_audit_log for select to authenticated
using (public.my_ecosystem_role() in ('SUPER_ADM','ADM_OFICIAL','BD'));

create or replace function public.request_ecosystem_role(p_role text,p_parent uuid default null,p_reason text default null)
returns uuid language plpgsql security definer set search_path=public as $$
declare rid uuid;
begin
 if p_role not in ('ADM_OFICIAL','BD','AGENCIA','HOST') then raise exception 'Role requires controlled approval'; end if;
 insert into public.ecosystem_role_requests(requester_user_id,requested_role_code,parent_member_id,reason)
 values(auth.uid(),p_role,p_parent,p_reason) returning id into rid;
 insert into public.ecosystem_audit_log(actor_user_id,action,entity_type,entity_id,after_data)
 values(auth.uid(),'ROLE_REQUESTED','ecosystem_role_request',rid,jsonb_build_object('role',p_role,'parent_member_id',p_parent));
 return rid;
end; $$;

create or replace function public.approve_ecosystem_role(p_request_id uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare req public.ecosystem_role_requests%rowtype; mid uuid;
begin
 if public.my_ecosystem_role() not in ('SUPER_ADM','ADM_OFICIAL','BD') then raise exception 'Not authorized'; end if;
 select * into req from public.ecosystem_role_requests where id=p_request_id and status='pending' for update;
 if not found then raise exception 'Request not found or already reviewed'; end if;
 if public.my_ecosystem_role()<>'SUPER_ADM' and req.requested_role_code='ADM_OFICIAL' then raise exception 'Only Super ADM can approve ADM Oficial'; end if;
 insert into public.ecosystem_members(user_id,role_code,parent_member_id,display_name,status)
 values(req.requester_user_id,req.requested_role_code,req.parent_member_id,'Membro aprovado','active')
 returning id into mid;
 update public.ecosystem_role_requests set status='approved',reviewed_by=auth.uid(),reviewed_at=now() where id=req.id;
 insert into public.ecosystem_audit_log(actor_user_id,action,entity_type,entity_id,after_data)
 values(auth.uid(),'ROLE_APPROVED','ecosystem_member',mid,jsonb_build_object('role',req.requested_role_code,'request_id',req.id));
 return mid;
end; $$;
