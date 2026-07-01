package it.unisa.skillmarket.dao;

import it.unisa.skillmarket.model.OrdineBean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class OrdineDAO {

    private static final String TABLE_NAME = "Ordine";

    // Query SQL costanti
    private static final String INSERT = "INSERT INTO " + TABLE_NAME + " (id_cliente, data_ordine, totale_ordine, indirizzo_spedizione, dati_pagamento) VALUES (?, ?, ?, ?, ?)";
    private static final String RETRIEVE_BY_ID = "SELECT * FROM " + TABLE_NAME + " WHERE id_ordine = ?";
    private static final String RETRIEVE_BY_CLIENTE = "SELECT * FROM " + TABLE_NAME + " WHERE id_cliente = ? ORDER BY data_ordine DESC";
    private static final String RETRIEVE_ALL = "SELECT * FROM " + TABLE_NAME + " ORDER BY data_ordine DESC";

    /**
     * Salva un nuovo Ordine nel database e restituisce l'ID generato automaticamente.
     * Necessario per poter agganciare i dettagli dell'ordine subito dopo.
     */
    public int doSave(OrdineBean ordine) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, ordine.getIdCliente());
            ps.setTimestamp(2, ordine.getDataOrdine());
            ps.setBigDecimal(3, ordine.getTotaleOrdine());
            ps.setString(4, ordine.getIndirizzoSpedizione());
            ps.setString(5, ordine.getDatiPagamento());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int idGenerato = generatedKeys.getInt(1);
                        ordine.setIdOrdine(idGenerato); // Aggiorno il bean per coerenza
                        return idGenerato;
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Recupera un singolo ordine tramite il suo ID identificativo.
     */
    public OrdineBean doRetrieveById(int idOrdine) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_BY_ID)) {
            
            ps.setInt(1, idOrdine);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractOrdineFromResultSet(rs);
                }
            }
        }
        return null;
    }

    /**
     * Recupera lo storico di tutti gli ordini effettuati da un determinato cliente.
     * Ordina i risultati dal più recente al più vecchio.
     */
    public List<OrdineBean> doRetrieveByCliente(int idCliente) throws SQLException {
        List<OrdineBean> ordini = new ArrayList<>();
        
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_BY_CLIENTE)) {
            
            ps.setInt(1, idCliente);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ordini.add(extractOrdineFromResultSet(rs));
                }
            }
        }
        return ordini;
    }

    /**
     * Recupera tutti gli ordini registrati nella piattaforma.
     * Metodo ad uso esclusivo del pannello amministratore.
     */
    public List<OrdineBean> doRetrieveAll() throws SQLException {
        List<OrdineBean> ordini = new ArrayList<>();
        
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ordini.add(extractOrdineFromResultSet(rs));
            }
        }
        return ordini;
    }

    /**
     * Metodo di utility privato per mappare un ResultSet in un oggetto OrdineBean.
     */
    private OrdineBean extractOrdineFromResultSet(ResultSet rs) throws SQLException {
        OrdineBean bean = new OrdineBean();
        bean.setIdOrdine(rs.getInt("id_ordine"));
        bean.setIdCliente(rs.getInt("id_cliente"));
        bean.setDataOrdine(rs.getTimestamp("data_ordine"));
        bean.setTotaleOrdine(rs.getBigDecimal("totale_ordine"));
        bean.setIndirizzoSpedizione(rs.getString("indirizzo_spedizione"));
        bean.setDatiPagamento(rs.getString("dati_pagamento"));
        return bean;
    }

    /* ====================================================================================
     * NOTE SULLE SCELTE ARCHITETTURALI DEL DAO (OrdineDAO)
     * * Durante lo sviluppo di questa classe ho adottato criteri rigidi dettati dalla
     * natura transazionale dei dati e dai requisiti funzionali del progetto:
     * * 1. HO INTEGRATO STATEMENT.RETURN_GENERATED_KEYS NELLA INSERZIONE:
     * Ho modificato il comportamento standard del metodo doSave() chiedendo al driver 
     * JDBC di restituirmi la chiave primaria autogenerata (id_ordine). Questa è una scelta 
     * obbligata: il flusso transazionale del checkout prevede che, subito dopo aver 
     * creato la testata dell'ordine, io debba inserire i singoli dettagli nel database. 
     * Senza recuperare immediatamente l'id_ordine appena creato dal database, non potrei 
     * collegare i record della tabella dettaglio_ordine.
     * * 2. HO AGGIUNTO IL METODO RETRIEVE_BY_CLIENTE CON ORDINAMENTO TIMECODE:
     * Ho preferito creare una query ad hoc (doRetrieveByCliente) anziché filtrare via 
     * codice. Questo risponde al requisito funzionale dell'"Area Personale", dove il 
     * Cliente deve poter consultare il proprio storico acquisti. Ho aggiunto 'ORDER BY 
     * data_ordine DESC' direttamente nella query SQL per delegare l'ordinamento cronologico 
     * al DBMS, alleggerendo il carico computazionale del server Tomcat.
     * * 3. HO TOTALMENTE EVITATO LE OPERAZIONI DI UPDATE E DELETE:
     * Così come per la riga d'ordine, anche la testata dell'ordine per me è un oggetto 
     * immutabile. Un ordine rappresenta una transazione economica conclusa e ha valore 
     * storico e statistico. Permettere una cancellazione (DELETE) o una modifica (UPDATE) 
     * dell'importo o del cliente comporterebbe una perdita di consistenza finanziaria. 
     * Eventuali evoluzioni sullo "stato dell'ordine" (es. Pagato, Spedito) andrebbero gestite 
     * con un attributo dedicato senza mai intaccare i dati core inseriti al momento del checkout.
     * ====================================================================================
     */
}