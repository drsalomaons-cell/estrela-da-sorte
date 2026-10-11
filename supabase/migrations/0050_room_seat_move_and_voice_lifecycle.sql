create or replace function public.claim_room_seat(
  p_room_id uuid, p_member_id uuid, p_seat_no smallint default null
) returns smallint
language plpgsql security definer set search_path = public
as $$
declare
  v_user_id uuid;
  v_current smallint;
  v_seat smallint;
  v_max_seats smallint;
begin
  select em.user_id into v_user_id
  from public.ecosystem_members em
  where em.id = p_member_id and em.status = 'active';
  if v_user_id is null or v_user_id <> auth.uid() then
    raise exception 'member_not_owned_by_current_user';
  end if;

  select rs.seats into v_max_seats
  from public.room_sessions rs
  where rs.id = p_room_id and rs.status = 'live';
  if v_max_seats is null then raise exception 'room_not_live'; end if;

  select rp.seat_no into v_current
  from public.room_participants rp
  where rp.room_id = p_room_id and rp.member_id = p_member_id and rp.left_at is null
  limit 1 for update;

  if p_seat_no is null then
    if v_current is not null then return v_current; end if;
    v_seat := public.p_seat_no(p_room_id, p_member_id, null);
  else
    if p_seat_no < 1 or p_seat_no > least(v_max_seats, 30) then
      raise exception 'invalid_seat_no';
    end if;
    if exists (
      select 1 from public.room_participants rp
      where rp.room_id = p_room_id and rp.seat_no = p_seat_no
        and rp.left_at is null and rp.member_id is distinct from p_member_id
    ) then raise exception 'seat_already_taken'; end if;
    v_seat := p_seat_no;
  end if;

  if v_current is not null then
    update public.room_participants set seat_no = v_seat
    where room_id = p_room_id and member_id = p_member_id and left_at is null;
    return v_seat;
  end if;

  insert into public.room_participants(room_id, member_id, seat_no, joined_at, left_at)
  values (p_room_id, p_member_id, v_seat, now(), null);
  return v_seat;
exception when unique_violation then
  raise exception 'seat_already_taken';
end;
$$;