package it.unisa.skillmarket.dao;

import it.unisa.skillmarket.model.ServizioBean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ServizioDAO {

    // Query SQL costanti (nomi tabelle e colonne ipotizzati in base al Bean)
    private static final String TABLE_NAME = "Servizio";
    
    // Recupera solo i servizi attivi (soft-delete)
    private static final String RETRIEVE_ALL = "SELECT * FROM " + TABLE_NAME + " WHERE attivo = true";
    private static final String RETRIEVE_BY_ID = "SELECT * FROM " + TABLE_NAME + " WHERE id_servizio = ? AND attivo = true";
    private static final String RETRIEVE_BY_CATEGORY = "SELECT * FROM " + TABLE_NAME + " WHERE id_categoria = ? AND attivo = true";
    
    // Inserimento: di default un nuovo servizio è attivo (true)
    private static final String INSERT = "INSERT INTO " + TABLE_NAME + " (titolo, descrizione, prezzo_corrente, immagine_path, id_categoria, id_venditore, attivo) VALUES (?, ?, ?, ?, ?, ?, true)";
    
    // Modifica: in genere il venditore non può cambiare chi è il creatore del servizio
    private static final String UPDATE = "UPDATE " + TABLE_NAME + " SET titolo = ?, descrizione = ?, prezzo_corrente = ?, immagine_path = ?, id_categoria = ? WHERE id_servizio = ?";
    
    // Soft Delete: imposta attivo = false
    private static final String LOGICAL_DELETE = "UPDATE " + TABLE_NAME + " SET attivo = false WHERE id_servizio = ?";

    /**
     * Recupera tutti i servizi attivi nel catalogo.
     */
    public List<ServizioBean> doRetrieveAll() throws SQLException {
        List<ServizioBean> servizi = new ArrayList<>();
        
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                servizi.add(extractServizioFromResultSet(rs));
            }
        }
        return servizi;
    }

      
    public ServizioBean doRetrieveById(int idServizio) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_BY_ID)) {
            
            ps.setInt(1, idServizio);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractServizioFromResultSet(rs);
                }
            }
        }
        return null;
    }

    /**
     * Recupera tutti i servizi appartenenti a una specifica categoria.
     */
    public List<ServizioBean> doRetrieveByCategory(int idCategoria) throws SQLException {
        List<ServizioBean> servizi = new ArrayList<>();
        
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_BY_CATEGORY)) {
            
            ps.setInt(1, idCategoria);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    servizi.add(extractServizioFromResultSet(rs));
                }
            }
        }
        return servizi;
    }

    /**
     * Salva un nuovo Servizio nel database.
     */
    public void doSave(ServizioBean servizio) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT)) {
            
            ps.setString(1, servizio.getTitolo());
            ps.setString(2, servizio.getDescrizione());
            ps.setBigDecimal(3, servizio.getPrezzoCorrente());
            ps.setString(4, servizio.getImmaginePath());
            ps.setInt(5, servizio.getIdCategoria());
            ps.setInt(6, servizio.getIdVenditore());
            
            ps.executeUpdate();
        }
    }

    /**
     * Aggiorna le informazioni di un Servizio esistente.
     */
    public void doUpdate(ServizioBean servizio) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE)) {
            
            ps.setString(1, servizio.getTitolo());
            ps.setString(2, servizio.getDescrizione());
            ps.setBigDecimal(3, servizio.getPrezzoCorrente());
            ps.setString(4, servizio.getImmaginePath());
            ps.setInt(5, servizio.getIdCategoria());
            ps.setInt(6, servizio.getIdServizio());
            
            ps.executeUpdate();
        }
    }

    /**
     * Esegue una CANCELLAZIONE LOGICA del servizio (imposta attivo a false).
     */
    public void doDelete(int idServizio) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(LOGICAL_DELETE)) {
            
            ps.setInt(1, idServizio);
            ps.executeUpdate();
        }
    }

    /**
     * Metodo di utility per mappare un ResultSet in un oggetto ServizioBean.
     */
    private ServizioBean extractServizioFromResultSet(ResultSet rs) throws SQLException {
        ServizioBean bean = new ServizioBean();
        bean.setIdServizio(rs.getInt("id_servizio"));
        bean.setTitolo(rs.getString("titolo"));
        bean.setDescrizione(rs.getString("descrizione"));
        bean.setPrezzoCorrente(rs.getBigDecimal("prezzo_corrente"));
        bean.setImmaginePath(rs.getString("immagine_path"));
        bean.setIdCategoria(rs.getInt("id_categoria"));
        bean.setIdVenditore(rs.getInt("id_venditore"));
        bean.setAttivo(rs.getBoolean("attivo"));
        return bean;
    }
}