-- V1.1 — escopo e permissões por função
create table if not exists public.ecosystem_permissions (
 role_code text not null references public.ecosystem_roles(code) on delete cascade,
 permission_code text not null,
 scope text not null default 'self' check (scope in ('self','children','network','global')),
 primary key(role_code,permission_code)
);
insert into public.ecosystem_permissions(role_code,permission_code,scope) values
('SUPER_ADM','manage_roles','global'),
('SUPER_ADM','manage_economy','global'),
('SUPER_ADM','manage_events','global'),
('ADM_OFICIAL','manage_bds','network'),
('ADM_OFICIAL','manage_agencies','children'),
('ADM_OFICIAL','view_production','network'),
('BD','manage_agencies','children'),
('BD','view_production','children'),
('AGENCIA','manage_hosts','children'),
('AGENCIA','view_production','children'),
('HOST','manage_room','self'),
('HOST','view_own_production','self')
on conflict do nothing;
alter table public.ecosystem_permissions enable row level security;
create policy "permissions authenticated read" on public.ecosystem_permissions for select to authenticated using (true);

create or replace function public.my_ecosystem_role()
returns text language sql stable security definer set search_path=public as $$
 select role_code from public.ecosystem_members
 where user_id=auth.uid() and status='active'
 order by case role_code when 'SUPER_ADM' then 1 when 'ADM_OFICIAL' then 2 when 'BD' then 3 when 'AGENCIA' then 4 else 5 end
 limit 1
$$;

create or replace function public.can_manage_ecosystem_member(p_target_id uuid)
returns boolean language plpgsql stable security definer set search_path=public as $$
declare r text; target_role text; target_parent uuid;
begin
 r:=public.my_ecosystem_role();
 select role_code,parent_member_id into target_role,target_parent from public.ecosystem_members where id=p_target_id;
 if r='SUPER_ADM' then return true; end if;
 if r='ADM_OFICIAL' then return target_parent in (select id from public.ecosystem_members where user_id=auth.uid() and status='active') and target_role in ('BD','AGENCIA','HOST'); end if;
 if r='BD' then return target_parent in (select id from public.ecosystem_members where user_id=auth.uid() and status='active') and target_role in ('AGENCIA','HOST'); end if;
 if r='AGENCIA' then return target_parent in (select id from public.ecosystem_members where user_id=auth.uid() and status='active') and target_role='HOST'; end if;
 return false;
end; $$;


-- RLS da cadeia: a própria função consulta sob SECURITY DEFINER.
create policy "ecosystem members scoped read" on public.ecosystem_members for select to authenticated
using (user_id=auth.uid() or public.my_ecosystem_role() in ('SUPER_ADM','ADM_OFICIAL','BD','AGENCIA'));
