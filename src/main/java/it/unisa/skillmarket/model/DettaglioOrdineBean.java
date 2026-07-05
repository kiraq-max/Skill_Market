package it.unisa.skillmarket.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class DettaglioOrdineBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idOrdine;
    private int idServizio;
    private int quantita;
    private BigDecimal prezzoAcquisto;

    /**
     * Campo transiente: non fa parte dello schema DB.
     * Viene popolato dalla AreaPersonaleServlet per portare i dati del Servizio
     * direttamente alla view, evitando query aggiuntive dalla JSP.
     */
    private transient ServizioBean servizio;

    public DettaglioOrdineBean() {
    }

    public int getIdOrdine() {
        return idOrdine;
    }

    public void setIdOrdine(int idOrdine) {
        this.idOrdine = idOrdine;
    }

    public int getIdServizio() {
        return idServizio;
    }

    public void setIdServizio(int idServizio) {
        this.idServizio = idServizio;
    }

    public int getQuantita() {
        return quantita;
    }

    public void setQuantita(int quantita) {
        this.quantita = quantita;
    }

    public BigDecimal getPrezzoAcquisto() {
        return prezzoAcquisto;
    }

    public void setPrezzoAcquisto(BigDecimal prezzoAcquisto) {
        this.prezzoAcquisto = prezzoAcquisto;
    }

    public ServizioBean getServizio() {
        return servizio;
    }

    public void setServizio(ServizioBean servizio) {
        this.servizio = servizio;
    }

    @Override
    public String toString() {
        return "DettaglioOrdineBean{" +
                "idOrdine=" + idOrdine +
                ", idServizio=" + idServizio +
                ", quantita=" + quantita +
                ", prezzoAcquisto=" + prezzoAcquisto +
                '}';
    }
}