package it.unisa.skillmarket.dao;

import it.unisa.skillmarket.model.CategoriaBean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoriaDAO {

    private static final String TABLE_NAME = "categoria";

    // Query SQL costanti
    private static final String INSERT = "INSERT INTO " + TABLE_NAME + " (nome, descrizione) VALUES (?, ?)";
    private static final String UPDATE = "UPDATE " + TABLE_NAME + " SET nome = ?, descrizione = ? WHERE id_categoria = ?";
    private static final String DELETE = "DELETE FROM " + TABLE_NAME + " WHERE id_categoria = ?";
    private static final String RETRIEVE_BY_ID = "SELECT * FROM " + TABLE_NAME + " WHERE id_categoria = ?";
    private static final String RETRIEVE_ALL = "SELECT * FROM " + TABLE_NAME + " ORDER BY nome ASC";

    /**
     * Salva una nuova Categoria nel database. (Ad uso dell'Amministratore)
     */
    public void doSave(CategoriaBean categoria) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT)) {
            
            ps.setString(1, categoria.getNome());
            ps.setString(2, categoria.getDescrizione());
            
            ps.executeUpdate();
        }
    }

    /**
     * Aggiorna i dati di una Categoria esistente. (Ad uso dell'Amministratore)
     */
    public void doUpdate(CategoriaBean categoria) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE)) {
            
            ps.setString(1, categoria.getNome());
            ps.setString(2, categoria.getDescrizione());
            ps.setInt(3, categoria.getIdCategoria());
            
            ps.executeUpdate();
        }
    }

    /**
     * Elimina fisicamente una Categoria dal database.
     * ATTENZIONE: Fallirà se ci sono servizi associati a questa categoria a causa dei vincoli di chiave esterna.
     */
    public void doDelete(int idCategoria) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(DELETE)) {
            
            ps.setInt(1, idCategoria);
            ps.executeUpdate();
        }
    }

    /**
     * Recupera una singola categoria tramite il suo ID.
     */
    public CategoriaBean doRetrieveById(int idCategoria) throws SQLException {
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_BY_ID)) {
            
            ps.setInt(1, idCategoria);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractCategoriaFromResultSet(rs);
                }
            }
        }
        return null;
    }

    /**
     * Recupera tutte le categorie presenti nel sistema ordinate alfabeticamente.
     * Fondamentale per generare dinamicamente il menu di navigazione del sito.
     */
    public List<CategoriaBean> doRetrieveAll() throws SQLException {
        List<CategoriaBean> categorie = new ArrayList<>();
        
        try (Connection con = ConPool.getConnection();
             PreparedStatement ps = con.prepareStatement(RETRIEVE_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categorie.add(extractCategoriaFromResultSet(rs));
            }
        }
        return categorie;
    }

    /**
     * Metodo di utility privato per mappare un ResultSet in un oggetto CategoriaBean.
     */
    private CategoriaBean extractCategoriaFromResultSet(ResultSet rs) throws SQLException {
        CategoriaBean bean = new CategoriaBean();
        bean.setIdCategoria(rs.getInt("id_categoria"));
        bean.setNome(rs.getString("nome"));
        bean.setDescrizione(rs.getString("descrizione"));
        return bean;
    }

    /* ====================================================================================
     * NOTE SULLE SCELTE ARCHITETTURALI DEL DAO (CategoriaDAO)
     * * Per questo DAO ho preso delle decisioni legate all'usabilità della piattaforma e 
     * all'integrità del database:
     * * 1. ORDINAMENTO ALFABETICO NEL RETRIEVE_ALL:
     * Ho inserito la clausola 'ORDER BY nome ASC' direttamente nella query di recupero di 
     * tutte le categorie. Questa scelta è strategica: il metodo doRetrieveAll() verrà 
     * chiamato ad ogni caricamento delle pagine per popolare il menu a tendina (Navbar) e 
     * i filtri laterali. Restituire una lista già ordinata alfabeticamente dal database 
     * evita di dover fare il sorting via codice in Java, migliorando l'esperienza utente.
     * * 2. MANTENIMENTO DELLA DELETE FISICA:
     * A differenza dei Servizi, per le categorie ho previsto la cancellazione fisica 
     * (doDelete). Tuttavia, ho delegato il controllo di integrità al DBMS tramite i 
     * vincoli di Foreign Key. Se un amministratore tenta di eliminare una categoria che 
     * contiene ancora dei servizi, il database bloccherà l'operazione lanciando una 
     * SQLException. Questo mi assicura che non ci siano "servizi orfani" nel sistema.
     * ====================================================================================
     */
}