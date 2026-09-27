# Integração LiveKit — ESTRELA DA SORTE

## Fluxo implementado
1. Usuário autenticado solicita token ao Supabase Edge Function `livekit-token`.
2. A função valida o JWT do Supabase.
3. O backend usa `LIVEKIT_API_KEY` e `LIVEKIT_API_SECRET`, nunca o navegador.
4. O backend emite JWT LiveKit com `roomJoin`, publicação, assinatura e dados.
5. O frontend recebe somente o token e conecta ao `VITE_LIVEKIT_URL`.
6. A sessão pode ser registrada em `call_sessions`.

## Secrets
Configurar no ambiente da Edge Function:
- LIVEKIT_URL
- LIVEKIT_API_KEY
- LIVEKIT_API_SECRET

No frontend:
- VITE_LIVEKIT_URL
- VITE_SUPABASE_URL
- VITE_SUPABASE_ANON_KEY

## Gate de validação
A implementação de código não equivale a funcionamento comprovado. O gate final exige:
- deploy da Edge Function;
- secrets configurados;
- usuário autenticado;
- conexão de dois clientes na mesma sala;
- áudio publicado/recebido;
- saída da sala;
- verificação de sessão no banco;
- npm install;
- npm run verify;
- npm run build.
