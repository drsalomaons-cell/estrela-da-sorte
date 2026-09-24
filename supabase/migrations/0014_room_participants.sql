-- V1.6 — participantes e cadeiras
create table if not exists public.room_participants (
 id uuid primary key default gen_random_uuid(),
 room_id uuid not null references public.room_sessions(id) on delete cascade,
 member_id uuid references public.ecosystem_members(id) on delete set null,
 seat_no smallint check(seat_no between 1 and 30),
 mic_enabled boolean not null default false,
 camera_enabled boolean not null default false,
 joined_at timestamptz not null default now(),
 left_at timestamptz,
 unique(room_id,seat_no)
);
alter table public.room_participants enable row level security;
create policy "room participants authenticated read" on public.room_participants for select to authenticated using (true);
