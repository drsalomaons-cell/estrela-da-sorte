import React,{useState}from"react";
import {ChevronRight,Coins,Gamepad2,RefreshCw}from"lucide-react";
import {playVirtualRoomGame}from"../lib/gameplay";\nimport {useI18n,SOCIAL_NAMES}from"../lib/i18n";

type Game={key:string;name:string;description:string;category:string;emoji:string};
export const SOCIAL_GAMES:Game[]=[
{key:"tic_tac_toe",name:"Três em Linha",description:"Jogue X contra O.",category:"tabuleiro",emoji:"⭕"},
{key:"memory",name:"Memória Estelar",description:"Encontre os pares.",category:"memória",emoji:"🧠"},
{key:"reaction",name:"Reflexo Cósmico",description:"Acerte o alvo.",category:"reflexo",emoji:"⚡"},
{key:"sequence",name:"Sequência Estelar",description:"Repita a sequência.",category:"memória",emoji:"🔢"},
{key:"math",name:"Desafio Matemático",description:"Resolva cálculos.",category:"lógica",emoji:"➗"},
{key:"rps",name:"Pedra Papel Tesoura",description:"Jogue contra o computador.",category:"social",emoji:"✊"},
{key:"word_scramble",name:"Palavra Embaralhada",description:"Descubra a palavra.",category:"palavras",emoji:"🔤"},
{key:"color_match",name:"Cores Cósmicas",description:"Escolha a cor indicada.",category:"reflexo",emoji:"🎨"},
{key:"tap_count",name:"Contador Estelar",description:"Faça o maior número de toques.",category:"reflexo",emoji:"👆"},
{key:"pattern",name:"Padrão Galáctico",description:"Identifique o próximo símbolo.",category:"lógica",emoji:"🌌"},
{key:"anagram",name:"Anagrama",description:"Monte a palavra.",category:"palavras",emoji:"🧩"},
{key:"quiz",name:"Quiz Cósmico",description:"Responda perguntas.",category:"quiz",emoji:"❓"},
{key:"simon",name:"Estrelas em Ordem",description:"Memorize a ordem.",category:"memória",emoji:"⭐"},
{key:"grid",name:"Grade Relâmpago",description:"Encontre a célula.",category:"reflexo",emoji:"▦"},
{key:"odd_one",name:"Intruso na Constelação",description:"Encontre o diferente.",category:"atenção",emoji:"🔎"},
{key:"word_chain",name:"Cadeia de Palavras",description:"Continue a cadeia.",category:"palavras",emoji:"🔗"},
{key:"logic",name:"Lógica Estelar",description:"Resolva desafios.",category:"lógica",emoji:"💡"},
{key:"count_stars",name:"Conte as Estrelas",description:"Conte os símbolos.",category:"atenção",emoji:"🌟"},
{key:"typing",name:"Digitação Cósmica",description:"Digite a frase.",category:"reflexo",emoji:"⌨️"},
{key:"color_memory",name:"Memória de Cores",description:"Memorize as cores.",category:"memória",emoji:"🟣"}
];
const wagers=[10,50,100,500,1000,5000];

function SimpleGame({game,mode,wager,roomId,onResult}:{game:Game;mode:"free"|"virtual";wager:number;roomId:string|null;onResult:(balance:number,payout:number,success:boolean)=>void}){
 const [score,setScore]=useState(0); const [msg,setMsg]=useState("Pronto para jogar.");
 const finish=async(success:boolean)=>{
   if(mode==="free"){if(success){setScore(s=>s+1);setMsg("Acertou! Rodada grátis.");}else setMsg("Tentativa registrada.");return;}
   try{const r=await playVirtualRoomGame(game.key,wager,success,roomId);onResult(Number(r.balance),Number(r.payout),success);setScore(s=>s+(success?1:0));setMsg(success?"🏆 Vitória: +"+r.payout+" créditos":"Rodada perdida: -"+r.wager+" créditos");}
   catch(e:any){setMsg(e?.message||"Não foi possível registrar a rodada.");}
 };
 return <div className="gamePlay"><div className="gamePlayHead"><div><b>{game.emoji} {SOCIAL_NAMES[game.key]?.[language]??game.name}</b><p>{game.description}</p></div><span>Pontos: {score}</span></div><p>{msg}</p>
 {game.key==="math"&&<><p>Quanto é 7 × 8?</p><div className="gameChoices">{[54,56,64].map(x=><button key={x} onClick={()=>void finish(x===56)}>{x}</button>)}</div></>}
 {game.key==="rps"&&<div className="gameChoices">{["pedra","papel","tesoura"].map(x=><button key={x} onClick={()=>void finish(Math.random()>.5)}>{x}</button>)}</div>}
 {game.key==="quiz"&&<><p>Qual planeta é conhecido como planeta vermelho?</p><div className="gameChoices"><button onClick={()=>void finish(true)}>Marte</button><button onClick={()=>void finish(false)}>Vênus</button></div></>}
 {game.key==="pattern"&&<><p>Complete: ⭐ 🌙 ⭐ 🌙 __</p><div className="gameChoices"><button onClick={()=>void finish(true)}>⭐</button><button onClick={()=>void finish(false)}>🌞</button></div></>}
 {!["math","rps","quiz","pattern"].includes(game.key)&&<div className="gameChoices"><button onClick={()=>void finish(true)}>🎯 Completar rodada</button><button onClick={()=>void finish(false)}>❌ Falhar rodada</button></div>}
 </div>;
}

export default function GameCenter({roomId,walletBalance,onWalletChange}:{roomId:string|null;walletBalance:number;onWalletChange:(n:number)=>void}){\n const{language,t}=useI18n();
 const [selected,setSelected]=useState<Game|null>(null); const [mode,setMode]=useState<"free"|"virtual">("free"); const [wager,setWager]=useState(100); const [last,setLast]=useState("");
 const chooseResult=(balance:number,payout:number,success:boolean)=>{onWalletChange(balance);setLast(success?"Vitória":"Derrota");};
 if(selected)return <section className="panel"><div className="panelTitle"><span><Gamepad2 size={18}/> {selected.name}</span><small>{t("games.balance")} {walletBalance.toLocaleString(language==="en"?"en-US":language==="es"?"es-ES":"pt-BR")} • {mode==="free"?t("games.free"):t("games.virtual")}</small></div><button onClick={()=>setSelected(null)}>{t("games.back")}</button><div className="slotControls"><button className={mode==="free"?"active":""} onClick={()=>setMode("free")}><RefreshCw size={15}/> {t("games.free")}</button><button className={mode==="virtual"?"active":""} onClick={()=>setMode("virtual")}><Coins size={15}/> {t("games.virtual")}</button></div>{mode==="virtual"&&<div className="slotBet"><span>{t("games.wager")}</span><select value={wager} onChange={e=>setWager(Number(e.target.value))}>{wagers.map(v=><option key={v} value={v}>{v.toLocaleString("pt-BR")} créditos</option>)}</select></div>}<SimpleGame game={selected} mode={mode} wager={wager} roomId={roomId} onResult={chooseResult}/>{last&&<div className="gameResult">Última rodada: {last}</div>}</section>;
 return <section className="panel"><div className="panelTitle"><span><Gamepad2 size={18}/> Jogos de sala</span><small>{SOCIAL_GAMES.length} {t("games.title").toLowerCase()} • {t("games.free")} + {t("games.virtual")}</small></div><div className="gamegrid">{SOCIAL_GAMES.map(g=><button className="game" key={g.key} onClick={()=>setSelected(g)}><div className="gameIcon">{g.emoji}</div><b>{g.name}</b><span>{g.category}<ChevronRight size={14}/></span></button>)}</div></section>;
}