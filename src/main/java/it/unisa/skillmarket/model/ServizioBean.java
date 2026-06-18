package it.unisa.skillmarket.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Classe JavaBean che rappresenta un Servizio digitale offerto nel catalogo.
 * Mappa la tabella 'Servizio' del database.
 */
public class ServizioBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idServizio;
    private String titolo;
    private String descrizione;
    private BigDecimal prezzoCorrente; // BigDecimal è perfetto per i prezzi (valute)
    private String immaginePath;
    private int idCategoria;
    private int idVenditore;
    private boolean attivo; // Per la gestione del soft-delete

    public ServizioBean() {
    }

    public int getIdServizio() {
        return idServizio;
    }

    public void setIdServizio(int idServizio) {
        this.idServizio = idServizio;
    }

    public String getTitolo() {
        return titolo;
    }

    public void setTitolo(String titolo) {
        this.titolo = titolo;
    }

    public String getDescrizione() {
        return descrizione;
    }

    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione;
    }

    public BigDecimal getPrezzoCorrente() {
        return prezzoCorrente;
    }

    public void setPrezzoCorrente(BigDecimal prezzoCorrente) {
        this.prezzoCorrente = prezzoCorrente;
    }

    public String getImmaginePath() {
        return immaginePath;
    }

    public void setImmaginePath(String immaginePath) {
        this.immaginePath = immaginePath;
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }

    public int getIdVenditore() {
        return idVenditore;
    }

    public void setIdVenditore(int idVenditore) {
        this.idVenditore = idVenditore;
    }

    public boolean isAttivo() {
        return attivo;
    }

    public void setAttivo(boolean attivo) {
        this.attivo = attivo;
    }

    @Override
    public String toString() {
        return "ServizioBean{" +
                "idServizio=" + idServizio +
                ", titolo='" + titolo + '\'' +
                ", prezzoCorrente=" + prezzoCorrente +
                ", attivo=" + attivo +
                '}';
    }
}