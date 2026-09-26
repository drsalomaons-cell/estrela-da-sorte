-- V3.2 — ciclo de vida explícito do catálogo de jogos
alter table public.game_registry drop constraint if exists game_registry_status_check;
alter table public.game_registry
  add constraint game_registry_status_check
  check(status in ('planned','prototype','integrated','tested','disabled'));

alter table public.game_registry
  add column if not exists monetization_mode text not null default 'none'
  check(monetization_mode in ('none','virtual'));

update public.game_registry
set status = case
  when status='planned' then 'planned'
  when status='integrated' then 'integrated'
  when status='disabled' then 'disabled'
  else 'prototype'
end;

update public.game_registry
set monetization_mode='none'
where monetization_mode is null;
