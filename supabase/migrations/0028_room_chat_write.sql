-- V2.14 — escrita segura do chat da sala
create or replace function public.send_room_chat_message(
  p_room_id uuid,
  p_body text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_body text := btrim(p_body);
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if length(v_body) < 1 or length(v_body) > 1000 then
    raise exception 'Message length must be between 1 and 1000';
  end if;

  perform 1
  from public.room_sessions rs
  where rs.id = p_room_id and rs.status = 'live';
  if not found then
    raise exception 'Room is not live';
  end if;

  perform 1
  from public.room_participants rp
  join public.ecosystem_members em on em.id = rp.member_id
  where rp.room_id = p_room_id
    and rp.left_at is null
    and em.user_id = auth.uid()
    and em.status = 'active';

  if not found then
    raise exception 'User is not an active room participant';
  end if;

  insert into public.room_chat_messages(room_id,sender_user_id,body)
  values (p_room_id,auth.uid(),v_body)
  returning id into v_id;

  return v_id;
end;
$$;

grant execute on function public.send_room_chat_message(uuid,text) to authenticated;
