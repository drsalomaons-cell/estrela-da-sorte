-- V1.7 — chat e presentes
create table if not exists public.room_chat_messages (
 id uuid primary key default gen_random_uuid(),
 room_id uuid not null references public.room_sessions(id) on delete cascade,
 sender_user_id uuid not null,
 body text not null check(length(body) between 1 and 1000),
 created_at timestamptz not null default now()
);
create table if not exists public.gift_events (
 id uuid primary key default gen_random_uuid(),
 room_id uuid not null references public.room_sessions(id) on delete cascade,
 gift_id uuid not null references public.gift_catalog(id),
 sender_user_id uuid not null,
 recipient_member_id uuid references public.ecosystem_members(id) on delete set null,
 lucky_result boolean,
 created_at timestamptz not null default now(),
 metadata jsonb not null default '{}'::jsonb
);
alter table public.room_chat_messages enable row level security;
alter table public.gift_events enable row level security;
create policy "chat authenticated read" on public.room_chat_messages for select to authenticated using (true);
create policy "gift events authenticated read" on public.gift_events for select to authenticated using (true);
