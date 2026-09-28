import fs from "node:fs";
import path from "node:path";

const required = [
  "package.json",
  "src/App.tsx",
  "src/lib/supabase.ts",
  "src/lib/room.ts",
  "src/lib/chat.ts",
  "src/lib/livekit.ts",
  "src/lib/livekit-token.ts",
  "src/lib/vconsole.ts",
  "src/lib/opentelemetry.ts",
  "src/components/GameCenter.tsx",
  "supabase/migrations/0037_social_games_catalog.sql",
  "supabase/migrations/0038_functional_signup_and_test_room.sql",
  "src/lib/auth.ts",
  "src/lib/gifts.ts",
  "supabase/functions/livekit-token/index.ts",
  "supabase/migrations/0036_call_sessions.sql",
  ".github/workflows/build.yml",
];

const missing = required.filter((file) => !fs.existsSync(path.resolve(file)));
if (missing.length) {
  console.error("Arquivos obrigatórios ausentes:", missing.join(", "));
  process.exit(1);
}

const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
for (const dep of ["react","react-dom","vite","@supabase/supabase-js","livekit-client","livekit-server-sdk"]) {
  if (!pkg.dependencies?.[dep] && !pkg.devDependencies?.[dep]) {
    console.error("Dependência ausente:", dep);
    process.exit(1);
  }
}

const app = fs.readFileSync("src/App.tsx", "utf8");
const gameCenter = fs.readFileSync("src/components/GameCenter.tsx", "utf8");
const edge = fs.readFileSync("supabase/functions/livekit-token/index.ts", "utf8");
const signupMigration = fs.readFileSync("supabase/migrations/0038_functional_signup_and_test_room.sql", "utf8");
const checks = [
  ["EventCalendar integrado", app.includes("EventCalendar")],
  ["room realtime", app.includes("subscribeToRoomSeats")],
  ["chat realtime", app.includes("subscribeToRoomChat")],
  ["diagnóstico", app.includes("diagnosticSnapshot")],
  ["token LiveKit no frontend", app.includes("getLiveKitToken")],
  ["conexão LiveKit", app.includes("connectLiveKitRoom")],
  ["microfone", app.includes("enableMicrophone")],
  ["áudio remoto", app.includes("TrackSubscribed")],
  ["token LiveKit no backend", edge.includes("LIVEKIT_API_SECRET") && edge.includes("AccessToken")],
  ["segurança do token", edge.includes("auth.getUser") && edge.includes("roomJoin: true")],
  ["20 jogos sociais", gameCenter.includes("SOCIAL_GAMES") && gameCenter.includes("jogos jogáveis") && (gameCenter.match(/key:/g) || []).length >= 20],
  ["cadastro", app.includes("signUp") && app.includes("signIn")],
  ["modo teste local", app.includes("MODO TESTE LOCAL") && app.includes("demo-room")],
  ["presentes", app.includes("transferVirtualGift") && app.includes("Presentes virtuais")],
  ["vídeo", app.includes("enableCamera")],
  ["trigger de cadastro", signupMigration.includes("create trigger on_auth_user_created_estreladasorte")],
  ["perfil automático", signupMigration.includes("insert into public.user_profiles")],
  ["carteira inicial", signupMigration.includes("insert into public.user_wallets") && signupMigration.includes("welcome_credits")],
  ["membro USER automático", signupMigration.includes("role_code,display_name,status,metadata") && signupMigration.includes("'USER'")],
  ["sala principal 30 lugares", signupMigration.includes("'sala-principal'") && signupMigration.includes("30,true,true")],
];

const failed = checks.filter(([, ok]) => !ok);
if (failed.length) {
  console.error("Verificações falharam:", failed.map(([name]) => name).join(", "));
  process.exit(1);
}

console.log("ESTRELA QA STATIC: OK");
