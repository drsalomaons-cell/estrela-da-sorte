import React,{useMemo,useState}from"react";
import {Rocket,RefreshCw,Coins,ChevronRight}from"lucide-react";
import {playVirtualSlot}from"../lib/gameplay";
import {useI18n,GAME_NAMES}from"../lib/i18n";

type Slot={key:string;name:string;emoji:string;description:string};
export const SLOTS:Slot[]=[
{key:"STAR_01",name:"Estrela Cósmica",emoji:"⭐",description:"Três rolos com símbolos estelares."},
{key:"STAR_02",name:"Órbita Dourada",emoji:"🪐",description:"Órbita e tesouro dourado."},
{key:"STAR_03",name:"Lua Violeta",emoji:"🌙",description:"Símbolos lunares e violetas."},
{key:"STAR_04",name:"Nebulosa",emoji:"🌌",description:"Combinações cósmicas."},
{key:"STAR_05",name:"Supernova",emoji:"💥",description:"Tema de explosão estelar."},
{key:"STAR_06",name:"Cometa",emoji:"☄️",description:"Velocidade e estrelas cadentes."},
{key:"STAR_07",name:"Galáxia",emoji:"🌠",description:"Símbolos de uma galáxia inteira."},
{key:"STAR_08",name:"Buraco Negro",emoji:"🕳️",description:"Tema espacial escuro."},
{key:"STAR_09",name:"Constelação",emoji:"✨",description:"Forme combinações de constelações."},
{key:"STAR_10",name:"Tesouro Estelar",emoji:"💎",description:"Diamantes, coroas e estrelas."},
{key:"STAR_11",name:"Zeus Cósmico",emoji:"⚡",description:"Tema mitológico original para teste."},
{key:"STAR_12",name:"Cleópatra Cósmica",emoji:"👑",description:"Tema histórico original para teste."},
{key:"STAR_13",name:"Gelo Estelar",emoji:"❄️",description:"Símbolos de gelo e cristais."},
{key:"STAR_14",name:"Foguete",emoji:"🚀",description:"Foguete que sobe conforme o multiplicador."},
{key:"STAR_15",name:"Ovo da Sorte",emoji:"🥚",description:"Ovos, estrelas e prêmios virtuais."},
{key:"STAR_16",name:"Trem Cósmico",emoji:"🚂",description:"Trem espacial em trilhos estelares."},
{key:"STAR_17",name:"Caçador Estelar",emoji:"🏹",description:"Tema de caça espacial original."},
{key:"STAR_18",name:"Creme Cósmico",emoji:"🍨",description:"Tema doce e colorido."},
{key:"STAR_19",name:"Yumi Estelar",emoji:"🌸",description:"Tema floral original para teste."},
{key:"STAR_20",name:"Feijão Estelar",emoji:"🫘",description:"Tema de cultivo e moedas."}
];
const symbols=["⭐","💎","👑","🌙","☄️","🚀","🌌","7️⃣"];
const wagers=[10,50,100,500,1000,5000];

export default function SlotCenter({roomId,walletBalance,onWalletChange}:{roomId:string|null;walletBalance:number;onWalletChange:(n:number)=>void}){
 const{language,t}=useI18n();
 const [selected,setSelected]=useState<Slot|null>(null);
 const [mode,setMode]=useState<"free"|"virtual">("free");
 const [wager,setWager]=useState(100);
 const [reels,setReels]=useState(["⭐","💎","👑"]);
 const [message,setMessage]=useState("Escolha um slot.");
 const [busy,setBusy]=useState(false);
 const [rocketHeight,setRocketHeight]=useState(8);
 const [rocketTarget,setRocketTarget]=useState(5);
 const localSpin=()=>{
   const r=Array.from({length:3},()=>symbols[Math.floor(Math.random()*symbols.length)]);
   setReels(r); const same=r[0]===r[1]&&r[1]===r[2]; const pair=r[0]===r[1]||r[1]===r[2]||r[0]===r[2];
   const mult=same?(r[0]==="7️⃣"?50:12):(pair?2:0);
   if(selected?.key==="STAR_14"){setRocketHeight(Math.min(100,8+mult*2));setMessage(mult>=rocketTarget?"🚀 Meta atingida: foguete subiu!":"🚀 Foguete lançado: continue testando.");}
   else setMessage(mult?"Resultado de teste: "+mult+"x":"Sem combinação nesta rodada.");
 };
 const spin=async()=>{
   if(!selected)return; setBusy(true);
   try{
     if(mode==="free"){localSpin();return;}
     if(walletBalance<wager)throw new Error("Saldo virtual insuficiente.");
     const r=await playVirtualSlot(selected.key,wager,roomId);
     const arr=(r.result?.reels??[]).map((n:number)=>symbols[n-1]??"⭐");
     if(arr.length===3)setReels(arr); onWalletChange(Number(r.balance));
     const mult=Number(r.result?.multiplier??0);
     if(selected.key==="STAR_14")setRocketHeight(Math.min(100,8+mult*2));
     setMessage(mult?"Resultado: "+mult+"x • +"+r.payout+" créditos":"Sem prêmio • -"+r.wager+" créditos");
   }catch(e:any){setMessage(e?.message||"Não foi possível jogar.");}finally{setBusy(false);}
 };
 const label=useMemo(()=>selected?.key==="STAR_14"?"Modo Foguete":"Slot",[selected]);
 if(!selected)return <section className="panel"><div className="panelTitle"><span>🎰 Slots</span><small>{SLOTS.length} {t("slots.title").toLowerCase()} • {t("slots.count").split("•")[1]?.trim()}</small></div><div className="gamegrid">{SLOTS.map(s=><button className="game" key={s.key} onClick={()=>setSelected(s)}><div className="gameIcon">{s.emoji}</div><b>{GAME_NAMES[s.key]?.[language]??s.name}</b><span>{s.description}<ChevronRight size={14}/></span></button>)}</div></section>;
 return <section className="panel"><div className="panelTitle"><span>{selected.emoji} {selected.name}</span><small>{label} • {t("games.balance")} {walletBalance.toLocaleString(language==="en"?"en-US":language==="es"?"es-ES":"pt-BR")}</small></div><button onClick={()=>setSelected(null)}>{t("slots.back")}</button><div className="slotControls"><button className={mode==="free"?"active":""} onClick={()=>setMode("free")}><RefreshCw size={15}/> {t("games.free")}</button><button className={mode==="virtual"?"active":""} onClick={()=>setMode("virtual")}><Coins size={15}/> {t("games.virtual")}</button></div>{mode==="virtual"&&<div className="slotBet"><span>Aposta</span><select value={wager} onChange={e=>setWager(Number(e.target.value))}>{wagers.map(v=><option key={v} value={v}>{v.toLocaleString("pt-BR")} créditos</option>)}</select></div>}{selected.key==="STAR_14"&&<div className="rocketBox"><Rocket size={24}/><div><b>Foguete</b><span>{t("slots.target")}: {rocketTarget}x • {t("slots.height")}: {rocketHeight}%</span></div><select value={rocketTarget} onChange={e=>setRocketTarget(Number(e.target.value))}><option value={2}>2x</option><option value={5}>5x</option><option value={10}>10x</option><option value={20}>20x</option></select></div>}<div className="reels">{reels.map((x,i)=><div key={i}>{x}</div>)}</div><button className="spinBtn" disabled={busy||(mode==="virtual"&&walletBalance<wager)} onClick={()=>void spin()}>{busy?"…":selected.key==="STAR_14"?t("slots.rocket"):t("slots.spin")}</button><div className="gameResult">{message}</div><p className="gameHint">{t("slots.hint")}</p></section>;
}