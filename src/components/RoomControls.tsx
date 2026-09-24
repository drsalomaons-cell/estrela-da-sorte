import { useState } from "react";
import { Mic, MicOff, Video, VideoOff, MessageCircle, LogIn } from "lucide-react";

export default function RoomControls(){
  const [seat,setSeat]=useState<number|null>(null);
  const [mic,setMic]=useState(false);
  const [video,setVideo]=useState(false);
  const [chat,setChat]=useState(true);
  return <div className="roomControls">
    <div className="controlLine"><b>Teste da sala</b><span>{seat ? "cadeira "+seat : "nenhuma cadeira selecionada"}</span></div>
    <div className="controlButtons">
      <button onClick={()=>setSeat(seat?null:1)}><LogIn size={16}/>{seat?"Sair da cadeira":"Entrar na cadeira 1"}</button>
      <button disabled={!seat} onClick={()=>setMic(v=>!v)}>{mic?<Mic size={16}/>:<MicOff size={16}/>} {mic?"Microfone ligado":"Microfone desligado"}</button>
      <button disabled={!seat} onClick={()=>setVideo(v=>!v)}>{video?<Video size={16}/>:<VideoOff size={16}/>} {video?"Vídeo ligado":"Vídeo desligado"}</button>
      <button onClick={()=>setChat(v=>!v)}><MessageCircle size={16}/>{chat?"Chat ligado":"Chat desligado"}</button>
    </div>
    <small>Este modo valida a interface e o fluxo local. Voz/vídeo reais exigem Supabase + token LiveKit configurados.</small>
  </div>;
}
