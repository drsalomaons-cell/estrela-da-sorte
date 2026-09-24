-- V2.0 — resolução de presentes sem saldo real
create or replace function public.resolve_gift_simulation(p_gift_id uuid)
returns jsonb language plpgsql security definer set search_path=public as $$
declare g public.gift_catalog%rowtype; rule public.gift_rules%rowtype;
begin
 select * into g from public.gift_catalog where id=p_gift_id and active=true;
 if not found then raise exception 'Gift not found'; end if;
 select * into rule from public.gift_rules where gift_id=g.id and enabled=true limit 1;
 if not found then raise exception 'Gift rule not found'; end if;
 return jsonb_build_object('gift',g.gift_key,'category',g.category,'lucky',rule.lucky,'animation',rule.animation_key,'drop_weight',rule.drop_weight,'simulation_only',true);
end; $$;
