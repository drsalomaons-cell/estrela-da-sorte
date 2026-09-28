// CI trigger: QA funcional reforçado em 2026-09-28
import fs from "node:fs";
import path from "node:path";

const required = [
  "package.json","src/App.tsx","src/lib/supabase.ts","src/lib/room.ts","src/lib/chat.ts",
  "src/lib/livekit.ts","src/lib/livekit-token.ts","src/lib/vconsole.ts","src/lib/opentelemetry.ts",
  "src/components/GameCenter.tsx","supabase/migrations/0037_social_games_catalog.sql",
  "supabase/migrations/0038_functional_signup_and_test_room.sql","src/lib/auth.ts","src/lib/gifts.ts",
  "supabase/functions/livekit-token/index.ts","supabase/migrations/0036_call_sessions.sql",".github/workflows/build.yml",
];
const missing=required.filter(file=>!fs.existsSync(path.resolve(file)));
if(missing.length){console.error("Arquivos obrigatórios ausentes:",missing.join(", "));process.exit(1);}
const pkg=JSON.parse(fs.readFileSync("package.json","utf8"));
for(const dep of ["react","react-dom","vite","@supabase/supabase-js","livekit-client","livekit-server-sdk"]){
 if(!pkg.dependencies?.[dep]&&!pkg.devDependencies?.[dep]){console.error("Dependência ausente:",dep);process.exit(1);}
}
const app=fs.readFileSync("src/App.tsx","utf8");
const gameCenter=fs.readFileSync("src/components/GameCenter.tsx","utf8");
const edge=fs.readFileSync("supabase/functions/livekit-token/index.ts","utf8");
const signup=fs.readFileSync("supabase/migrations/0038_functional_signup_and_test_room.sql","utf8");
const checks=[
["EventCalendar",app.includes("EventCalendar")],["room realtime",app.includes("subscribeToRoomSeats")],
["chat realtime",app.includes("subscribeToRoomChat")],["diagnóstico",app.includes("diagnosticSnapshot")],
["LiveKit token frontend",app.includes("getLiveKitToken")],["LiveKit connection",app.includes("connectLiveKitRoom")],
["microfone",app.includes("enableMicrophone")],["áudio remoto",app.includes("TrackSubscribed")],
["LiveKit backend",edge.includes("LIVEKIT_API_SECRET")&&edge.includes("AccessToken")],
["token auth",edge.includes("auth.getUser")&&edge.includes("roomJoin: true")],
["20 jogos",gameCenter.includes("SOCIAL_GAMES")&&gameCenter.includes("jogos jogáveis")&&(gameCenter.match(/key:/g)||[]).length>=20],
["cadastro",app.includes("signUp")&&app.includes("signIn")],["modo teste",app.includes("MODO TESTE LOCAL")&&app.includes("demo-room")],
["presentes",app.includes("transferVirtualGift")&&app.includes("Presentes virtuais")],["vídeo",app.includes("enableCamera")],
["trigger cadastro",signup.includes("create trigger on_auth_user_created_estreladasorte")],
["perfil",signup.includes("insert into public.user_profiles")],["carteira",signup.includes("insert into public.user_wallets")&&signup.includes("welcome_credits")],
["USER",signup.includes("'USER'")],["sala 30",signup.includes("'sala-principal'")&&signup.includes("30,true,true")],
];
const failed=checks.filter(([,ok])=>!ok);
if(failed.length){console.error("Verificações falharam:",failed.map(([n])=>n).join(", "));process.exit(1);}
console.log("ESTRELA QA STATIC: OK");
