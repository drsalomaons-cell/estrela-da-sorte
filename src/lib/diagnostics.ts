import { logDiagnostic } from "./vconsole";

const SENSITIVE_KEYS = new Set([
  "access_token",
  "refresh_token",
  "token",
  "password",
  "apikey",
  "authorization",
  "cookie",
]);

function sanitize(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sanitize);
  if (!value || typeof value !== "object") return value;

  const source = value as Record<string, unknown>;
  return Object.fromEntries(
    Object.entries(source).map(([key, item]) => [
      key,
      SENSITIVE_KEYS.has(key.toLowerCase()) ? "[redacted]" : sanitize(item),
    ]),
  );
}

export function diagnosticSnapshot(label: string, value: unknown): void {
  logDiagnostic(label, sanitize(value));
}
