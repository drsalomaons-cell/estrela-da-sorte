-- V4.8 — Auto-enrollment do programa de homologação
-- O cadastro não falha se o programa estiver cheio/inativo.
create or replace function public.auto_enroll_test_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  begin perform public.enroll_test_user(new.id); exception when others then null; end;
  return new;
end; $$;

drop trigger if exists on_auth_user_test_program on auth.users;
create trigger on_auth_user_test_program after insert on auth.users
for each row execute function public.auto_enroll_test_user();
