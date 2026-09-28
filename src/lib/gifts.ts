import { supabase } from "./supabase";

export type GiftItem = { id:string; gift_key:string; name:string; category:string; virtual_cost_credits:number|null; active:boolean };

export async function listRoomGifts(): Promise<GiftItem[]> {
  if (!supabase) return [];
  const {data,error}=await supabase.from("gift_catalog").select("id,gift_key,name,category,virtual_cost_credits,active").eq("active",true).order("virtual_cost_credits",{ascending:true});
  if(error) throw error;
  return (data??[]) as GiftItem[];
}

export async function getWalletBalance(): Promise<number> {
  if (!supabase) return 0;
  const user=(await supabase.auth.getUser()).data.user;
  if(!user) return 0;
  const {data,error}=await supabase.from("user_wallets").select("balance").eq("user_id",user.id).maybeSingle();
  if(error) throw error;
  return Number(data?.balance??0);
}

export async function transferVirtualGift(
  roomId: string,
  senderUserId: string,
  recipientMemberId: string | null,
  giftId: string,
) {
  if (!supabase) throw new Error("Supabase não configurado");
  const { data, error } = await supabase.rpc("transfer_virtual_gift", {
    p_room_id: roomId,
    p_sender_user_id: senderUserId,
    p_recipient_member_id: recipientMemberId,
    p_gift_id: giftId,
  });
  if (error) throw error;
  return data as {
    transfer_id: string;
    sender_balance: number;
    worker_credits: number;
    gift_cost_credits: number;
    virtual_only: true;
  };
}
