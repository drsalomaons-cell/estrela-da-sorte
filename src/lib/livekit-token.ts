import { supabase } from "./supabase";

export type LiveKitTokenResponse = {
  token: string;
  url: string | null;
};

export async function getLiveKitToken(roomName: string): Promise<LiveKitTokenResponse> {
  if (!supabase) throw new Error("Supabase não configurado");
  if (!roomName.trim()) throw new Error("Nome da sala não informado");

  const { data, error } = await supabase.functions.invoke("livekit-token", {
    body: { room_name: roomName.trim() },
  });

  if (error) throw new Error(error.message || "Não foi possível obter o token LiveKit");
  if (!data?.token) throw new Error("Backend não retornou token LiveKit");

  return {
    token: data.token,
    url: data.url ?? null,
  };
}
