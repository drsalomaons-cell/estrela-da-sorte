alter table public.room_sessions drop constraint if exists room_sessions_seats_check; alter table public.room_sessions add constraint room_sessions_seats_check check (seats >= 30 and seats <= 100);
