import { trace, SpanStatusCode } from "@opentelemetry/api";
import {
  ConsoleSpanExporter,
  SimpleSpanProcessor,
  WebTracerProvider,
} from "@opentelemetry/sdk-trace-web";

let initialized = false;

export function initOpenTelemetry(): void {
  if (initialized || typeof window === "undefined") return;

  const enabled =
    import.meta.env.DEV ||
    import.meta.env.VITE_ENABLE_OPENTELEMETRY === "true" ||
    new URLSearchParams(window.location.search).get("otel") === "1";

  if (!enabled) return;

  const provider = new WebTracerProvider({
    spanProcessors: [new SimpleSpanProcessor(new ConsoleSpanExporter())],
  });

  provider.register();
  initialized = true;

  const tracer = trace.getTracer("estrela-da-sorte", "0.1.0");
  const span = tracer.startSpan("estrela.app.start");
  span.setAttribute("app.environment", import.meta.env.MODE);
  span.setAttribute("app.route", window.location.pathname);
  span.setAttribute("app.user_agent", navigator.userAgent);
  span.setStatus({ code: SpanStatusCode.OK });
  span.end();

  console.info("[Estrela][OTel] tracing web ativo");
}
