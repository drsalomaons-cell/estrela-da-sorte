-- V2.15 — habilitar Realtime para estado de sala e chat
-- Idempotente: só adiciona as tabelas se ainda não estiverem na publicação.

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'room_chat_messages'
  ) then
    alter publication supabase_realtime add table public.room_chat_messages;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'room_participants'
  ) then
    alter publication supabase_realtime add table public.room_participants;
  end if;
end
$$;
