-- V3.7 — catálogo executável de 20 jogos sociais não monetários.
-- Estes registros não habilitam apostas, prêmios ou conversão financeira.
insert into public.game_registry(game_key,name,category,status,free_mode,coin_mode,monetization_mode)
values
('tic_tac_toe','Três em Linha','tabuleiro','integrated',true,false,'none'),
('memory','Memória Estelar','memória','integrated',true,false,'none'),
('reaction','Reflexo Cósmico','reflexo','integrated',true,false,'none'),
('sequence','Sequência Estelar','memória','integrated',true,false,'none'),
('math','Desafio Matemático','lógica','integrated',true,false,'none'),
('rps','Pedra Papel Tesoura','social','integrated',true,false,'none'),
('word_scramble','Palavra Embaralhada','palavras','integrated',true,false,'none'),
('color_match','Cores Cósmicas','reflexo','integrated',true,false,'none'),
('tap_count','Contador Estelar','reflexo','integrated',true,false,'none'),
('pattern','Padrão Galáctico','lógica','integrated',true,false,'none'),
('anagram','Anagrama','palavras','integrated',true,false,'none'),
('quiz','Quiz Cósmico','quiz','integrated',true,false,'none'),
('simon','Estrelas em Ordem','memória','integrated',true,false,'none'),
('grid','Grade Relâmpago','reflexo','integrated',true,false,'none'),
('odd_one','Intruso na Constelação','atenção','integrated',true,false,'none'),
('word_chain','Cadeia de Palavras','palavras','integrated',true,false,'none'),
('logic','Lógica Estelar','lógica','integrated',true,false,'none'),
('count_stars','Conte as Estrelas','atenção','integrated',true,false,'none'),
('typing','Digitação Cósmica','reflexo','integrated',true,false,'none'),
('color_memory','Memória de Cores','memória','integrated',true,false,'none')
on conflict (game_key) do update set
 name=excluded.name,category=excluded.category,status=excluded.status,
 free_mode=excluded.free_mode,coin_mode=false,monetization_mode='none';
