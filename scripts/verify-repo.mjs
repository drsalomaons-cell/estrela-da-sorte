import fs from "node:fs";
import path from "node:path";

const required = [
  "package.json",
  "src/App.tsx",
  "src/lib/supabase.ts",
  "src/lib/room.ts",
  "src/lib/chat.ts",
  "src/lib/livekit.ts",
  "src/lib/vconsole.ts",
  "src/lib/opentelemetry.ts",
  ".github/workflows/build.yml",
];

const missing = required.filter((file) => !fs.existsSync(path.resolve(file)));
if (missing.length) {
  console.error("Arquivos obrigatórios ausentes:", missing.join(", "));
  process.exit(1);
}

const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
for (const dep of ["react", "react-dom", "vite", "@supabase/supabase-js", "livekit-client"]) {
  if (!pkg.dependencies?.[dep] && !pkg.devDependencies?.[dep]) {
    console.error("Dependência ausente:", dep);
    process.exit(1);
  }
}

const app = fs.readFileSync("src/App.tsx", "utf8");
const checks = [
  ["EventCalendar integrado", app.includes("EventCalendar")],
  ["room realtime", app.includes("subscribeToRoomSeats")],
  ["chat realtime", app.includes("subscribeToRoomChat")],
  ["diagnóstico", app.includes("diagnosticSnapshot")],
];
const failed = checks.filter(([, ok]) => !ok);
if (failed.length) {
  console.error("Verificações falharam:", failed.map(([name]) => name).join(", "));
  process.exit(1);
}

console.log("ESTRELA QA STATIC: OK");
