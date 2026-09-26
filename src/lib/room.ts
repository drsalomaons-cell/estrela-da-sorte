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

export async function getLiveRoom(roomKey?: string): Promise<RoomSession | null> {
  if (!supabase) throw new Error("Supabase não configurado");
  let query = supabase
    .from("room_sessions")
    .select("id,room_key,title,status,seats,video_enabled,chat_enabled")
    .eq("status", "live");

  if (roomKey) query = query.eq("room_key", roomKey);

  const { data, error } = await query.order("created_at", { ascending: true }).limit(1).maybeSingle();
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

export function subscribeToRoomSeats(
  roomId: string,
  onChange: () => void,
) {
  if (!supabase) throw new Error("Supabase não configurado");
  const channel = supabase
    .channel(`room-seats:${roomId}`)
    .on(
      "postgres_changes",
      {
        event: "*",
        schema: "public",
        table: "room_participants",
        filter: `room_id=eq.${roomId}`,
      },
      () => onChange(),
    )
    .subscribe();

  return () => {
    void supabase.removeChannel(channel);
  };
}

export async function getCurrentMemberId() {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
  if (sessionError) throw sessionError;
  const userId = sessionData.session?.user.id;
  if (!userId) return null;

  const { data, error } = await supabase
    .from("ecosystem_members")
    .select("id")
    .eq("user_id", userId)
    .eq("status", "active")
    .maybeSingle();

  if (error) throw error;
  return data?.id ?? null;
}
