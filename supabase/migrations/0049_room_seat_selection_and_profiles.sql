-- V4.9 — seleção/liberação de cadeiras com perfil
-- A operação é feita por RPC SECURITY DEFINER para que o cliente não possa
-- escolher/liberar uma cadeira em nome de outro usuário.
--
-- Compatível com a tabela criada em 0014_room_participants.sql.

create unique index if not exists room_participants_active_member_uidx
  on public.room_participants(room_id, member_id)
  where left_at is null;

create or replace function public.p_seat_no(
  p_room_id uuid,
  p_member_id uuid,
  p_seat_no smallint default null
)
returns smallint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
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

  if v_max_seats is null then
    raise exception 'room_not_live';
  end if;

  select rp.seat_no into v_seat
  from public.room_participants rp
  where rp.room_id = p_room_id
    and rp.member_id = p_member_id
    and rp.left_at is null
  limit 1;

  if v_seat is not null then
    return v_seat;
  end if;

  if p_seat_no is null then
    select gs::smallint into v_seat
    from generate_series(1, least(v_max_seats, 30)) gs
    where not exists (
      select 1 from public.room_participants rp
      where rp.room_id = p_room_id
        and rp.seat_no = gs
        and rp.left_at is null
    )
    order by gs
    limit 1;
  else
    if p_seat_no < 1 or p_seat_no > least(v_max_seats, 30) then
      raise exception 'invalid_seat_no';
    end if;
    if exists (
      select 1 from public.room_participants rp
      where rp.room_id = p_room_id
        and rp.seat_no = p_seat_no
        and rp.left_at is null
    ) then
      raise exception 'seat_already_taken';
    end if;
    v_seat := p_seat_no;
  end if;

  if v_seat is null then
    raise exception 'room_full';
  end if;

  return v_seat;
end;
$$;

create or replace function public.claim_room_seat(
  p_room_id uuid,
  p_member_id uuid,
  p_seat_no smallint default null
)
returns smallint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_seat smallint;
begin
  v_seat := public.p_seat_no(p_room_id, p_member_id, p_seat_no);

  insert into public.room_participants(
    room_id, member_id, seat_no, joined_at, left_at
  )
  values (p_room_id, p_member_id, v_seat, now(), null);

  return v_seat;
exception
  when unique_violation then
    raise exception 'seat_already_taken';
end;
$$;

create or replace function public.leave_room_seat(
  p_room_id uuid,
  p_member_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_count integer;
begin
  select em.user_id
    into v_user_id
  from public.ecosystem_members em
  where em.id = p_member_id
    and em.status = 'active';

  if v_user_id is null or v_user_id <> auth.uid() then
    raise exception 'member_not_owned_by_current_user';
  end if;

  update public.room_participants
  set left_at = now()
  where room_id = p_room_id
    and member_id = p_member_id
    and left_at is null;

  get diagnostics v_count = row_count;
  return v_count > 0;
end;
$$;

create or replace function public.list_room_seats(
  p_room_id uuid
)
returns table (
  id uuid,
  member_id uuid,
  seat_no smallint,
  mic_enabled boolean,
  camera_enabled boolean,
  joined_at timestamptz,
  display_name text,
  avatar_url text
)
language sql
security definer
set search_path = public
as $$
  select
    rp.id,
    rp.member_id,
    rp.seat_no,
    rp.mic_enabled,
    rp.camera_enabled,
    rp.joined_at,
    coalesce(em.display_name, 'Usuário') as display_name,
    coalesce(
      nullif(au.raw_user_meta_data->>'avatar_url', ''),
      nullif(au.raw_user_meta_data->>'picture', '')
    ) as avatar_url
  from public.room_participants rp
  left join public.ecosystem_members em
    on em.id = rp.member_id
  left join auth.users au
    on au.id = em.user_id
  where rp.room_id = p_room_id
    and rp.left_at is null
  order by rp.seat_no;
$$;

revoke all on function public.p_seat_no(uuid, uuid, smallint) from public;
grant execute on function public.p_seat_no(uuid, uuid, smallint) to authenticated;

revoke all on function public.claim_room_seat(uuid, uuid, smallint) from public;
grant execute on function public.claim_room_seat(uuid, uuid, smallint) to authenticated;

revoke all on function public.leave_room_seat(uuid, uuid) from public;
grant execute on function public.leave_room_seat(uuid, uuid) to authenticated;

revoke all on function public.list_room_seats(uuid) from public;
grant execute on function public.list_room_seats(uuid) to authenticated;
