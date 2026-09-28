import { supabase } from "./supabase";

export type GameRoundResult = {
  round_id:string; game_key:string; mode:"free"|"virtual";
  wager:number; payout:number; balance:number; result:any; virtual_only:true;
};

export async function playVirtualSlot(gameKey:string,wager:number,roomId:string|null):Promise<GameRoundResult>{
  if(!supabase) throw new Error("Supabase não configurado");
  const {data,error}=await supabase.rpc("play_virtual_slot",{p_game_key:gameKey,p_wager:wager,p_room_id:roomId});
  if(error) throw error;
  return data as GameRoundResult;
}

export async function playVirtualRoomGame(gameKey:string,wager:number,success:boolean,roomId:string|null):Promise<GameRoundResult>{
  if(!supabase) throw new Error("Supabase não configurado");
  const {data,error}=await supabase.rpc("play_virtual_room_game",{p_game_key:gameKey,p_wager:wager,p_success:success,p_room_id:roomId});
  if(error) throw error;
  return data as GameRoundResult;
}