package it.unisa.skillmarket.model;

import java.io.Serializable;

/**
 * Classe JavaBean che rappresenta un Utente (Cliente, Venditore o Amministratore).
 * Mappa la tabella 'Utente' del database.
 */
public class UtenteBean implements Serializable {

    private static final long serialVersionUID = 1L;

    // Attributi che rispecchiano fedelmente le colonne del database
    private int idUtente;
    private String nome;
    private String cognome;
    private String email;
    private String passwordHash;
    private String ruolo; // Può assumere i valori: 'CLIENTE', 'VENDITORE', 'AMMINISTRATORE'

    // Costruttore vuoto (obbligatorio per le specifiche JavaBean)
    public UtenteBean() {
    }

    // --- Metodi Getters e Setters ---

    public int getIdUtente() {
        return idUtente;
    }

    public void setIdUtente(int idUtente) {
        this.idUtente = idUtente;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCognome() {
        return cognome;
    }

    public void setCognome(String cognome) {
        this.cognome = cognome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRuolo() {
        return ruolo;
    }

    public void setRuolo(String ruolo) {
        this.ruolo = ruolo;
    }

    // Metodo toString utile per stampare il contenuto dell'oggetto in fase di test/debug
    @Override
    public String toString() {
        return "UtenteBean{" +
                "idUtente=" + idUtente +
                ", nome='" + nome + '\'' +
                ", cognome='" + cognome + '\'' +
                ", email='" + email + '\'' +
                ", ruolo='" + ruolo + '\'' +
                '}';
    }
}