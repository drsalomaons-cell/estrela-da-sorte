-- V2.3 — checklist de prontidão Android/loja
create table if not exists public.mobile_release_checks (
 check_key text primary key,
 description text not null,
 status text not null default 'pending' check(status in ('pending','pass','fail','blocked')),
 evidence text
);
insert into public.mobile_release_checks(check_key,description) values
('WEB_BUILD','Build web de produção executado',''),
('SUPABASE_MIGRATIONS','Migrations aplicadas no ambiente de teste',''),
('LIVEKIT_ROOM','Sala LiveKit testada com áudio',''),
('CHAT','Chat testado em duas sessões',''),
('GIFTS','Presentes testados sem saldo real',''),
('SLOTS_20','20 slots catalogados e testados',''),
('ANDROID_BUILD','APK/AAB de teste gerado',''),
('PLAY_ASSETS','Ícone e capturas da experiência real preparados','')
on conflict(check_key) do nothing;
