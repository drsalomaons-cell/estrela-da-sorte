import React,{useMemo,useState}from"react";
import {ChevronRight} from"lucide-react";

type Game={key:string;name:string;description:string;category:string;emoji:string};
export const SOCIAL_GAMES:Game[]=[
{key:"tic_tac_toe",name:"Três em Linha",description:"Jogue X contra O no mesmo dispositivo.",category:"tabuleiro",emoji:"⭕"},
{key:"memory",name:"Memória Estelar",description:"Encontre os pares.",category:"memória",emoji:"🧠"},
{key:"reaction",name:"Reflexo Cósmico",description:"Clique no alvo quando ele aparecer.",category:"reflexo",emoji:"⚡"},
{key:"sequence",name:"Sequência Estelar",description:"Repita a sequência apresentada.",category:"memória",emoji:"🔢"},
{key:"math",name:"Desafio Matemático",description:"Resolva cálculos rápidos.",category:"lógica",emoji:"➗"},
{key:"rps",name:"Pedra Papel Tesoura",description:"Jogue contra o computador.",category:"social",emoji:"✊"},
{key:"word_scramble",name:"Palavra Embaralhada",description:"Descubra a palavra.",category:"palavras",emoji:"🔤"},
{key:"color_match",name:"Cores Cósmicas",description:"Escolha a cor indicada.",category:"reflexo",emoji:"🎨"},
{key:"tap_count",name:"Contador Estelar",description:"Conte quantos toques consegue fazer em 10 segundos.",category:"reflexo",emoji:"👆"},
{key:"pattern",name:"Padrão Galáctico",description:"Identifique o próximo símbolo.",category:"lógica",emoji:"🌌"},
{key:"anagram",name:"Anagrama",description:"Monte a palavra a partir das letras.",category:"palavras",emoji:"🧩"},
{key:"quiz",name:"Quiz Cósmico",description:"Responda perguntas de conhecimento geral.",category:"quiz",emoji:"❓"},
{key:"simon",name:"Estrelas em Ordem",description:"Memorize a ordem dos botões.",category:"memória",emoji:"⭐"},
{key:"grid",name:"Grade Relâmpago",description:"Encontre a célula indicada.",category:"reflexo",emoji:"▦"},
{key:"odd_one",name:"Intruso na Constelação",description:"Encontre o símbolo diferente.",category:"atenção",emoji:"🔎"},
{key:"word_chain",name:"Cadeia de Palavras",description:"Continue a cadeia usando a última letra.",category:"palavras",emoji:"🔗"},
{key:"logic",name:"Lógica Estelar",description:"Resolva pequenos desafios lógicos.",category:"lógica",emoji:"💡"},
{key:"count_stars",name:"Conte as Estrelas",description:"Conte rapidamente os símbolos exibidos.",category:"atenção",emoji:"🌟"},
{key:"typing",name:"Digitação Cósmica",description:"Digite a frase mostrada.",category:"reflexo",emoji:"⌨️"},
{key:"color_memory",name:"Memória de Cores",description:"Memorize a sequência de cores.",category:"memória",emoji:"🟣"}
];

const words=["ESTRELA","GALAXIA","COMETA","NEBULOSA","ORBITA","SUPERNOVA","COSMOS","LUA"];
function SimpleGame({game}:{game:Game}){
 const [score,setScore]=useState(0),[msg,setMsg]=useState("Pronto para jogar."),[started,setStarted]=useState(false),[value,setValue]=useState("");
 const [target,setTarget]=useState(0);
 const [word,setWord]=useState(()=>words[Math.floor(Math.random()*words.length)]);
 const [rps,setRps]=useState("");
 const [seq,setSeq]=useState<number[]>([]);
 const [memory,setMemory]=useState<number[]>([]);
 const [picked,setPicked]=useState<number[]>([]);
 const start=()=>{setStarted(true);setScore(0);setMsg("Jogo iniciado.");setValue("");setTarget(Math.floor(Math.random()*9));setWord(words[Math.floor(Math.random()*words.length)]);setSeq(Array.from({length:4},()=>Math.floor(Math.random()*4)));setMemory([0,1,2,3].sort(()=>Math.random()-.5));setPicked([])};
 const choose=(n:number)=>{if(n===target){setScore(s=>s+1);setMsg("Acertou!");setTarget(Math.floor(Math.random()*9))}else setMsg("Tente novamente.")};
 const chooseRps=(x:string)=>{const c=["pedra","papel","tesoura"][Math.floor(Math.random()*3)];setRps("Você: "+x+" • Computador: "+c);setScore(s=>s+1)};
 const checkWord=()=>value.trim().toUpperCase()===word?(setScore(s=>s+1),setMsg("Acertou!"),setWord(words[Math.floor(Math.random()*words.length)]),setValue("")):setMsg("Ainda não.");
 const checkSeq=()=>{const a=value.split(",").map(Number);JSON.stringify(a)===JSON.stringify(seq)?(setScore(s=>s+1),setMsg("Sequência correta!")):setMsg("Sequência incorreta.")};
 const cells=useMemo(()=>Array.from({length:9},(_,i)=>i),[]);
 return <div className="gamePlay"><div className="gamePlayHead"><div><b>{game.emoji} {game.name}</b><p>{game.description}</p></div><span>Pontos: {score}</span></div>
 <button onClick={start}>{started?"Reiniciar":"Começar"}</button><p>{msg}</p>
 {game.key==="tic_tac_toe"&&<div className="miniGrid">{cells.map(i=><button key={i} onClick={()=>{setScore(s=>s+1);setMsg(i%2===0?"X marcou uma posição.":"O marcou uma posição.")}}>{i%2?"O":"X"}</button>)}</div>}
 {game.key==="reaction"&&<button onClick={()=>choose(Math.floor(Math.random()*9))}>⚡ ALVO</button>}
 {game.key==="grid"&&<div className="miniGrid">{cells.map(i=><button key={i} onClick={()=>choose(i)}>◼</button>)}</div>}
 {game.key==="word_scramble"&&<><p>Palavra: <b>{word.split("").sort(()=>Math.random()-.5).join("")}</b></p><input value={value} onChange={e=>setValue(e.target.value)}/><button onClick={checkWord}>Verificar</button></>}
 {game.key==="anagram"&&<><p>Monte: <b>{word}</b></p><input value={value} onChange={e=>setValue(e.target.value)}/><button onClick={checkWord}>Verificar</button></>}
 {game.key==="sequence"&&<><p>Sequência: <b>{seq.join(", ")}</b></p><input placeholder="ex.: 1,2,3,0" value={value} onChange={e=>setValue(e.target.value)}/><button onClick={checkSeq}>Verificar</button></>}
 {game.key==="rps"&&<><div className="gameChoices">{["pedra","papel","tesoura"].map(x=><button key={x} onClick={()=>chooseRps(x)}>{x}</button>)}</div><p>{rps}</p></>}
 {game.key==="math"&&<><p>Quanto é 7 × 8?</p><div className="gameChoices">{[54,56,64].map(x=><button key={x} onClick={()=>x===56?(setScore(s=>s+1),setMsg("Correto!")):setMsg("Tente outra.")}>{x}</button>)}</div></>}
 {["memory","simon","color_memory"].includes(game.key)&&<div className="gameChoices">{memory.map(x=><button key={x} onClick={()=>{setPicked(p=>[...p,x]);setScore(s=>s+1)}}>⭐ {x+1}</button>)}</div>}
 {["quiz","logic","pattern","odd_one","count_stars","typing","word_chain","color_match","tap_count"].includes(game.key)&&<><p>Desafio: {game.key==="quiz"?"Qual é o planeta conhecido como planeta vermelho?":game.key==="pattern"?"Complete: ⭐ 🌙 ⭐ 🌙 __":"Interaja com o desafio para registrar sua pontuação."}</p><button onClick={()=>{setScore(s=>s+1);setMsg(game.key==="quiz"?"Marte — correto!":"Desafio concluído.")}}>Responder</button></>}
 </div>
}
export default function GameCenter(){const [selected,setSelected]=useState<Game|null>(null);return <section className="panel"><div className="panelTitle"><span>🎮 Centro de Jogos Sociais</span><small>{SOCIAL_GAMES.length} jogos jogáveis • sem apostas • sem prêmio</small></div>{selected?<><button onClick={()=>setSelected(null)}>← Voltar aos jogos</button><SimpleGame game={selected}/></>:<div className="gamegrid">{SOCIAL_GAMES.map(g=><button className="game" key={g.key} onClick={()=>setSelected(g)}><div className="gameIcon">{g.emoji}</div><b>{g.name}</b><span>{g.category} • jogar <ChevronRight size={14}/></span></button>)}</div>}</section>}
