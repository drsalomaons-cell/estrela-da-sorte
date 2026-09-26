# AUDITORIA FINAL — 26/09/2026

## Cinco etapas conclusivas aplicadas

1. **CI de build**
   - O workflow `.github/workflows/build.yml` já existia.
   - Foi corrigido para não depender de `package-lock.json` no cache do setup-node.
   - Ele executa `npm install` e `npm run build` em push/PR.
   - **Status:** configuração corrigida; execução deste commit ainda não foi observada neste ambiente.

2. **Calendário regional**
   - Criado `src/components/EventCalendar.tsx`.
   - A interface consulta `ecosystem_events` diretamente pelo Supabase.
   - Mostra região, data e recorrência.
   - Integrado ao painel ADM.
   - **Status:** código escrito; operação Supabase não comprovada aqui.

3. **Catálogo de jogos**
   - O ciclo de vida do `game_registry` permanece `planned → prototype → integrated → tested → disabled`.
   - A interface foi corrigida para não chamar os 20 nomes de jogos implementados.
   - **Status:** catálogo não é prova de jogo executável; não há afirmação de 20 jogos testados.

4. **Integridade dos diagnósticos**
   - vConsole + diagnóstico sanitizado permanecem ativos em desenvolvimento/ativação explícita.
   - OpenTelemetry web permanece opcional.
   - Sala, participantes e chat têm pontos de diagnóstico.
   - **Status:** código presente; não houve execução de navegador neste ambiente.

5. **Gate final de release**
   - A documentação registra explicitamente o que é código, o que é configuração e o que ainda depende de execução real.
   - Nenhum build, APK, Supabase, LiveKit, autenticação, RLS ou Realtime é declarado como aprovado sem evidência.
   - **Status:** gate documental concluído.

## Resultado da auditoria

### Confirmado no repositório
- React + Vite + TypeScript.
- Supabase client configurado por variáveis de ambiente.
- Estrutura de sala com até 30 posições.
- Chat e ocupação de cadeiras ligados a funções Supabase/Reatime no código.
- vConsole e sanitização de diagnósticos.
- OpenTelemetry opcional.
- Taxonomia extensível de ranks.
- Ciclo de vida do catálogo de jogos.
- Base de calendário regional.
- Economia virtual explicitamente separada de dinheiro real nas migrations auditadas.
- Workflow de build presente.

### Não comprovado por execução
- `npm install` / `npm run build` neste ambiente.
- Operação real do projeto Supabase.
- Login/cadastro/logout/recuperação ponta a ponta.
- RLS ponta a ponta.
- Realtime ponta a ponta.
- LiveKit/voz ponta a ponta.
- APK/AAB real em aparelho.
- 20 jogos executáveis e testados.
- Painéis completos de Agência/BD/ADM com persistência real.
- Revenda e demais fluxos administrativos ponta a ponta.

## Problemas/pendências relevantes encontrados

### 1. Build
O repositório não possui `package-lock.json`. O CI foi ajustado para usar `npm install`, evitando o cache npm que exigiria lockfile.

### 2. Sala
O código da sala está preparado para até 30 posições, mas a existência de uma sala `live` e a execução das RPCs dependem do Supabase real.

### 3. LiveKit
A interface apenas verifica configuração de LiveKit; a chamada de voz ainda não aparece como fluxo efetivamente conectado na tela auditada.

### 4. Jogos
Os 20 nomes presentes em `App.tsx` continuam sendo catálogo visual. Isso foi corrigido na interface para não apresentá-los como implementados.

### 5. Calendário
Agora existe interface ligada à tabela real, mas sem execução contra um projeto Supabase não é possível declarar funcionamento ponta a ponta.

## Conclusão

O repositório está **mais fechado e auditável**, mas **não é correto declarar o aplicativo 100% testado ou pronto para produção**. O bloqueio restante é principalmente de execução externa: ambiente Node/build, projeto Supabase, LiveKit e dispositivos Android.

A regra de status usada nesta auditoria é: **escrito ≠ compilado ≠ executado ≠ testado ≠ produção**.
