import VConsole from "vconsole";

let instance: VConsole | null = null;

function safeValue(value: unknown): string {
  if (value == null) return "n/a";
  if (typeof value === "string") return value;
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
}

export function initVConsole(): VConsole | null {
  if (typeof window === "undefined" || typeof document === "undefined") return null;
  if (instance) return instance;

  const enabled =
    import.meta.env.DEV ||
    import.meta.env.VITE_ENABLE_VCONSOLE === "true" ||
    new URLSearchParams(window.location.search).get("vconsole") === "1";

  if (!enabled) return null;

  instance = new VConsole({
    theme: "dark",
    defaultPlugins: ["system", "network", "element", "storage"],
    pluginOrder: ["system", "network", "element", "storage"],
    log: {
      maxLogNumber: 1000,
      showTimestamps: true,
    },
    network: {
      maxNetworkNumber: 1000,
    },
    storage: {
      defaultStorages: ["cookies", "localStorage", "sessionStorage"],
    },
    onReady: () => {
      console.info("[Estrela] vConsole inicializado");
      console.log("[Estrela] Ambiente:", import.meta.env.MODE);
      console.log("[Estrela] Rota:", window.location.href.split("?")[0]);
      console.log("[Estrela] User agent:", navigator.userAgent);
    },
  });

  window.addEventListener("error", (event) => {
    console.error("[Estrela] Erro global:", event.error ?? event.message);
  });

  window.addEventListener("unhandledrejection", (event) => {
    console.error("[Estrela] Promise rejeitada:", event.reason);
  });

  console.info("[Estrela] Diagnóstico mobile ativo. Não registrar tokens, cookies de sessão ou credenciais manualmente.");
  return instance;
}

export function getVConsole(): VConsole | null {
  return instance;
}

export function logDiagnostic(label: string, value?: unknown): void {
  if (value === undefined) console.log("[Estrela]", label);
  else console.log("[Estrela]", label, safeValue(value));
}
