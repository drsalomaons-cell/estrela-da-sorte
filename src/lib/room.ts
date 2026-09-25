import { supabase } from "./supabase";

export type RoomSession = {
  id: string;
  room_key: string;
  title: string;
  status: "scheduled" | "live" | "ended";
  seats: number;
  video_enabled: boolean;
  chat_enabled: boolean;
};

export async function getLiveRoom(roomKey: string): Promise<RoomSession | null> {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase
    .from("room_sessions")
    .select("id,room_key,title,status,seats,video_enabled,chat_enabled")
    .eq("room_key", roomKey)
    .maybeSingle();
  if (error) throw error;
  return data as RoomSession | null;
}

export async function claimSeat(roomId: string, memberId: string) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase.rpc("claim_room_seat", {
    p_room_id: roomId,
    p_member_id: memberId,
  });
  if (error) throw error;
  return Number(data);
}

export async function leaveSeat(roomId: string, memberId: string) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase.rpc("leave_room_seat", {
    p_room_id: roomId,
    p_member_id: memberId,
  });
  if (error) throw error;
  return Boolean(data);
}

export async function listActiveSeats(roomId: string) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase
    .from("room_participants")
    .select("id,member_id,seat_no,mic_enabled,camera_enabled,joined_at")
    .eq("room_id", roomId)
    .is("left_at", null)
    .order("seat_no");
  if (error) throw error;
  return data ?? [];
}
