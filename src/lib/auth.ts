import { supabase } from "./supabase";

function getOAuthRedirectTo(): string {
  if (typeof window === "undefined") {
    return "https://fjkhdokdwvpyidgunoes.supabase.co";
  }

  const origin = window.location.origin;
  const href = window.location.href;

  // Capacitor Android / iOS WebView
  if (
    origin.startsWith("capacitor://") ||
    origin.startsWith("http://localhost") ||
    origin.startsWith("https://localhost") ||
    href.startsWith("file://")
  ) {
    return "com.estreladasorte.app://auth/callback";
  }

  return origin;
}

export async function signIn(email: string, password: string) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) throw error;
  return data;
}

export async function signUp(email: string, password: string, displayName: string) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { display_name: displayName } },
  });
  if (error) throw error;
  return data;
}

export async function signOut() {
  if (!supabase) return;
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
}

export async function signInWithProvider(provider: "google" | "facebook") {
  if (!supabase) throw new Error("Supabase não configurado");
  const redirectTo = getOAuthRedirectTo();
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider,
    options: {
      redirectTo,
      skipBrowserRedirect: false,
    },
  });
  if (error) throw error;
  return data;
}
