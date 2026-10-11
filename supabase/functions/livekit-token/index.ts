import { createClient } from "npm:@supabase/supabase-js@2.110.2";
import { AccessToken } from "npm:livekit-server-sdk@2.19.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

function reply(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });

  const authorization = req.headers.get("Authorization");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const livekitUrl = Deno.env.get("LIVEKIT_URL");
  const livekitKey = Deno.env.get("LIVEKIT_API_KEY");
  const livekitSecret = Deno.env.get("LIVEKIT_API_SECRET");

  if (!authorization || !supabaseUrl || !serviceRoleKey) {
    return reply(401, { error: "supabase_auth_not_configured" });
  }
  if (!livekitUrl || !livekitKey || !livekitSecret) {
    return reply(503, { error: "livekit_credentials_not_configured" });
  }

  try {
    const userClient = createClient(supabaseUrl, serviceRoleKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) return reply(401, { error: "invalid_user_session" });

    const payload = await req.json().catch(() => ({}));
    const roomName = typeof payload.room_name === "string" ? payload.room_name.trim() : "";
    if (!roomName || roomName.length > 120) return reply(400, { error: "room_name_required" });

    const { data: room, error: roomError } = await userClient
      .from("room_sessions")
      .select("id,room_key,status")
      .eq("room_key", roomName)
      .maybeSingle();
    if (roomError) return reply(403, { error: "room_lookup_failed" });
    if (!room || room.status !== "live") return reply(404, { error: "live_room_not_found" });

    const token = new AccessToken(livekitKey, livekitSecret, {
      identity: userData.user.id,
      name: userData.user.user_metadata?.display_name ?? userData.user.email ?? userData.user.id,
      ttl: "15m",
    });
    token.addGrant({
      roomJoin: true,
      room: room.room_key,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });
    return reply(200, { token: await token.toJwt(), url: livekitUrl });
  } catch {
    return reply(500, { error: "token_generation_failed" });
  }
});