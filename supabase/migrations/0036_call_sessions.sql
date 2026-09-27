-- V2.17 — sessões de voz/vídeo ligadas à sala do ecossistema.
create table if not exists public.call_sessions (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.room_sessions(id) on delete cascade,
  call_type text not null default 'voice' check (call_type in ('voice','video')),
  livekit_room_name text not null,
  started_by uuid not null,
  status text not null default 'active' check (status in ('active','ended')),
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

create index if not exists call_sessions_room_id_idx on public.call_sessions(room_id);
create index if not exists call_sessions_status_idx on public.call_sessions(status);

alter table public.call_sessions enable row level security;

drop policy if exists "call sessions authenticated read" on public.call_sessions;
create policy "call sessions authenticated read"
  on public.call_sessions for select to authenticated using (true);

drop policy if exists "call sessions authenticated insert own" on public.call_sessions;
create policy "call sessions authenticated insert own"
  on public.call_sessions for insert to authenticated
  with check (started_by = auth.uid());

drop policy if exists "call sessions authenticated update own" on public.call_sessions;
create policy "call sessions authenticated update own"
  on public.call_sessions for update to authenticated
  using (started_by = auth.uid())
  with check (started_by = auth.uid());
