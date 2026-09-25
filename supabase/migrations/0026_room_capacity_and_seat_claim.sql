-- V2.12 — capacidade configurável e ocupação atômica de cadeiras
-- Mantém a capacidade escolhida pela sala; apenas o teto é 30.

alter table public.room_participants
  drop constraint if exists room_participants_seat_no_check;
alter table public.room_participants
  add constraint room_participants_seat_no_check check (seat_no between 1 and 30);

create index if not exists room_participants_active_room_idx
  on public.room_participants(room_id, seat_no)
  where left_at is null;

create or replace function public.claim_room_seat(
  p_room_id uuid,
  p_member_id uuid
) returns smallint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_capacity smallint;
  v_seat smallint;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  perform 1
  from public.ecosystem_members
  where id = p_member_id
    and user_id = auth.uid()
    and status = 'active';

  if not found then
    raise exception 'Active member not found for authenticated user';
  end if;

  select seats into v_capacity
  from public.room_sessions
  where id = p_room_id and status = 'live'
  for update;

  if not found then
    raise exception 'Room is not live';
  end if;

  select seat_no into v_seat
  from generate_series(1, v_capacity) as s(seat_no)
  where not exists (
    select 1 from public.room_participants rp
    where rp.room_id = p_room_id
      and rp.seat_no = s.seat_no
      and rp.left_at is null
  )
  order by seat_no
  limit 1;

  if v_seat is null then
    raise exception 'Room is full';
  end if;

  update public.room_participants
  set left_at = now()
  where room_id = p_room_id
    and member_id = p_member_id
    and left_at is null;

  insert into public.room_participants(room_id,member_id,seat_no)
  values (p_room_id,p_member_id,v_seat);

  return v_seat;
end;
$$;

create or replace function public.leave_room_seat(
  p_room_id uuid,
  p_member_id uuid
) returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  update public.room_participants rp
  set left_at = now()
  from public.ecosystem_members em
  where rp.room_id = p_room_id
    and rp.member_id = p_member_id
    and rp.left_at is null
    and em.id = p_member_id
    and em.user_id = auth.uid();

  return found;
end;
$$;

grant execute on function public.claim_room_seat(uuid,uuid) to authenticated;
grant execute on function public.leave_room_seat(uuid,uuid) to authenticated;
