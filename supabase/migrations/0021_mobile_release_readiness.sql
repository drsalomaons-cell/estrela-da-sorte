-- V2.3 release checklist
create table if not exists public.mobile_release_checks (check_key text primary key,description text not null,status text not null default 'pending',evidence text);