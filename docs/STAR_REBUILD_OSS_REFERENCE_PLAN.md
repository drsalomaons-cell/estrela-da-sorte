# STAR — Plano de reconstrução funcional baseado nos dois APKs

Data: 2026-10-01

## Regra principal

Os dois APKs fornecidos pelo titular são referências funcionais. Eles serão usados para identificar fluxos, módulos, estados, telas, comportamento e requisitos de integração.

Não será copiado código, recurso gráfico, marca, texto proprietário, asset ou implementação proprietária dos APKs sem uma licença/autorização que permita isso.

O STAR terá implementação própria. Componentes open source serão incorporados somente quando a licença permitir o uso pretendido e suas obrigações forem registradas.

## Licenciamento

- Código original do STAR: licença proprietária do titular do projeto.
- Componentes open source: mantêm suas licenças originais.
- Apache-2.0, MIT e outras licenças permissivas não transferem a titularidade desses componentes para o titular do STAR.
- Cada componente incorporado deve aparecer no inventário de terceiros com nome, versão, origem, licença e obrigação de NOTICE/atribuição quando aplicável.
- Não declarar que todo o aplicativo é open source nem que toda a propriedade intelectual de terceiros pertence ao STAR.

## Referências funcionais a extrair dos APKs

1. Login/cadastro e retorno correto após OAuth.
2. Login por telefone/e-mail quando existente.
3. Perfil, carteira e estados de conta.
4. Sala e ciclo entrar/sair.
5. Cadeiras, ocupação, troca e estados de usuário.
6. Voz em tempo real e controles de microfone.
7. Vídeo em tempo real quando suportado.
8. Chat de sala e mensagens.
9. Presentes, animações, efeitos e histórico.
10. Moedas/diamantes e ledger econômico.
11. Rankings, níveis, riqueza e tarefas.
12. Jogos de sala.
13. Slots/catálogo de jogos.
14. Rocket/Crash quando tecnicamente presente na referência.
15. PK e eventos de sala.
16. Administração e moderação.
17. Internacionalização.
18. Sons, feedback visual, estados de carregamento e erros.
19. Responsividade e dimensionamento da sala.
20. Fluxos de saída, recarga e saque, sujeitos às regras e integrações efetivamente autorizadas.

## Open source candidato confirmado na pesquisa inicial

### LiveKit
Repositório oficial: https://github.com/livekit/livekit
Licença: Apache-2.0.
Uso candidato: infraestrutura WebRTC de voz, vídeo e dados em tempo real.
O servidor é open source; serviços externos/cloud não devem ser tratados como automaticamente gratuitos.

### AppLooma RTC Samples
Repositório: https://github.com/AppLooma-RTC/Samples
Licença: MIT.
Uso candidato: referência/implementação de telas e fluxos de voice room, video call, chat, gifts e seats. A licença do repositório deve ser conferida novamente na versão exata incorporada.

## Estado do repositório STAR

Branch de trabalho: star-rebuild-oss-reference

O repositório atual já contém:
- GameCenter
- SlotCenter
- lib de gifts
- gameplay
- rooms/room
- chat
- LiveKit
- i18n
- translator
- migrations econômicas
- catálogo de 20 slots
- registro de jogos
- workflows de Android/Supabase

Esses itens ainda precisam ser validados funcionalmente; existência no código não significa que estejam operacionais.

## Critério de conclusão

Uma funcionalidade somente será marcada como PRONTA quando houver:
1. implementação;
2. build sem erro;
3. teste de integração;
4. teste do fluxo de entrada/saída;
5. persistência correta quando aplicável;
6. teste entre pelo menos dois participantes quando for realtime;
7. evidência de funcionamento;
8. licença/origem registrada quando houver terceiro.

## Importante

Os APKs de referência não são tratados como código open source apenas porque foram fornecidos para análise. A extração serve para requisitos e comportamento. Implementação proprietária, assets e código descompilado somente podem ser reutilizados se houver direito/licença para isso.

## Próxima etapa

Completar o inventário funcional dos dois APKs e confrontá-lo com o código atual do STAR; depois selecionar, por módulo, uma implementação open source permissiva e funcional quando existir. Somente então serão feitas alterações de código em blocos testáveis.
