package it.unisa.skillmarket.dao;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolProperties;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.TimeZone;

/**
 * Classe di utilità per la gestione del Pool di Connessioni al database.
 * Utilizza il pattern Singleton per garantire che esista un solo DataSource.
 */
public class ConPool {

    // L'oggetto DataSource è il "serbatoio" di connessioni
    private static DataSource datasource;

    /**
     * Restituisce una connessione attiva presa dal pool.
     * Se il pool non esiste ancora, lo inizializza.
     * * @return Connection oggetto che rappresenta la connessione al DB.
     * @throws SQLException in caso di problemi di comunicazione col DB.
     */
    public static Connection getConnection() throws SQLException {
        
        if (datasource == null) {
            PoolProperties p = new PoolProperties();
            
            // Configurazione dei parametri del database MariaDB
            p.setUrl("jdbc:mariadb://localhost:3306/skillmarket");
            p.setDriverClassName("org.mariadb.jdbc.Driver");
            p.setUsername("root");
            p.setPassword("SkillMarketDB1"); 
            
            // Configurazione delle prestazioni del Pool
            p.setMaxActive(100); 
            p.setInitialSize(10); 
            p.setMinIdle(10);     
            
            p.setRemoveAbandonedTimeout(60); // Se una connessione resta bloccata per 60 secondi...
            p.setRemoveAbandoned(true);      // ...viene "uccisa" e ricreata, per evitare blocchi del server
            
            // Inizializziamo il DataSource con queste proprietà
            datasource = new DataSource();
            datasource.setPoolProperties(p);
        }
        
        // Chiediamo in prestito una connessione dal serbatoio
        return datasource.getConnection();
    }
}