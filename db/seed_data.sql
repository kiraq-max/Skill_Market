-- ============================================================
-- SkillMarket — Dati di esempio per test e sviluppo
-- ============================================================
USE skillmarket;

-- ========================================================
-- UTENTI DI TEST (password in chiaro → SHA-256 hash)
-- Password per tutti: "Password1"
-- SHA-256("Password1") = 0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e
-- ========================================================

INSERT INTO Utente (nome, cognome, email, password_hash, ruolo) VALUES
('Admin', 'SkillMarket', 'admin@skillmarket.it', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'AMMINISTRATORE'),
('Marco', 'Rossi', 'marco.rossi@email.it', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'VENDITORE'),
('Laura', 'Bianchi', 'laura.bianchi@email.it', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'VENDITORE'),
('Giuseppe', 'Verdi', 'giuseppe.verdi@email.it', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'VENDITORE'),
('Anna', 'Esposito', 'anna.esposito@email.it', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'CLIENTE'),
('Luca', 'Romano', 'luca.romano@email.it', '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', 'CLIENTE');

-- ========================================================
-- CATEGORIE
-- ========================================================

INSERT INTO Categoria (nome, descrizione) VALUES
('Sviluppo Web', 'Servizi di sviluppo frontend, backend e full-stack per siti e applicazioni web.'),
('Graphic Design', 'Creazione di loghi, branding, illustrazioni e materiali grafici professionali.'),
('Marketing Digitale', 'Strategie SEO, SEM, social media marketing e campagne pubblicitarie online.'),
('Scrittura & Traduzione', 'Copywriting, content writing, traduzioni professionali e revisione testi.'),
('Video & Animazione', 'Produzione video, motion graphics, editing e animazioni 2D/3D.'),
('Musica & Audio', 'Composizione musicale, sound design, voice-over e produzione audio.');

-- ========================================================
-- SERVIZI (collegati alle categorie e ai venditori)
-- I venditori sono: Marco Rossi (id=2), Laura Bianchi (id=3), Giuseppe Verdi (id=4)
-- Le categorie sono: 1=Web, 2=Design, 3=Marketing, 4=Scrittura, 5=Video, 6=Audio
-- ========================================================

-- === Categoria: Sviluppo Web (id_categoria = 1) ===
INSERT INTO Servizio (titolo, descrizione, prezzo_corrente, immagine_path, id_categoria, id_venditore, attivo) VALUES
('Sito Web Responsive in HTML/CSS/JS',
 'Realizzo il tuo sito web moderno e responsive, ottimizzato per tutti i dispositivi. Include design personalizzato, animazioni CSS e integrazione con i principali CMS. Consegna in 7 giorni lavorativi.',
 250.00, 'web_responsive.png', 1, 2, TRUE),

('Sviluppo API REST con Spring Boot',
 'Progettazione e sviluppo di API RESTful con Java Spring Boot, documentazione Swagger inclusa. Architettura pulita con pattern MVC, gestione errori e test unitari.',
 400.00, 'api_rest.png', 1, 4, TRUE),

('E-commerce con WordPress + WooCommerce',
 'Creazione completa di un negozio online con WordPress e WooCommerce. Configurazione pagamenti, spedizioni, catalogo prodotti e tema personalizzato.',
 350.00, 'ecommerce.png', 1, 2, TRUE),

('Landing Page ad Alta Conversione',
 'Design e sviluppo di una landing page ottimizzata per la conversione. A/B testing incluso, integrazione analytics e form di contatto avanzati.',
 180.00, 'landing_page.png', 1, 3, TRUE),

-- === Categoria: Graphic Design (id_categoria = 2) ===
('Logo Professionale + Brand Identity',
 'Creazione di un logo unico e memorabile con 3 proposte iniziali e revisioni illimitate. Include palette colori, tipografia e linee guida per il brand.',
 300.00, 'logo_branding.png', 2, 3, TRUE),

('UI/UX Design per App Mobile',
 'Progettazione completa dell interfaccia utente per la tua app mobile. Wireframe, mockup ad alta fedeltà in Figma e prototipo interattivo.',
 500.00, 'uiux_design.png', 2, 3, TRUE),

('Pacchetto Social Media Graphics',
 'Set di 20 template grafici personalizzati per i tuoi canali social (Instagram, Facebook, LinkedIn). Formato editabile incluso.',
 150.00, 'social_media_graphics.png', 2, 2, TRUE),

-- === Categoria: Marketing Digitale (id_categoria = 3) ===
('Audit SEO Completo del Sito',
 'Analisi approfondita del posizionamento del tuo sito web. Report dettagliato con keyword research, analisi competitor, problemi tecnici e piano d azione strategico.',
 200.00, 'seo_audit.png', 3, 4, TRUE),

('Gestione Campagna Google Ads',
 'Setup e gestione di campagne Google Ads per 30 giorni. Include ricerca keyword, creazione annunci, ottimizzazione bid e report settimanali sulle performance.',
 450.00, 'google_ads.png', 3, 4, TRUE),

('Piano Editoriale Social Media',
 'Strategia social media completa per 3 mesi. Calendario editoriale, copy per i post, hashtag strategy e analisi dei risultati mensile.',
 280.00, 'social_media_plan.png', 3, 2, TRUE),

-- === Categoria: Scrittura & Traduzione (id_categoria = 4) ===
('Articoli Blog SEO-Optimized (5 pezzi)',
 'Pacchetto di 5 articoli blog ottimizzati per la SEO, da 800-1200 parole ciascuno. Ricerca keyword inclusa, tono di voce personalizzato sul tuo brand.',
 220.00, 'blog_seo.png', 4, 3, TRUE),

('Traduzione Professionale IT ↔ EN',
 'Traduzione professionale italiano-inglese o viceversa per documenti, siti web o materiali marketing. Fino a 5000 parole, revisione inclusa.',
 180.00, 'translation.png', 4, 4, TRUE),

('Copywriting per Pagina di Vendita',
 'Testo persuasivo per la tua pagina di vendita. Struttura AIDA, headline accattivanti e call-to-action efficaci. Una revisione inclusa.',
 160.00, 'copywriting.png', 4, 3, TRUE),

-- === Categoria: Video & Animazione (id_categoria = 5) ===
('Video Promozionale Aziendale (60 sec)',
 'Produzione di un video promozionale professionale di 60 secondi. Include script, storyboard, riprese stock premium, editing e colonna sonora royalty-free.',
 600.00, 'video_promo.png', 5, 2, TRUE),

('Animazione Logo (Intro/Outro)',
 'Animazione professionale del tuo logo per intro e outro dei tuoi video. 3 stili diversi tra cui scegliere, consegna in formato MP4 e trasparente.',
 120.00, 'logo_animation.png', 5, 4, TRUE),

-- === Categoria: Musica & Audio (id_categoria = 6) ===
('Jingle Pubblicitario Personalizzato',
 'Composizione originale di un jingle pubblicitario per il tuo brand. Include 2 versioni (15 e 30 secondi), mix e master professionale.',
 350.00, 'jingle.png', 6, 2, TRUE),

('Voice-Over Professionale (5 min)',
 'Registrazione voice-over professionale in italiano, fino a 5 minuti. Ideale per video aziendali, spot pubblicitari, e-learning e podcast.',
 100.00, 'voiceover.png', 6, 4, TRUE);

-- ========================================================
-- VERIFICA
-- ========================================================
SELECT 'Utenti inseriti:' AS info, COUNT(*) AS totale FROM Utente
UNION ALL
SELECT 'Categorie inserite:', COUNT(*) FROM Categoria
UNION ALL
SELECT 'Servizi inseriti:', COUNT(*) FROM Servizio;
