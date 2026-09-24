import { useMemo } from "react";
import { CheckCircle2, CircleAlert, Mic, Radio, Database } from "lucide-react";
import { supabaseConfigured } from "../lib/supabase";
import { livekitConfigured } from "../lib/livekit";

export default function RuntimeStatus(){
  const demoMode = import.meta.env.VITE_DEMO_MODE === "true";
  const items = useMemo(()=>[
    {label:"Sala / 30 cadeiras",ok:true,icon:Radio},
    {label:"Supabase",ok:supabaseConfigured,icon:Database},
    {label:"LiveKit",ok:livekitConfigured,icon:Mic},
  ],[]);
  return <div className="runtimeStatus">
    <div><b>Runtime</b><span>{demoMode?"DEMO CONTROLADO":"PRODUÇÃO"}</span></div>
    {items.map(({label,ok,icon:Icon})=><div key={label} className={ok?"ok":"pending"}>
      <Icon size={15}/><span>{label}</span>{ok?<CheckCircle2 size={14}/>:<CircleAlert size={14}/>}
    </div>)}
  </div>;
}
