# ECONOMIA — PESQUISA, BENCHMARK E PROPOSTA V0.1

Status: RASCUNHO TÉCNICO — NÃO É REGRA OFICIAL E NÃO DEVE SER IMPLEMENTADO COMO ECONOMIA DEFINITIVA.

## 1. Objetivo

Definir uma economia concreta para a Estrela da Sorte aproveitando componentes open source já existentes e referências comerciais que demonstram modelos usados no mercado, sem copiar uma plataforma específica.

Regra de processo:
PESQUISAR → AUDITAR → COMPARAR → SIMULAR → APROVAR → IMPLEMENTAR.

## 2. Pesquisa realizada

### 2.1 TeraLIVE / teraa_live_app_docs — referência de cobertura funcional

O repositório público documenta uma plataforma full-stack de live/social com Flutter, Node/Express, React Admin, painel de Agência e PostgreSQL. Documenta Coin Wallet, VIP, Agency System com 5 níveis e comissão, Host Earnings, withdrawal, Diamond Exchange, rankings, tarefas, presentes e administração.

Classificação: 🟠 referência forte de arquitetura funcional/documentação. A documentação pública não é, sozinha, prova suficiente de produção independente.

### 2.2 ledger — referência técnica de integridade econômica

Repositório MIT de ledger/wallet com dupla entrada, idempotência, holds, PostgreSQL, testes de concorrência e invariantes de conservação.

Classificação: 🟢 referência técnica forte para o núcleo contábil.

### 2.3 Taka Live — referência comercial

Site atual informa que Hosts mantêm 70% de cada presente e que Agências recebem comissão de 4% a 20% sobre ganhos dos Hosts, além de outras regras comerciais.

Classificação: 🟠 referência comercial atual, não open source.

### 2.4 Bigo-style clone / referência comercial

Foi encontrada uma implementação comercial demonstrável que descreve quatro moedas (coins, diamonds, beans e cash), agência, presentes, saque e divisão configurável. O material apresenta como padrão ilustrativo 30% plataforma, 10% agência e 60% Host.

Classificação: 🟠 referência comercial/demonstrativa; não deve ser tratada como open source nem como prova de resultados de mercado.

## 3. Conclusão da pesquisa

Não foi encontrado um único repositório open source verificável que reúna, já pronto e comprovado, toda a cadeia:

Super ADM → ADM Oficial → BD → Agência → Host → produção → comissão escalonada → saque.

Portanto, a estratégia oficial de desenvolvimento deverá ser modular:

A) reaproveitar arquitetura live/social existente quando compatível;
B) reaproveitar padrões de carteira/ledger open source;
C) construir apenas a camada específica de hierarquia e comissão da Estrela da Sorte;
D) não reinventar wallet/ledger se uma implementação compatível puder ser integrada e auditada.

## 4. Princípio econômico

A plataforma não deve maximizar sua porcentagem por operação. O objetivo é manter simultaneamente:

- retorno atraente para o usuário;
- ganho suficientemente atraente para Host;
- comissão suficiente para Agência;
- incentivo real para BD;
- comissão progressiva para ADM Oficial;
- remuneração do Super ADM;
- reserva para eventos e estabilidade;
- margem suficiente para a plataforma pagar infraestrutura, suporte, aquisição e operação.

## 5. 50/50 — análise

50% plataforma / 50% ecossistema é tecnicamente possível como meta, mas não deve ser congelado sem simulação.

As referências encontradas mostram modelos comerciais com participação maior para Hosts, incluindo 70% para Host em Taka Live e um modelo demonstrativo 60% Host / 10% Agência / 30% Plataforma.

Conclusão: 50% para a plataforma é uma margem forte e pode reduzir o incentivo do ecossistema se aplicada de forma rígida. Não deve ser considerada automaticamente inviável, mas deve ser comparada com cenários 45/55 e 40/60.

## 6. Cenários a simular

### Cenário A — 50/50

Plataforma: 50%
Ecossistema: 50%

Proposta de distribuição interna:
Host 28%
Agência 9%
ADM Oficial 6%
BD 4%
Super ADM 1%
Eventos 1%
Reserva 1%

Total ecossistema: 50%.

### Cenário B — 45/55

Plataforma: 45%
Host: 30%
Agência: 10%
ADM Oficial: 7%
BD: 4%
Super ADM: 2%
Eventos: 1%
Reserva: 1%

Total: 100%.

Este é o cenário de referência inicial para simulação porque aumenta o incentivo da rede sem eliminar a margem da plataforma.

### Cenário C — 40/60

Plataforma: 40%
Host: 32%
Agência: 11%
ADM Oficial: 8%
BD: 5%
Super ADM: 2%
Eventos: 1%
Reserva: 1%

Total: 100%.

Este cenário maximiza incentivo ao ecossistema, mas precisa provar que a margem operacional da plataforma permanece sustentável.

## 7. Regra de ADM Oficial

ADM Oficial NÃO será uma comissão administrativa fixa de 2%.

É uma função de expansão da rede.

Cadeia:
Super ADM → ADM Oficial → BD → Agência → Host.

O ADM Oficial só recebe comissão por produção econômica elegível da rede que efetivamente administra, conforme nível.

O cargo não gera automaticamente comissão máxima.

## 8. Níveis de ADM Oficial — estrutura a definir na simulação

Nível 1: entrada após aprovação e cumprimento do requisito mínimo.
Nível 2: produção sustentada.
Nível 3: rede maior e produção maior.
Nível 4: liderança de rede relevante.

A comissão cresce por nível, mas permanece dentro do pool econômico reservado ao ADM Oficial.

Promoção exige produção real e manutenção dos critérios.

## 9. BD

BD é responsável pelo desenvolvimento do candidato até ADM Oficial e pelo acompanhamento da rede conforme sua atribuição.

Cadastro não gera comissão máxima.

A comissão deve depender de:
- Agência ativa;
- produção;
- retenção;
- cumprimento das metas;
- qualidade da rede.

## 10. Super ADM

Super ADM coordena e produz através dos ADMs Oficiais.

Sua remuneração deve estar ligada à produção global elegível da estrutura sob sua responsabilidade, sem criar uma comissão infinita sobre as mesmas operações.

## 11. Agência

A Agência recebe por produção real dos Hosts vinculados e ativos.

A comissão deve ser configurável por nível/contrato, dentro do limite econômico oficial.

## 12. Host

Host deve continuar sendo suficientemente valorizado para permanecer na plataforma.

A produção vem de:
- presentes;
- atividades autorizadas;
- eventos;
- outras fontes econômicas aprovadas.

Estar online, por si só, não cria dinheiro.

## 13. Carteiras

Separar:
1. Coins — consumo.
2. Bônus — promocional, com regras próprias.
3. Earnings/Diamonds — ganhos econômicos.
4. Cash/saque — liquidação.

O nome visual pode variar, mas o ledger central será único.

## 14. Regra contra inflação

Nenhum jogo, presente, evento, ranking, bônus, ADM, Agência, Host ou administrador pode criar valor sacável fora do motor econômico.

Todo valor precisa ter:
- origem;
- operação;
- idempotency key;
- lançamento contábil;
- destino;
- status;
- auditoria.

## 15. Ledger

O motor econômico deverá adotar:
- dupla entrada;
- valores inteiros/minor units;
- append-only;
- idempotência;
- reversão compensatória;
- locks/transações;
- reconciliação;
- saldo disponível versus saldo pendente;
- proteção contra double-spend.

## 16. Eventos e jogos

Jogos e eventos consomem ou distribuem valores dentro de orçamento previamente definido.

Presente da Sorte e outros presentes especiais não poderão criar dinheiro ilimitado.

Fluxo:
Calendário → evento aprovado → missão/presente/jogo → consumo → recompensa autorizada → ledger.

## 17. Decisão de implementação

NÃO implementar os percentuais deste documento ainda.

Primeiro:
1. auditar referências;
2. testar compatibilidade com VoiceHub/Estrela da Sorte;
3. simular os três cenários;
4. definir níveis de ADM Oficial;
5. definir promoção BD → ADM Oficial;
6. definir regras de Agência;
7. definir saque e liquidação;
8. validar sustentabilidade da plataforma;
9. apresentar a versão final para aprovação.

Somente depois:
10. registrar como ECONOMIA OFICIAL;
11. alterar o Dossiê;
12. implementar no código.

## 18. Regra de congelamento

Quando aprovada como ECONOMIA OFICIAL, nenhuma alteração de percentuais, comissões, emissão, conversão, saque ou regras de promoção poderá entrar no código sem revisão e aprovação da nova versão do documento.

