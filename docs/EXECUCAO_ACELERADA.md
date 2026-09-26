# Próxima etapa acelerada — mapa de execução

## 1. Origem dos dados
Instrumentação de diagnóstico já registra sala, participantes e chat no vConsole, com mascaramento de credenciais.

## 2. Ranks
Foi criada uma taxonomia extensível em rank_types e member_ranks para separar domínio de sala, VIP, riqueza, charme, CP e tarefas sem inventar níveis. Os valores reais só devem ser cadastrados quando a origem for comprovada.

## 3. Jogos
Foi criado ciclo de vida explícito planned → prototype → integrated → tested → disabled. O catálogo continua não sendo prova de jogos jogáveis. monetization_mode fica restrito a none/virtual; não há implementação de aposta ou prêmio em dinheiro.

## 4. Calendário
A base ecosystem_events já existe e suporta região, data, recorrência e metadados. A interface de calendário ainda precisa ser ligada a essa tabela.

## 5. Mobile
mobile_release_checks já existe. Build e APK continuam pendentes de execução real; nenhum status foi marcado como tested sem evidência.

## Bloqueios técnicos atuais
- Não há execução local de npm install/npm run build neste ambiente.
- Não há evidência de operação real do Supabase neste ambiente.
- Não há APK real gerado/testado neste ambiente.
- Os 20 nomes do App.tsx continuam sendo catálogo visual, não 20 jogos implementados.

## Próxima ordem
1. identificar origem dos ranks observados;
2. ligar a taxonomia aos dados reais somente após comprovação;
3. implementar interface de calendário sobre ecosystem_events;
4. substituir catálogo visual por registro de jogos não monetários e estados reais;
5. executar build/integração quando houver ambiente de execução e registrar evidências.