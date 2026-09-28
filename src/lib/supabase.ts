import { createClient } from "@supabase/supabase-js";

const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL as string | undefined) || "https://fjkhdokdwvpyidgunoes.supabase.co";
const supabaseAnonKey = (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) || "sb_publishable_4UDvq04914l9HSJ_gGFAgA_FCxOzDfN";

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
export const supabaseConfigured = true;
