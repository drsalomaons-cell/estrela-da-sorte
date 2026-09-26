# Diagnóstico vConsole — ranks, VIP, tarefas e presentes

Data do diagnóstico: 2026-09-26

## Resultado verificado no código atual

O vConsole não implementa nem controla VIP, rank, nível de sala, riqueza, charme, CP, tarefas ou presentes. Ele é uma ferramenta de diagnóstico do front-end.

A auditoria do código atual encontrou:
- room_sessions: sala, status, quantidade de posições, vídeo e chat.
- room_participants: participantes/cadeiras da sala.
- ecosystem_roles: cadeia administrativa Super ADM → ADM Oficial → BD → Agência → Host.
- ecosystem_permissions: permissões por função.
- ecosystem_events: eventos/calendário regional.
- gift_catalog e gift_rules: catálogo e regras de presentes.
- game_registry: catálogo/status dos jogos.
- user_wallets, wallet_ledger, gift_transfers e worker_earnings_ledger: economia virtual interna.

## O que NÃO foi localizado

A busca no código por VIP, riqueza, charme, CP, rank, level, task, tarefa e gift não encontrou módulos front-end específicos com esses nomes.

Isso significa que não é correto afirmar ainda que esses ranks estejam implementados no ESTRELA DA SORTE.

## O que foi implementado neste passo

Foi criado src/lib/diagnostics.ts, que sanitiza campos sensíveis e permite registrar dados observados no vConsole.

A tela principal agora registra no diagnóstico:
1. objeto da sala carregada;
2. participantes/cadeiras carregados;
3. mensagens de chat recebidas.

Tokens, senhas, cookies, chaves e campos de autorização são mascarados antes do log.

## Próxima investigação

Se o vConsole de uma execução mostrar VIP/riqueza/charme/CP/tarefas junto dos dados da sala, o próximo passo é identificar a origem concreta desses campos:
1. resposta de API/fetch;
2. resposta de RPC;
3. payload WebSocket/Realtime;
4. estado local;
5. tabela/consulta Supabase;
6. código de componente.

Só depois dessa identificação devemos criar ou integrar os respectivos módulos no ESTRELA DA SORTE.

## Status
- Auditoria de origem: CONCLUÍDA para o código atualmente acessível.
- Instrumentação diagnóstica: ESCRITA/COMMITADA.
- Build: NÃO EXECUTADO neste ambiente.
- Teste em APK: NÃO EXECUTADO.
- Existência de todos os ranks: NÃO CONFIRMADA.