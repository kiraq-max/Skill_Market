package it.unisa.skillmarket.dao;

import it.unisa.skillmarket.model.DettaglioOrdineBean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DettaglioOrdineDAO {

    private static final String TABLE_NAME = "dettaglio_ordine";

    // Query SQL
    // Salva una singola riga d'ordine
    private static final String INSERT = "INSERT INTO " + TABLE_NAME + " (id_ordine, id_servizio, prezzo_acquisto, quantita) VALUES (?, ?, ?, ?)";
    
    // Recupera tutti i dettagli (i prodotti) che compongono uno specifico ordine
    private static final String RETRIEVE_BY_ORDINE = "SELECT * FROM " + TABLE_NAME + " WHERE id_ordine = ?";

    /**
     * Salva un nuovo Dettaglio Ordine nel database.
     * Viene chiamato per ogni elemento presente nel carrello durante il checkout.
     */
    public void doSave(DettaglioOrdineBean dettaglio) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT)) {
            
            ps.setInt(1, dettaglio.getIdOrdine());
            ps.setInt(2, dettaglio.getIdServizio());
            ps.setBigDecimal(3, dettaglio.getPrezzoAcquisto());
            ps.setInt(4, dettaglio.getQuantita());
            
            ps.executeUpdate();
        }
    }

    /**
     * Recupera l'elenco dei servizi acquistati all'interno di uno specifico ordine.
     * Utile quando il cliente clicca su "Dettagli" nello storico ordini.
     */
    public List<DettaglioOrdineBean> doRetrieveByOrdine(int idOrdine) throws SQLException {
        List<DettaglioOrdineBean> dettagli = new ArrayList<>();
        
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_BY_ORDINE)) {
            
            ps.setInt(1, idOrdine);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dettagli.add(extractDettaglioFromResultSet(rs));
                }
            }
        }
        return dettagli;
    }

    /**
     * Metodo di utility per mappare un ResultSet in un oggetto DettaglioOrdineBean.
     */
    private DettaglioOrdineBean extractDettaglioFromResultSet(ResultSet rs) throws SQLException {
        DettaglioOrdineBean bean = new DettaglioOrdineBean();
        bean.setIdOrdine(rs.getInt("id_ordine"));
        bean.setIdServizio(rs.getInt("id_servizio"));
        bean.setPrezzoAcquisto(rs.getBigDecimal("prezzo_acquisto"));
        bean.setQuantita(rs.getInt("quantita"));
        return bean;
    }

    /* ====================================================================================
     * NOTE SULLE SCELTE ARCHITETTURALI DEL DAO (DettaglioOrdineDAO)
     * * Per la stesura di questo DAO ho preso delle decisioni architetturali precise
     * in ottica di integrità dei dati e rispetto delle logiche di e-commerce:
     * * 1. HO AGGIUNTO IL CAMPO "PREZZO ACQUISTO" NELLA INSERT: 
     * Ho deciso di salvare esplicitamente il prezzo del servizio al momento del checkout 
     * dentro la tabella dettaglio_ordine. Questo l'ho fatto perché il prezzo 
     * nel catalogo (nella tabella Servizio) può variare in futuro. Se non storicizzassi 
     * il prezzo qui, uno scontrino dell'anno scorso cambierebbe totale se il venditore
     * oggi decidesse di alzare il prezzo del servizio.
     * * 2. HO EVITATO I METODI UPDATE E DELETE:
     * Ho scelto di non implementare né un doUpdate() né un doDelete() per questa classe.
     * Essendo SkillMarket un e-commerce, un ordine confermato rappresenta un documento
     * fiscale e storico. Una volta che il cliente ha pagato e la riga d'ordine è stata
     * creata, essa diventa immutabile. Se permettessi la cancellazione o la modifica
     * delle righe d'ordine, andrei a corrompere lo storico degli acquisti e i ricavi
     * registrati dai venditori.
     * * 3. HO EVITATO IL METODO RETRIEVE_ALL GENERALE:
     * Non ho inserito un doRetrieveAll() senza filtri perché caricare in RAM l'intera 
     * tabella contenente ogni singolo servizio venduto nella storia della piattaforma
     * sarebbe uno spreco inutile di risorse. Ho preferito implementare solo un 
     * doRetrieveByOrdine(id) in modo da estrarre esclusivamente i dettagli del
     * singolo scontrino che l'utente o l'admin vogliono visualizzare in quel momento.
     * ====================================================================================
     */
}