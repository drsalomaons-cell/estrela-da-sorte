import React, { useEffect, useMemo, useRef, useState } from "react";
import RoleHierarchy from "./components/RoleHierarchy";
import GameCenter from "./components/GameCenter";
import SlotCenter from "./components/SlotCenter";
import EventCalendar from "./components/EventCalendar";
import {
  Gift, Gamepad2, Shield, Users, Settings, Mic, Video,
  MessageCircle, Star, Crown, LogIn, LogOut, RefreshCw,
} from "lucide-react";
import {
  getLiveRoom, getCurrentMemberId, claimSeat, leaveSeat,
  listActiveSeats, subscribeToRoomSeats, RoomSession,
} from "./lib/room";
import { sendRoomMessage, subscribeToRoomChat } from "./lib/chat";
import {
  livekitConfigured, createLiveKitRoom, connectLiveKitRoom,
  enableMicrophone, enableCamera, subscribeLiveKitState, LiveKitMediaState,
} from "./lib/livekit";
import { getLiveKitToken } from "./lib/livekit-token";
import { supabase, supabaseConfigured } from "./lib/supabase";
import { signIn, signUp, signOut, signInWithProvider } from "./lib/auth";
import { listRoomGifts, getWalletBalance, transferVirtualGift } from "./lib/gifts";
import { diagnosticSnapshot } from "./lib/diagnostics";
import { useI18n } from "./lib/i18n";
import { translateText } from "./lib/translator";
import { Track, Room, RoomEvent } from "livekit-client";

function App() {
  const { language, setLanguage, t } = useI18n();
  const [translated, setTranslated] = useState<Record<string, string>>({});
  const [translating, setTranslating] = useState<string | null>(null);
  const translateMessage = async (id: string, body: string) => {
    setTranslating(id);
    try {
      const translatedText = await translateText(body, language);
      setTranslated((v) => ({ ...v, [id]: translatedText }));
    } catch (e: any) {
      setError(e?.message || "Translation unavailable");
    } finally {
      setTranslating(null);
    }
  };

  const [tab, setTab] = useState("sala");
  const [room, setRoom] = useState<RoomSession | null>(null);
  const [seats, setSeats] = useState<any[]>([]);
  const [memberId, setMemberId] = useState<string | null>(null);
  const [chat, setChat] = useState<any[]>([]);
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const [authMode, setAuthMode] = useState<"login" | "signup">("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [authBusy, setAuthBusy] = useState(false);
  const [userEmail, setUserEmail] = useState<string | null>(null);
  const [authReady, setAuthReady] = useState(false);

  const [gifts, setGifts] = useState<any[]>([]);
  const [walletBalance, setWalletBalance] = useState(0);
  const [giftOpen, setGiftOpen] = useState(false);
  const [giftBusy, setGiftBusy] = useState(false);

  const [livekitState, setLivekitState] = useState<LiveKitMediaState | null>(null);
  const [voiceBusy, setVoiceBusy] = useState(false);
  const [voiceError, setVoiceError] = useState("");
  const livekitRoomRef = useRef<Room | null>(null);
  const [callSessionId, setCallSessionId] = useState<string | null>(null);

  const isLoggedIn = Boolean(userEmail);

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      if (!supabase) {
        setRoom({
          id: "demo-room",
          room_key: "demo-room",
          title: "Estrela da Sorte — Modo Teste",
          status: "live",
          seats: 30,
          video_enabled: true,
          chat_enabled: true,
        });
        setMemberId("demo-user");
        setSeats([]);
        setChat([]);
        return;
      }
      const live = await getLiveRoom();
      setRoom(live);
      diagnosticSnapshot("Sala carregada", live);
      if (live) {
        setSeats(await listActiveSeats(live.id));
        const session = (await supabase.auth.getSession()).data.session;
        if (session?.user) {
          setMemberId(await getCurrentMemberId());
          setGifts(await listRoomGifts());
          setWalletBalance(await getWalletBalance());
        } else {
          setMemberId(null);
          setGifts([]);
          setWalletBalance(0);
        }
      } else {
        setSeats([]);
        setMemberId(null);
        setGifts([]);
        setWalletBalance(0);
      }
    } catch (e: any) {
      setError(e?.message || "Não foi possível consultar a sala.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (supabase) {
      void supabase.auth.getSession().then(({ data }) => {
        setUserEmail(data.session?.user.email ?? null);
        setAuthReady(true);
      });
    } else {
      setAuthReady(true);
    }
  }, []);

  useEffect(() => {
    if (isLoggedIn) void load();
    else setLoading(false);
  }, [isLoggedIn]);

  useEffect(() => {
    if (!room || !supabase || !isLoggedIn) return;
    const stopChat = subscribeToRoomChat(room.id, (m) => {
      diagnosticSnapshot("Mensagem de chat recebida", m);
      setChat((v) => [...v, m]);
    });
    const stopSeats = subscribeToRoomSeats(room.id, () => {
      void listActiveSeats(room.id)
        .then(setSeats)
        .catch((e) => setError(e?.message || "Não foi possível atualizar as cadeiras."));
    });
    return () => {
      stopChat();
      stopSeats();
    };
  }, [room, isLoggedIn]);

  useEffect(() => {
    if (!supabase) return;
    const { data } = supabase.auth.onAuthStateChange((_event, session) => {
      setUserEmail(session?.user?.email ?? null);
      if (session?.user) {
        void getCurrentMemberId().then(setMemberId).catch(() => setMemberId(null));
      } else {
        setMemberId(null);
      }
    });
    return () => data.subscription.unsubscribe();
  }, []);

  const occupied = new Map(seats.map((s) => [Number(s.seat_no), s]));
  const mySeat = useMemo(
    () => seats.find((s) => s.member_id === memberId)?.seat_no ?? null,
    [seats, memberId],
  );

  useEffect(() => {
    let disposed = false;
    let stopState: undefined | (() => void);
    let localCallId: string | null = null;
    const connectVoice = async () => {
      if (disposed || !room || !memberId || !mySeat || !livekitConfigured || livekitRoomRef.current) return;
      setVoiceBusy(true);
      setVoiceError("");
      try {
        const auth = await supabase?.auth.getUser();
        const user = auth?.data.user;
        if (!user) throw new Error("Login necessário para conectar a voz");
        const authToken = await getLiveKitToken(room.room_key);
        const lk = createLiveKitRoom();
        livekitRoomRef.current = lk;
        stopState = subscribeLiveKitState(lk, setLivekitState);
        lk.on(RoomEvent.TrackSubscribed, (track) => {
          if (track.kind === Track.Kind.Audio) {
            const el = track.attach();
            el.autoplay = true;
            el.setAttribute("data-livekit-audio", "true");
            document.body.appendChild(el);
          }
        });
        lk.on(RoomEvent.TrackUnsubscribed, (track) => track.detach());
        await connectLiveKitRoom(lk, authToken.token, authToken.url ?? undefined);
        const { data: call, error: callError } = await supabase!
          .from("call_sessions")
          .insert({
            room_id: room.id,
            call_type: "voice",
            livekit_room_name: room.room_key,
            started_by: user.id,
          })
          .select("id")
          .single();
        if (callError) throw callError;
        localCallId = call.id;
        setCallSessionId(call.id);
        diagnosticSnapshot("LiveKit conectado", { room: room.room_key, user: user.id });
      } catch (e: any) {
        if (!disposed) {
          setVoiceError(e?.message || "Não foi possível conectar a voz.");
          diagnosticSnapshot("Falha LiveKit", e?.message);
        }
      } finally {
        if (!disposed) setVoiceBusy(false);
      }
    };
    void connectVoice();
    return () => {
      disposed = true;
      if (stopState) stopState();
      const lk = livekitRoomRef.current;
      livekitRoomRef.current = null;
      setLivekitState(null);
      if (lk) {
        void lk.disconnect();
        lk.removeAllListeners();
      }
      if (localCallId && supabase) {
        void supabase
          .from("call_sessions")
          .update({ status: "ended", ended_at: new Date().toISOString() })
          .eq("id", localCallId);
        setCallSessionId(null);
      }
    };
  }, [room, memberId, mySeat, livekitConfigured]);

  const join = async () => {
    if (!room || !memberId) return;
    setBusy(true);
    setError("");
    try {
      if (!supabase) {
        setSeats((v) =>
          v.some((s) => s.member_id === memberId)
            ? v
            : [...v, { id: "demo-seat", member_id: memberId, seat_no: v.length + 1 }],
        );
        return;
      }
      await claimSeat(room.id, memberId);
      await load();
    } catch (e: any) {
      setError(e?.message || "Não foi possível ocupar a cadeira.");
    } finally {
      setBusy(false);
    }
  };

  const leave = async () => {
    if (!room || !memberId) return;
    setBusy(true);
    setError("");
    try {
      if (!supabase) {
        setSeats((v) => v.filter((s) => s.member_id !== memberId));
        return;
      }
      await leaveSeat(room.id, memberId);
      await load();
    } catch (e: any) {
      setError(e?.message || "Não foi possível sair da cadeira.");
    } finally {
      setBusy(false);
    }
  };

  const toggleMic = async () => {
    const lk = livekitRoomRef.current;
    if (!lk) return;
    setVoiceBusy(true);
    setVoiceError("");
    try {
      await enableMicrophone(lk, !lk.localParticipant.isMicrophoneEnabled);
    } catch (e: any) {
      setVoiceError(e?.message || "Não foi possível alterar o microfone.");
    } finally {
      setVoiceBusy(false);
    }
  };

  const send = async () => {
    if (!room || !message.trim()) return;
    try {
      if (!supabase) {
        setChat((v) => [...v, { id: crypto.randomUUID(), sender_user_id: "demo-user", body: message.trim() }]);
        setMessage("");
        return;
      }
      await sendRoomMessage(room.id, message.trim());
      setMessage("");
    } catch (e: any) {
      setError(e?.message || "Não foi possível enviar a mensagem.");
    }
  };

  const submitAuth = async () => {
    setAuthBusy(true);
    setError("");
    setSuccess("");
    try {
      if (!email.trim() || !password.trim()) {
        throw new Error("Preencha e-mail e senha.");
      }
      if (password.length < 6) {
        throw new Error("A senha precisa ter pelo menos 6 caracteres.");
      }
      if (authMode === "login") {
        const d = await signIn(email.trim(), password);
        setUserEmail(d.user?.email ?? email.trim());
        setSuccess("Login realizado com sucesso.");
      } else {
        if (!displayName.trim()) {
          throw new Error("Informe seu nome para criar a conta.");
        }
        const d = await signUp(email.trim(), password, displayName.trim());
        const identities = d.user?.identities ?? [];

        // Supabase can return an obfuscated user when this e-mail already
        // belongs to an existing confirmed account. Do not tell the user
        // that a new account was created in that case.
        if (!d.session && d.user && identities.length === 0) {
          setAuthMode("login");
          setError(
            "Este e-mail já possui uma conta. Se ela foi criada com Google, entre pelo Google; a senha digitada aqui não foi criada nessa conta.",
          );
        } else if (d.session) {
          setUserEmail(d.user?.email ?? email.trim());
          setSuccess("Conta criada e sessão iniciada.");
        } else {
          setAuthMode("login");
          setSuccess(
            "Conta criada. Se o projeto exigir confirmação por e-mail, confira sua caixa de entrada e depois faça login.",
          );
        }
      }
    } catch (e: any) {
      const msg = e?.message || "Não foi possível concluir a autenticação.";
      if (/invalid login credentials/i.test(msg)) {
        setError("E-mail ou senha incorretos. Se acabou de se cadastrar, confirme o e-mail antes de entrar.");
      } else if (/already registered|already been registered/i.test(msg)) {
        setError("Este e-mail já está cadastrado. Tente entrar.");
        setAuthMode("login");
      } else if (/email not confirmed/i.test(msg)) {
        setError("Confirme seu e-mail antes de entrar. Verifique a caixa de entrada e o spam.");
      } else {
        setError(msg);
      }
    } finally {
      setAuthBusy(false);
    }
  };

  const socialLogin = async (provider: "google" | "facebook") => {
    setAuthBusy(true);
    setError("");
    setSuccess("");
    try {
      await signInWithProvider(provider);
      setSuccess(`Abrindo login com ${provider === "google" ? "Google" : "Facebook"}…`);
    } catch (e: any) {
      setError(
        e?.message ||
          `Login com ${provider} não está disponível. No Supabase é preciso ativar o provedor OAuth.`,
      );
    } finally {
      setAuthBusy(false);
    }
  };

  const logout = async () => {
    try {
      await signOut();
      setUserEmail(null);
      setMemberId(null);
      setSuccess("");
      setError("");
    } catch (e: any) {
      setError(e?.message || "Não foi possível sair.");
    }
  };

  const toggleCamera = async () => {
    const lk = livekitRoomRef.current;
    if (!lk) return;
    setVoiceBusy(true);
    try {
      await enableCamera(lk, !lk.localParticipant.isCameraEnabled);
    } catch (e: any) {
      setVoiceError(e?.message || "Não foi possível alterar a câmera.");
    } finally {
      setVoiceBusy(false);
    }
  };

  const sendGift = async (g: any) => {
    if (!room || !memberId || !g) return;
    setGiftBusy(true);
    try {
      if (!supabase) {
        setWalletBalance((v) => Math.max(0, v - Number(g.virtual_cost_credits ?? 0)));
        setGiftOpen(false);
        return;
      }
      const target = seats.find((s) => s.member_id !== memberId)?.member_id ?? null;
      const result = await transferVirtualGift(room.id, memberId, target, g.id);
      setWalletBalance(Number(result.sender_balance));
      setGiftOpen(false);
    } catch (e: any) {
      setError(e?.message || "Não foi possível enviar o presente.");
    } finally {
      setGiftBusy(false);
    }
  };

  if (!authReady) {
    return (
      <div className="app authScreen">
        <div className="authCard">
          <div className="logo big">★</div>
          <p>Carregando…</p>
        </div>
      </div>
    );
  }

  // ===== TELA DE LOGIN / CADASTRO (antes de entrar) =====
  if (!isLoggedIn) {
    return (
      <div className="app authScreen">
        <div className="authCard">
          <div className="authBrand">
            <div className="logo big">★</div>
            <b>ESTRELA DA SORTE</b>
            <span>Rede social de voz e jogos</span>
          </div>

          <div className="authLang">
            <label>
              {t("language")}
              <select value={language} onChange={(e) => setLanguage(e.target.value as any)}>
                <option value="pt">Português</option>
                <option value="en">English</option>
                <option value="es">Español</option>
              </select>
            </label>
          </div>

          <h2>{authMode === "login" ? t("auth.login") : t("auth.signup")}</h2>

          {error && (
            <div className="notice error">
              <Settings size={16} />
              <span>{error}</span>
            </div>
          )}
          {success && (
            <div className="notice ok">
              <Star size={16} />
              <span>{success}</span>
            </div>
          )}

          <div className="socialRow">
            <button type="button" className="socialBtn" disabled={authBusy} onClick={() => void socialLogin("google")}>
              Google
            </button>
            <button type="button" className="socialBtn" disabled={authBusy} onClick={() => void socialLogin("facebook")}>
              Facebook
            </button>
          </div>

          <div className="divider"><span>ou</span></div>

          {authMode === "signup" && (
            <input
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder={t("auth.name")}
              autoComplete="name"
            />
          )}
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder={t("auth.email")}
            autoComplete="email"
          />
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder={t("auth.password")}
            autoComplete={authMode === "login" ? "current-password" : "new-password"}
          />

          <button className="primaryBtn" onClick={() => void submitAuth()} disabled={authBusy}>
            {authBusy ? t("auth.wait") : authMode === "login" ? t("auth.login") : t("auth.signup")}
          </button>

          <button
            type="button"
            className="linkBtn center"
            onClick={() => {
              setAuthMode(authMode === "login" ? "signup" : "login");
              setError("");
              setSuccess("");
            }}
          >
            {authMode === "login" ? t("auth.switchSignup") : t("auth.switchLogin")}
          </button>
        </div>
      </div>
    );
  }

  // ===== APP PRINCIPAL (só depois do login) =====
  return (
    <div className="app">
      <header>
        <div className="brand">
          <div className="logo">★</div>
          <div>
            <b>ESTRELA DA SORTE</b>
            <span>{userEmail}</span>
          </div>
        </div>
        <div className="headerRight">
          <label className="languagePicker">
            <select value={language} onChange={(e) => setLanguage(e.target.value as any)}>
              <option value="pt">PT</option>
              <option value="en">EN</option>
              <option value="es">ES</option>
            </select>
          </label>
          <button onClick={() => void logout()}>{t("auth.logout")}</button>
        </div>
      </header>

      <nav>
        {(
          [
            ["sala", t("nav.room"), Mic],
            ["jogos", t("nav.games"), Gamepad2],
            ["agencia", t("nav.agency"), Users],
            ["admin", t("nav.admin"), Shield],
          ] as const
        ).map(([id, label, Icon]) => (
          <button className={tab === id ? "active" : ""} onClick={() => setTab(id)} key={id}>
            <Icon size={17} />
            {label}
          </button>
        ))}
      </nav>

      <main>
        {giftOpen && (
          <div className="modalBackdrop">
            <section className="modal">
              <div className="panelTitle">
                <span>
                  <Gift size={18} /> Presentes virtuais
                </span>
                <small>Saldo {walletBalance}</small>
              </div>
              <div className="gamegrid">
                {(gifts.length
                  ? gifts
                  : [
                      { id: "demo1", name: "Estrela", gift_key: "DEMO_STAR", category: "sorte", virtual_cost_credits: 100 },
                      { id: "demo2", name: "Lua", gift_key: "DEMO_MOON", category: "temático", virtual_cost_credits: 250 },
                      { id: "demo3", name: "Supernova", gift_key: "DEMO_NOVA", category: "especial", virtual_cost_credits: 500 },
                    ]
                ).map((g: any) => (
                  <button
                    className="game"
                    key={g.id}
                    onClick={() => void sendGift(g)}
                    disabled={giftBusy || walletBalance < Number(g.virtual_cost_credits ?? 0)}
                  >
                    <div className="gameIcon">🎁</div>
                    <b>{g.name}</b>
                    <span>{g.virtual_cost_credits} créditos</span>
                  </button>
                ))}
              </div>
              <button onClick={() => setGiftOpen(false)}>Fechar</button>
            </section>
          </div>
        )}

        {tab === "sala" && (
          <section>
            <section className="hero">
              <div>
                <small>{t("room.live")}</small>
                <h1>{room?.title || "Sala principal"}</h1>
                <p>
                  {loading
                    ? "Consultando a sala…"
                    : room
                      ? `${room.seats} ${t("room.positions")}`
                      : "Nenhuma sala ao vivo encontrada"}
                </p>
              </div>
              <div className="actions">
                <button onClick={() => void load()}>
                  <RefreshCw size={17} /> {t("room.refresh")}
                </button>
                <button onClick={() => void toggleCamera()} disabled={!livekitState?.connected || voiceBusy}>
                  <Video size={17} /> {t("room.video")}
                </button>
                <button onClick={() => setTab("sala")}>
                  <MessageCircle size={17} /> {t("room.chat")}
                </button>
                <button className="gold" onClick={() => setGiftOpen(true)} disabled={!memberId}>
                  <Gift size={17} /> {t("room.gift")}
                </button>
              </div>
            </section>

            {error && (
              <div className="notice error">
                <Settings size={17} />
                <span>{error}</span>
              </div>
            )}
            {voiceError && (
              <div className="notice">
                <Mic size={17} />
                <span>{voiceError}</span>
              </div>
            )}

            {!loading && room && (
              <section className="panel">
                <div className="panelTitle">
                  <span>
                    <Crown size={18} /> {t("room.seats")}
                  </span>
                  <small>
                    {seats.length}/{room.seats} {t("room.occupied")} • máximo 30
                  </small>
                </div>
                <div className="roomActions">
                  {memberId ? (
                    mySeat ? (
                      <>
                        <button onClick={() => void toggleMic()} disabled={voiceBusy || !livekitState?.connected}>
                          <Mic size={16} />
                          {livekitState?.microphoneEnabled ? t("room.micOff") : t("room.micOn")}
                        </button>
                        <button onClick={() => void leave()} disabled={busy}>
                          <LogOut size={16} /> {t("room.leave")} {mySeat}
                        </button>
                      </>
                    ) : (
                      <button onClick={() => void join()} disabled={busy}>
                        <LogIn size={16} /> {t("room.join")}
                      </button>
                    )
                  ) : (
                    <span>{t("room.loginRequired")}</span>
                  )}
                  {voiceBusy && <span>{t("room.connecting")}</span>}
                </div>
                <div className="seats">
                  {Array.from({ length: room.seats }, (_, i) => i + 1).map((n) => {
                    const s = occupied.get(n);
                    return (
                      <div className={"seat " + (s ? "live" : "")} key={n}>
                        <div className="avatar">{s ? "★" : "+"}</div>
                        <b>{s ? "Membro " + String(s.member_id).slice(0, 6) : "Cadeira " + n}</b>
                        <span>{s ? t("room.occupied") : t("room.free")}</span>
                      </div>
                    );
                  })}
                </div>
              </section>
            )}

            {room?.chat_enabled && (
              <section className="panel chatPanel">
                <div className="panelTitle">
                  <span>
                    <MessageCircle size={18} /> {t("room.chatTitle")}
                  </span>
                  <small>{t("room.realtime")}</small>
                </div>
                <div className="chatList">
                  {chat.slice(-30).map((m) => (
                    <div className="chatMsg" key={String(m.id)}>
                      <b>{String(m.sender_user_id).slice(0, 8)}</b>
                      <span>{translated[String(m.id)] || String(m.body)}</span>
                      {memberId && (
                        <button
                          className="translateBtn"
                          onClick={() => void translateMessage(String(m.id), String(m.body))}
                          disabled={translating === String(m.id)}
                        >
                          {translating === String(m.id) ? "…" : t("chat.translate")}
                        </button>
                      )}
                      {translated[String(m.id)] && (
                        <small className="translatedLabel">{t("chat.translated")}</small>
                      )}
                    </div>
                  ))}
                </div>
                <div className="chatInput">
                  <input
                    value={message}
                    maxLength={1000}
                    onChange={(e) => setMessage(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") void send();
                    }}
                    placeholder={memberId ? t("chat.placeholder") : t("chat.loginPlaceholder")}
                  />
                  <button onClick={() => void send()} disabled={!memberId || !message.trim()}>
                    {t("chat.send")}
                  </button>
                </div>
              </section>
            )}
          </section>
        )}

        {tab === "jogos" && (
          <>
            <GameCenter roomId={room?.id ?? null} walletBalance={walletBalance} onWalletChange={setWalletBalance} />
            <SlotCenter roomId={room?.id ?? null} walletBalance={walletBalance} onWalletChange={setWalletBalance} />
          </>
        )}

        {tab === "agencia" && (
          <section className="panel">
            <div className="panelTitle">
              <span>
                <Users size={18} /> Agência & Hosts
              </span>
              <small>estrutura preparada</small>
            </div>
            <div className="cards">
              <div className="card">
                <Star />
                <b>Agência</b>
                <p>Equipe, convites, metas, resultados e hosts vinculados.</p>
              </div>
              <div className="card">
                <Mic />
                <b>Host</b>
                <p>Entrada por convite, sala, metas e desempenho.</p>
              </div>
              <div className="card">
                <Crown />
                <b>BD</b>
                <p>Acompanhamento de agências ativas e desempenho.</p>
              </div>
            </div>
          </section>
        )}

        {tab === "admin" && (
          <>
            <section className="panel">
              <div className="panelTitle">
                <span>
                  <Shield size={18} /> Central ADM
                </span>
                <small>controle por função</small>
              </div>
              <RoleHierarchy />
              <div className="notice">
                <Settings size={17} />
                <span>Permissões devem ser aplicadas no backend Supabase.</span>
              </div>
            </section>
            <EventCalendar />
          </>
        )}
      </main>

      <footer>
        <span>Estrela da Sorte • Fundação 0.5</span>
        <span>
          {supabaseConfigured ? "Backend Supabase" : "MODO TESTE LOCAL"} • Carteira:{" "}
          <b>{walletBalance} créditos</b>
        </span>
      </footer>
    </div>
  );
}

export default App;
