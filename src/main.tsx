import React from "react";
import { createRoot } from "react-dom/client";
import { App as CapacitorApp } from "@capacitor/app";
import { Capacitor } from "@capacitor/core";
import "./styles.css";
import App from "./App";
import { initVConsole } from "./lib/vconsole";
import { initOpenTelemetry } from "./lib/opentelemetry";
import { I18nProvider } from "./lib/i18n";
import { supabase } from "./lib/supabase";

initVConsole();
initOpenTelemetry();

async function handleAuthRedirect(url: string) {
  if (!supabase || !url) return;

  try {
    const parsed = new URL(url);
    const code = parsed.searchParams.get("code");

    // PKCE flow: Supabase returns ?code=... to the native deep link.
    if (code) {
      const { error } = await supabase.auth.exchangeCodeForSession(code);
      if (error) throw error;
      return;
    }

    // Implicit flow: Supabase can return access/refresh tokens in the URL hash.
    const hash = parsed.hash.startsWith("#") ? parsed.hash.slice(1) : parsed.hash;
    if (hash) {
      const params = new URLSearchParams(hash);
      const accessToken = params.get("access_token");
      const refreshToken = params.get("refresh_token");

      if (accessToken && refreshToken) {
        const { error } = await supabase.auth.setSession({
          access_token: accessToken,
          refresh_token: refreshToken,
        });
        if (error) throw error;
      }
    }
  } catch (error) {
    console.error("[Estrela da Sorte] Falha ao processar retorno OAuth:", error);
  }
}

async function initNativeAuthRedirect() {
  if (!Capacitor.isNativePlatform() || !supabase) return;

  await CapacitorApp.addListener("appUrlOpen", ({ url }) => {
    void handleAuthRedirect(url);
  });

  const launch = await CapacitorApp.getLaunchUrl();
  if (launch?.url) {
    await handleAuthRedirect(launch.url);
  }
}

void initNativeAuthRedirect();

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <I18nProvider><App /></I18nProvider>
  </React.StrictMode>,
);
