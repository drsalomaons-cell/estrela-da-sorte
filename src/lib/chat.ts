import { supabase } from "./supabase";

export async function sendRoomMessage(roomId: string, body: string) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase.rpc("send_room_chat_message", {
    p_room_id: roomId,
    p_body: body,
  });
  if (error) throw error;
  return data as string;
}

export function subscribeToRoomChat(
  roomId: string,
  onMessage: (message: Record<string, unknown>) => void,
) {
  if (!supabase) throw new Error("Supabase não configurado");
  const channel = supabase
    .channel(`room-chat:${roomId}`)
    .on(
      "postgres_changes",
      {
        event: "INSERT",
        schema: "public",
        table: "room_chat_messages",
        filter: `room_id=eq.${roomId}`,
      },
      (payload) => onMessage(payload.new as Record<string, unknown>),
    )
    .subscribe();

  return () => {
    void supabase.removeChannel(channel);
  };
}
