package it.unisa.skillmarket.dao;

import it.unisa.skillmarket.model.UtenteBean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Classe DAO per la gestione della persistenza degli oggetti UtenteBean.
 * Si occupa di tutte le operazioni CRUD sulla tabella 'Utente' del database.
 */
public class UtenteDAO {

    /**
     * Salva un nuovo utente nel database (Registrazione).
     * 
     * @param utente L'oggetto UtenteBean da salvare.
     * @throws SQLException in caso di errori con il database.
     */
    public synchronized void doSave(UtenteBean utente) throws SQLException {
        // La query SQL per l'inserimento
        String query = "INSERT INTO Utente (nome, cognome, email, password_hash, ruolo) VALUES (?, ?, ?, ?, ?)";

        // costrutto try-with-resources per gestire in sicurezza la chiusura delle
        // connessioni
        try (Connection con = ConPool.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, utente.getNome());
            ps.setString(2, utente.getCognome());
            ps.setString(3, utente.getEmail());
            ps.setString(4, utente.getPasswordHash());
            ps.setString(5, utente.getRuolo());

            // Eseguiamo l'aggiornamento sul database
            ps.executeUpdate();
        }
    }

    /**
     * Recupera un utente dal database tramite email e password (Login).
     * 
     * @param email        L'email inserita dall'utente.
     * @param passwordHash L'hash della password inserita dall'utente.
     * @return L'oggetto UtenteBean se le credenziali sono corrette, null
     *         altrimenti.
     * @throws SQLException in caso di errori con il database.
     */
    public synchronized UtenteBean doRetrieveByEmailAndPassword(String email, String passwordHash) throws SQLException {
        String query = "SELECT * FROM Utente WHERE email = ? AND password_hash = ?";
        UtenteBean utente = null;

        try (Connection con = ConPool.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, email);
            ps.setString(2, passwordHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    utente = new UtenteBean();
                    utente.setIdUtente(rs.getInt("id_utente"));
                    utente.setNome(rs.getString("nome"));
                    utente.setCognome(rs.getString("cognome"));
                    utente.setEmail(rs.getString("email"));
                    utente.setPasswordHash(rs.getString("password_hash"));
                    utente.setRuolo(rs.getString("ruolo"));
                }
            }
        }
        return utente;
    }
}