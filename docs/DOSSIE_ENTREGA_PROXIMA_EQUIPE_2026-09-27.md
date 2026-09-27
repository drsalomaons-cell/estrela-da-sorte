# DOSSIÊ DE ENTREGA — ESTRELA DA SORTE
## Estado técnico em 27/09/2026

### 1. Objetivo deste documento
Este documento é o handoff técnico para a próxima equipe responsável pelo ESTRELA DA SORTE. Ele separa claramente:
- o que já foi escrito/integrado;
- o que ainda não foi executado;
- o que precisa de infraestrutura externa;
- o que não foi implementado e deverá ser avaliado pela equipe responsável pela jurisdição de destino;
- o que pode ser testado imediatamente.

**Regra de evidência:** escrito não significa compilado; compilado não significa executado; executado não significa testado; testado não significa produção.

---

# 2. O QUE JÁ FOI FEITO NO REPOSITÓRIO

Repositório: `drsalomaons-cell/estrela-da-sorte`
Branch: `main`

## Base técnica
- React 18 + Vite + TypeScript.
- Supabase client.
- LiveKit client/server SDK preparados.
- Zustand, Tailwind e demais dependências existentes preservadas.
- vConsole para diagnóstico.
- OpenTelemetry opcional.
- pipeline CI configurado com `npm install`, `npm run verify` e `npm run build`.

## Sala
- Estrutura `room_sessions`.
- Até 30 posições técnicas.
- Ocupação/liberação de cadeira.
- Realtime das cadeiras.
- Chat Realtime.
- Estrutura para sala ao vivo.
- Vídeo permanece separado e não é declarado funcional.

## Voz
Foi criada a cadeia técnica LiveKit:
- cliente LiveKit;
- geração segura de token no backend;
- Edge Function `livekit-token`;
- registro de `call_sessions`;
- conexão/desconexão;
- publicação de microfone;
- recepção de áudio remoto;
- diagnóstico de conexão.

**Ainda não há evidência de execução ponta a ponta.**

O LiveKit exige que a criação do token aconteça no backend e que o segredo da API não seja enviado ao cliente. citeturn0search1turn0search7

## Jogos
Foi feita uma mudança importante nesta etapa:

### 20 jogos sociais executáveis no código
1. Três em Linha
2. Memória Estelar
3. Reflexo Cósmico
4. Sequência Estelar
5. Desafio Matemático
6. Pedra Papel Tesoura
7. Palavra Embaralhada
8. Cores Cósmicas
9. Contador Estelar
10. Padrão Galáctico
11. Anagrama
12. Quiz Cósmico
13. Estrelas em Ordem
14. Grade Relâmpago
15. Intruso na Constelação
16. Cadeia de Palavras
17. Lógica Estelar
18. Conte as Estrelas
19. Digitação Cósmica
20. Memória de Cores

Esses módulos foram implementados como jogos sociais **sem aposta, prêmio financeiro ou conversão financeira**.

O `game_registry` também recebeu os 20 registros como `integrated`, `free_mode=true`, `coin_mode=false`, `monetization_mode=none`.

**Importante:** a implementação foi escrita, mas ainda precisa ser compilada e executada para receber o status `tested`.

## Calendário
- `EventCalendar.tsx` criado.
- Integrado ao painel ADM.
- Estrutura consulta `ecosystem_events`.
- Execução contra Supabase ainda não comprovada.

## Diagnóstico/QA
- `scripts/verify-repo.mjs`.
- `npm run verify`.
- `npm run ci`.
- Checklist de release.
- Auditorias documentadas.
- Migration de correção de `gift_events`.

## Economia
As migrations auditadas mantêm a economia interna como virtual. Não deve ser interpretada como prova de operação financeira real.

---

# 3. O QUE FOI DEIXADO FORA E PRECISA FICAR VISÍVEL PARA A PRÓXIMA EQUIPE

Esta seção existe para evitar que alguém receba o repositório e suponha que determinadas funcionalidades já estejam prontas.

## A. Apostas/gambling e mecanismos equivalentes
Não foram implementados:
- apostas com dinheiro;
- apostas usando créditos com valor financeiro;
- retirada/pagamento de prêmio;
- conversão de créditos em dinheiro;
- sistemas de banca;
- odds;
- apostas em resultados;
- jogos de cassino/aposta;
- integração operacional com fornecedor de gambling;
- fluxo de depósito/saque para gambling;
- certificação de jogos de aposta.

Esses itens ficam **fora da implementação atual** e devem ser tratados separadamente pela equipe jurídica, regulatória, técnica e de fornecedores da jurisdição de destino.

**Não marcar esses itens como “já implementados”.**

## B. Jogos do APK CIA
A análise do APK mostrou arquitetura de centro de jogos, carregamento de pacotes, gameId/gameName/gameType, ranking/recompensas e integração com sala de voz.

Entretanto, a análise estática não comprovou uma lista completa de nomes de jogos do CIA.

Portanto:
- não afirmar que todos os nomes do catálogo de referência foram comprovados no APK;
- não copiar código/assets proprietários;
- identificar fornecedor/licença antes de incorporar qualquer pacote externo;
- preservar a documentação como referência, não como prova de propriedade ou licença.

---

# 4. O QUE AINDA FALTA PARA A PRIMEIRA COMPILAÇÃO

## Etapa 1 — ambiente
Executar em máquina com Node:
```
npm install
npm run verify
npm run build
```

**Status atual:** não comprovado neste ambiente.

Se o build falhar, corrigir somente o erro real encontrado e repetir.

## Etapa 2 — Supabase
Configurar projeto real e:
- aplicar migrations em ordem;
- verificar todas as tabelas;
- verificar funções/RPC;
- verificar RLS;
- verificar Auth;
- verificar Realtime;
- verificar `gift_events`;
- verificar `call_sessions`;
- verificar `game_registry`.

As Edge Functions podem ser protegidas por JWT e devem manter a autenticação apropriada. A documentação atual do Supabase recomenda manter `verify_jwt` ativo para funções chamadas por usuários autenticados. citeturn0search0turn0search3

## Etapa 3 — primeira execução web
Depois do build:
- abrir o Vite;
- carregar a aplicação;
- confirmar que a sala aparece;
- confirmar navegação;
- abrir Centro de Jogos;
- abrir cada um dos 20 jogos;
- registrar erros de console;
- confirmar que nenhum jogo quebra a aplicação.

## Etapa 4 — voz
Configurar:
- `VITE_LIVEKIT_URL`;
- `LIVEKIT_API_KEY`;
- `LIVEKIT_API_SECRET`;
- Supabase Edge Function.

Depois:
1. autenticar;
2. entrar na sala;
3. ocupar cadeira;
4. obter token;
5. conectar ao LiveKit;
6. ligar microfone;
7. abrir segundo cliente;
8. verificar áudio nos dois sentidos;
9. sair da sala;
10. verificar encerramento de `call_sessions`.

O segredo LiveKit deve permanecer somente no backend. citeturn0search1turn0search2

---

# 5. O QUE AINDA FALTA PARA O PRIMEIRO APK

Depois do build web/backend estar validado:

1. preparar empacotamento Android;
2. gerar APK de teste;
3. instalar em aparelho 1;
4. instalar em aparelho 2;
5. autenticar nos dois;
6. testar sala;
7. testar voz;
8. testar chat;
9. testar os 20 jogos;
10. registrar falhas;
11. corrigir;
12. gerar novo APK;
13. repetir regressão.

**Nenhum APK deve ser chamado de “aprovado” antes da instalação e execução reais.**

---

# 6. FUNCIONALIDADES AINDA PENDENTES

### Autenticação
- cadastro;
- login;
- logout;
- recuperação;
- sessão;
- perfil;
- RLS ponta a ponta.

### Sala
- teste multiusuário real;
- limite real de 30;
- presença;
- reconexão;
- encerramento.

### Voz
- teste LiveKit ponta a ponta;
- reconexão;
- microfone;
- áudio remoto;
- permissões.

### Vídeo
- ainda não conectado como fluxo funcional.

### Presentes
- interface de presentes ainda não deve ser declarada funcional;
- persistência/transferência precisa ser testada;
- qualquer mecanismo de sorte/aposta/prêmio deve permanecer separado e sujeito à avaliação da equipe de destino.

### Agência / BD / ADM
A estrutura visual existe, mas ainda falta comprovar:
- persistência;
- permissões;
- RLS;
- metas;
- produção;
- histórico;
- relatórios;
- auditoria.

### Revenda
A arquitetura/ideia existe no projeto, mas o fluxo ponta a ponta ainda não foi comprovado.

### Jogos
Os 20 módulos sociais agora estão escritos e integrados, mas precisam de:
- build;
- execução;
- teste individual;
- teste de regressão;
- registro de resultado.

---

# 7. O QUE PODE SER FEITO AGORA

Sem esperar a definição jurídica da jurisdição de destino, a equipe técnica pode:

- compilar o projeto;
- corrigir erros de TypeScript/Vite;
- aplicar e validar migrations;
- testar Auth/RLS;
- testar sala;
- testar Realtime;
- configurar e testar LiveKit;
- testar chat;
- testar os 20 jogos sociais;
- gerar APK;
- instalar em aparelhos;
- fazer testes de regressão;
- completar o painel ADM;
- completar Agência/BD/Host;
- completar calendário;
- melhorar diagnóstico;
- documentar fornecedores/licenças;
- preparar interfaces modulares para futuros provedores.

---

# 8. O QUE NÃO DEVE SER CONFUNDIDO

| Estado | Significado |
|---|---|
| Catalogado | Apenas registrado |
| Escrito | Código criado |
| Integrado | Código conectado à aplicação |
| Compilado | Build executou sem erro |
| Executado | Aplicação foi aberta/executada |
| Testado | Função foi exercitada e resultado registrado |
| Aprovado | Testes e critérios definidos foram satisfeitos |
| Produção | Liberado para operação |

Atualmente, vários itens do ESTRELA estão entre **escrito/integrado**. Não transformar automaticamente esses estados em “testado”.

---

# 9. CHECKLIST DE ENTREGA PARA A PRÓXIMA EQUIPE

### Obrigatório antes de produção
- [ ] npm install
- [ ] npm run verify
- [ ] npm run build
- [ ] Supabase configurado
- [ ] migrations aplicadas
- [ ] Auth testado
- [ ] RLS testado
- [ ] Realtime testado
- [ ] sala testada
- [ ] chat testado
- [ ] LiveKit testado
- [ ] APK gerado
- [ ] APK instalado
- [ ] dois ou mais aparelhos testados
- [ ] 20 jogos testados
- [ ] regressão executada
- [ ] erros críticos corrigidos
- [ ] checklist de release preenchido

### Avaliação separada pela jurisdição de destino
- [ ] regras locais;
- [ ] licenças;
- [ ] certificações;
- [ ] fornecedor de jogos;
- [ ] fornecedor de pagamentos, se aplicável;
- [ ] regras de distribuição;
- [ ] regras de idade/identidade;
- [ ] auditoria;
- [ ] proteção de dados;
- [ ] requisitos de publicação.

---

# 10. RESUMO EXECUTIVO

**Já feito:** núcleo React/Vite/TypeScript, Supabase, sala, cadeiras, chat Realtime, diagnóstico, calendário, LiveKit em código, registry/lifecycle de jogos, CI/QA e 20 jogos sociais não monetários.

**Feito nesta última etapa:** Centro de Jogos com 20 módulos jogáveis, integração no App, migration de registro dos 20 jogos, verificação estática atualizada e documentação de referência do CIA.

**Ainda não comprovado:** build, Supabase real, Auth/RLS, Realtime ponta a ponta, LiveKit ponta a ponta, APK real e testes em aparelhos.

**Deixado explicitamente para avaliação futura:** qualquer operação de apostas/gambling, prêmios financeiros, conversão financeira, fornecedores específicos de gambling e certificações/regulação da jurisdição de destino.

**Primeiro objetivo técnico agora:** fazer `npm install → verify → build`, corrigir os erros reais encontrados e, em seguida, gerar o primeiro APK para teste.

---

## Critério de honestidade do projeto

Nenhuma equipe deve dizer que uma funcionalidade está funcionando somente porque existe código para ela.

O status deve ser baseado em evidência de execução.

**ESTRELA DA SORTE — estado de entrega: código avançado e documentado, aguardando execução real de build, infraestrutura e dispositivos para fechar o primeiro ciclo de testes.**
