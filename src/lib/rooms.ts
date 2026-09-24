import { supabase } from "./supabase";

export type RoomRecord = {
  id: string;
  name: string;
  owner_id: string | null;
  max_seats: number;
  video_enabled: boolean;
  active: boolean;
};

export async function listActiveRooms(): Promise<RoomRecord[]> {
  if (!supabase) return [];
  const { data, error } = await supabase
    .from("rooms")
    .select("id,name,owner_id,max_seats,video_enabled,active")
    .eq("active", true)
    .order("created_at", { ascending: true });

  if (error) throw error;
  return data ?? [];
}
