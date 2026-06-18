package it.unisa.skillmarket.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class OrdineBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idOrdine;
    private int idCliente;
    private Timestamp dataOrdine;
    private BigDecimal totaleOrdine;
    private String indirizzoSpedizione;
    private String datiPagamento;

    public OrdineBean() {
    }

    public int getIdOrdine() {
        return idOrdine;
    }

    public void setIdOrdine(int idOrdine) {
        this.idOrdine = idOrdine;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    public Timestamp getDataOrdine() {
        return dataOrdine;
    }

    public void setDataOrdine(Timestamp dataOrdine) {
        this.dataOrdine = dataOrdine;
    }

    public BigDecimal getTotaleOrdine() {
        return totaleOrdine;
    }

    public void setTotaleOrdine(BigDecimal totaleOrdine) {
        this.totaleOrdine = totaleOrdine;
    }

    public String getIndirizzoSpedizione() {
        return indirizzoSpedizione;
    }

    public void setIndirizzoSpedizione(String indirizzoSpedizione) {
        this.indirizzoSpedizione = indirizzoSpedizione;
    }

    public String getDatiPagamento() {
        return datiPagamento;
    }

    public void setDatiPagamento(String datiPagamento) {
        this.datiPagamento = datiPagamento;
    }

    @Override
    public String toString() {
        return "OrdineBean{" +
                "idOrdine=" + idOrdine +
                ", idCliente=" + idCliente +
                ", dataOrdine=" + dataOrdine +
                ", totaleOrdine=" + totaleOrdine +
                '}';
    }
}