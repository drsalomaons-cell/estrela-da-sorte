import { supabase } from "./supabase";

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
