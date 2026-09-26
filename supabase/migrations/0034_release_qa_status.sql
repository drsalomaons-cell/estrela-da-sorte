-- V3.4 — checklist de release com estados honestos
insert into public.mobile_release_checks(check_key,description,status,evidence) values
('source_integrity','Arquivos centrais presentes','verified','Auditoria de repositório'),
('static_qa','Verificação estática executada no CI','pending','Aguardando execução do workflow'),
('production_build','npm run build executado com sucesso','pending','Aguardando execução do workflow'),
('supabase_connection','Consulta real ao Supabase','pending','Requer ambiente Supabase configurado'),
('auth_rls','Auth + perfil + RLS + sessão','pending','Requer teste ponta a ponta'),
('room_realtime','Sala + cadeiras + Realtime','pending','Requer Supabase configurado e execução'),
('chat_realtime','Chat Realtime','pending','Requer Supabase configurado e execução'),
('livekit_voice','Voz LiveKit','pending','Requer URL + token LiveKit e teste em dispositivo'),
('android_apk','APK/AAB instalado em dispositivo real','pending','Requer ambiente Android'),
('games_execution','Jogos executáveis e testados','pending','Catálogo não equivale a implementação')
on conflict(check_key) do update set description=excluded.description;
