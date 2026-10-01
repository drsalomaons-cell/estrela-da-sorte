# STAR — REFERENCIA FUNCIONAL DOS APKS E PLANO DE RECONSTRUCAO

Data: 2026-10-01
Base: branch star-rebuild-reference-analysis

## Objetivo
Reconstruir a plataforma Star sobre o repositorio existente, usando os dois pacotes APKS fornecidos pelo usuario como referencia funcional e de produto, sem copiar codigo, identidade visual ou recursos proprietarios.

## Pacotes analisados
- Crush Live: com.starlink.crushlive
  - APKS com base.apk + arm64_v8a + xxhdpi
  - ~225.6 MB descompactado
  - base.apk ~105.9 MB
  - 5 DEX
  - ~2.211 assets
  - ~5.155 recursos res/
- Fomi Party: tuo.ba.party.chat
  - APKS com base.apk + arm64_v8a
  - ~87.7 MB descompactado
  - base.apk ~74.1 MB
  - 3 DEX
  - ~165 assets
  - ~3.327 recursos res/

## Funcionalidades identificadas
### Identidade e entrada
- login
- cadastro
- email/senha
- Google
- Facebook
- telefone
- auto-login
- troca de login
- perfil
- nivel
- tarefas

### Sala
- entrar/sair
- sala de voz
- sala de video
- assentos/microfones
- troca de assento
- espectadores
- chat
- presentes
- gift box
- lucky gift
- PK
- multiplos PK
- ranking
- jogos
- efeitos e animacoes

### Economia
- gold coin/moeda
- diamond/diamante
- recarga
- itens de recarga
- pacotes
- presentes com valor
- recompensa
- lucky bag
- transferencia de moedas
- nivel de presente
- nivel de riqueza
- tarefas
- rankings
- pagamentos Google
- carteira/fluxos de saldo

### Conteudo e jogos
- Ludo identificado no Fomi
- Lucky Rocket identificado nos dois
- PK de sala
- PK de video
- ranking de jogos
- ranking de presentes
- ranking de salas
- eventos
- fireworks
- CP/relacionamentos
- familia
- rebate/bonus
- efeitos de presentes

## Evidencia visual/tecnica importante
Crush:
- bg_gift_*
- bg_pk_*
- charge_item_*
- gold_coin_*
- room_ranking_*
- party_room_pk_*
- mul_video_pk_*
- audio_seat_*
- video_seat_*
- seat_change_*
- live_task_*
- task_level_*
- common_google_signin_*
- com_facebook_*
- pag_lucky_rocket1..5
- pk_sound.mp3
- classes/fluxos: LoginTelRegisterAndResetActivity, LoginSwitchActivity, LoginCountryListActivity, MainActivity, LiveRoomPlayActivity, LiveRoomPushActivity, GameListActivity, GiftFragment, GiftManagerView, GiftViewModel, PartySeatDialog, SeatChangeDialog, RoomSettingDialog, PartyRoomSettingFragment, LivePkManager, PkListViewModel, UserProfileActivity.

Fomi:
- diamond_add
- diamond_reward
- diamond_rotate
- mic_diamond
- lucky_gift
- lucky_bag
- gift_number_10..10000
- rocket_small_level_1..5
- rocket_large_level_1..5 com gif/launch/luck
- pk_hs / pk_lan / pk_pingju em varios idiomas
- pk_time
- room_rank_1..3
- gift_rank_1..3
- game_rank_1..3
- room_luxu_bg
- active_fireworks
- Ludo
- CP/family assets
- 137 assets diretamente relacionados a sala/economia/jogos/ranking foram encontrados no inventario filtrado.

## Contagem de recursos por categoria
Crush (nomes de arquivo no base.apk):
- login 92
- sala/assento 285
- chat 352
- presentes 172
- economia 207
- jogos/PK 281
- ranking 44
- perfil/niveis/familia/CP 622
- video 548
- audio/voz 146

Fomi:
- sala/assento 112
- presentes 34
- economia 9
- jogos/PK 59
- ranking 13
- perfil/niveis/familia/CP 43
- assets filtrados de sala/economia/jogos/ranking: 137

## Regra de engenharia
Nao copiar codigo proprietario, backend, chaves, endpoints privados, identidade visual ou assets proprietarios. Reproduzir apenas comportamentos e requisitos de produto com implementacao propria e componentes/licencas permissivos.

## Base atual do Star
O repositorio ja possui:
- React 18 + Vite + TypeScript
- Supabase
- LiveKit client/server token
- salas
- assentos
- chat realtime
- presentes
- carteira virtual
- 20 slots/catalogo
- registro de jogos
- lifecycle de jogos
- economia/ledger
- rankings
- roles e permissoes
- reseller economy
- profile assets/registration
- Capacitor Android
- GitHub Actions para APK

## Arquitetura alvo
Separar telas e responsabilidades:
1. Splash
2. Login
3. Cadastro
4. OAuth callback
5. Recuperacao
6. Home
7. Lista de salas
8. Sala
9. Perfil
10. Carteira/recarga
11. Presentes
12. Jogos
13. Rankings
14. Tarefas/recompensas
15. Host/Agencia
16. Admin
17. Configuracoes

A sala nao deve ser misturada com login/cadastro.

## Sala alvo
- capacidade configuravel ate 30
- layout responsivo
- assentos uniformes
- tamanho natural para celular
- scroll apenas quando necessario
- voz e video realtime
- chat realtime
- presentes com animacao
- foguete/crash com motor proprio
- jogos em painel separado
- eventos e ranking sem quebrar a sala

## Economia alvo
Manter ledger auditavel e regras do Star. Nao copiar valores economicos dos apps de referencia.
Fluxo base:
recarga -> moedas -> presentes/jogos -> diamantes/recompensas -> regras de host/agencia/BD -> saque autorizado.

## Login OAuth
Fluxo alvo:
botao -> provedor -> callback -> sessao Supabase -> retorno para Home, sem deixar usuario preso na tela externa.
Google/Facebook/telefone devem ser tratados como fluxos separados.

## Bases open source encontradas
- LiveKit server: Apache-2.0; adequado para realtime de voz/video. O Star ja usa LiveKit. 
- TUILiveKit: repositorio MIT, com UI de live, voz/video, presentes, gerenciamento de sala e co-hosting. E uma referencia tecnica forte, mas depende dos servicos Tencent para funcionar integralmente.
- LibreLudo/libreludo: Ludo open source com React/Vite/TypeScript, MIT/AGPL conforme a variante; usar apenas depois de verificar licenca do repositorio escolhido.
- Ludo multiplayer de BiswajitSen: React/TypeScript + WebSocket + WebRTC/LiveKit, com logica server-authoritative.
- Crash Game Demo de cristianmarcu: Phaser, foguete, multiplicador, cash-out, som e canvas responsivo; BSD-2-Clause segundo o repositorio. Serve como referencia/possivel base, mas requer auditoria antes de integrar.
- TUILiveKit possui componentes de presentes e gerenciamento de sala, mas seu uso pode exigir servicos/credenciais Tencent; portanto nao sera tratado como 'custo zero' ate validar a infraestrutura.

## QA
Cada grande alteracao deve:
1. revisar novamente os dois APKS;
2. revisar codigo Star;
3. aplicar mudanca isolada;
4. compilar;
5. testar fluxos disponiveis;
6. repetir revisao dos APKS;
7. registrar resultado.

Teste fisico em Android depende de dispositivo conectado; no momento nao ha Desktop Commander conectado.

## Progresso da analise
Estimativa atual: ~45%.
Ja extraido: estrutura dos pacotes, DEX, recursos, assets, categorias, classes/fluxos relevantes, economia, sala, jogos, login e referencias de arquitetura.
Falta para 90%:
- inventario completo de recursos/textos/telas;
- extracao sistematica de nomes de classes/activities/servicos;
- mapa completo de navegacao;
- catalogo completo de jogos e presentes;
- analise de audio/video/animacoes e dimensoes;
- comparacao tela a tela com Star;
- levantamento de licencas e bases open source modulo a modulo;
- implementacao e testes de integracao;
- teste fisico em Android.

## Infraestrutura open source
LiveKit foi confirmado como Apache-2.0. TUILiveKit foi confirmado como MIT, mas exige servicos Tencent para uso completo. O Star deve priorizar componentes self-hosted/licenca permissiva e manter economia/backend proprios.
