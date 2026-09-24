-- V1.5 — salas e sessões, sem cobrança real
create table if not exists public.room_sessions (
 id uuid primary key default gen_random_uuid(),
 room_key text unique not null,
 host_member_id uuid references public.ecosystem_members(id) on delete set null,
 title text not null,
 status text not null default 'live' check(status in ('scheduled','live','ended')),
 seats smallint not null default 30 check(seats between 1 and 30),
 video_enabled boolean not null default false,
 chat_enabled boolean not null default true,
 created_at timestamptz not null default now(),
 ended_at timestamptz
);
create index if not exists room_sessions_host_idx on public.room_sessions(host_member_id,status);
alter table public.room_sessions enable row level security;
create policy "room sessions authenticated read" on public.room_sessions for select to authenticated using (true);
