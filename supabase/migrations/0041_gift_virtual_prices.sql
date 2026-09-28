-- V4.1 — preços virtuais mínimos para os presentes oficiais
update public.gift_catalog
set virtual_cost_credits = case gift_key
  when 'BR_INDEPENDENCE_STAR' then 100
  when 'LUCKY_STAR' then 500
  when 'UNLUCKY_STAR' then 1000
  else virtual_cost_credits
end
where gift_key in ('BR_INDEPENDENCE_STAR','LUCKY_STAR','UNLUCKY_STAR');

alter table public.gift_catalog
  alter column virtual_cost_credits set default 100;

update public.gift_catalog
set virtual_cost_credits = 100
where active=true and (virtual_cost_credits is null or virtual_cost_credits <= 0);
