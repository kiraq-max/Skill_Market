CREATE DATABASE IF NOT EXISTS skillmarket;
USE skillmarket;

-- Rimozione tabelle preesistenti per evitare conflitti in fase di test (ordine inverso di dipendenza)
DROP TABLE IF EXISTS Dettaglio_Ordine;
DROP TABLE IF EXISTS Ordine;
DROP TABLE IF EXISTS Servizio;
DROP TABLE IF EXISTS Categoria;
DROP TABLE IF EXISTS Utente;

-- ========================================================
-- TABELLA: Utente
-- Gestisce Clienti, Venditori (Freelance) e Amministratori
-- ========================================================
CREATE TABLE Utente (
    id_utente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Conterrà la password cifrata
    ruolo ENUM('CLIENTE', 'VENDITORE', 'AMMINISTRATORE') NOT NULL DEFAULT 'CLIENTE'
) ENGINE=InnoDB;

-- ========================================================
-- TABELLA: Categoria
-- Serve per la navigazione del catalogo ad albero
-- ========================================================
CREATE TABLE Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descrizione TEXT
) ENGINE=InnoDB;

-- ========================================================
-- TABELLA: Servizio
-- Rappresenta i servizi digitali (i "prodotti") inseriti dai freelance
-- ========================================================
CREATE TABLE Servizio (
    id_servizio INT AUTO_INCREMENT PRIMARY KEY,
    titolo VARCHAR(100) NOT NULL,
    descrizione TEXT NOT NULL,
    prezzo_corrente DECIMAL(10, 2) NOT NULL, -- Prezzo di listino attuale
    immagine_path VARCHAR(255) DEFAULT 'default_service.png', -- Cartella <images>
    id_categoria INT,
    id_venditore INT,
    attivo BOOLEAN NOT NULL DEFAULT TRUE, -- FONDAMENTALE per il Soft-Delete!
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria) ON DELETE SET NULL,
    FOREIGN KEY (id_venditore) REFERENCES Utente(id_utente) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ========================================================
-- TABELLA: Ordine
-- Testata dell'ordine generata al checkout
-- ========================================================
CREATE TABLE Ordine (
    id_ordine INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_ordine TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    totale_ordine DECIMAL(10, 2) NOT NULL,
    indirizzo_spedizione VARCHAR(255) NOT NULL, -- Richiesto dalle specifiche formali
    dati_pagamento VARCHAR(100) NOT NULL,       -- Es. "Carta di Credito (iniziali/token)"
    FOREIGN KEY (id_cliente) REFERENCES Utente(id_utente) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ========================================================
-- TABELLA: Dettaglio_Ordine
-- Tabella associativa N:M tra Ordine e Servizio.
-- Mantiene lo storico congelato dei singoli acquisti.
-- ========================================================
CREATE TABLE Dettaglio_Ordine (
    id_ordine INT NOT NULL,
    id_servizio INT NOT NULL,
    quantita INT NOT NULL DEFAULT 1,
    prezzo_acquisto DECIMAL(10, 2) NOT NULL, -- FONDAMENTALE per il blocco del prezzo storico!
    PRIMARY KEY (id_ordine, id_servizio),
    FOREIGN KEY (id_ordine) REFERENCES Ordine(id_ordine) ON DELETE CASCADE,
    FOREIGN KEY (id_servizio) REFERENCES Servizio(id_servizio) ON DELETE RESTRICT
) ENGINE=InnoDB;