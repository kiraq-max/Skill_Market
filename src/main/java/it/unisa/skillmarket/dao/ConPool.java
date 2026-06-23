package it.unisa.skillmarket.dao;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolProperties;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Classe di utilità per la gestione del Pool di Connessioni al database.
 * Implementa il pattern Singleton con double-checked locking per garantire
 * thread-safety senza degradare le prestazioni del pool.
 *
 * Le credenziali vengono caricate da /WEB-INF/db.properties (escluso da git).
 */
public class ConPool {

    // volatile garantisce la visibilità della scrittura tra i thread (JMM)
    private static volatile DataSource datasource;

    // Costruttore privato: impedisce l'istanziazione diretta
    private ConPool() {}

    /**
     * Restituisce una connessione attiva presa dal pool.
     * Se il pool non esiste ancora, lo inizializza (double-checked locking).
     *
     * @return Connection oggetto che rappresenta la connessione al DB.
     * @throws SQLException in caso di problemi di comunicazione col DB.
     */
    public static Connection getConnection() throws SQLException {
        // Primo controllo (senza lock) per evitare la sincronizzazione una volta che il pool è pronto
        if (datasource == null) {
            synchronized (ConPool.class) {
                // Secondo controllo (con lock) per garantire che un solo thread inizializzi il pool
                if (datasource == null) {
                    datasource = buildDataSource();
                }
            }
        }
        return datasource.getConnection();
    }

    /**
     * Costruisce e configura il DataSource leggendo le credenziali da db.properties.
     *
     * @return DataSource configurato e pronto all'uso.
     * @throws SQLException se le proprietà non sono leggibili o la configurazione fallisce.
     */
    private static DataSource buildDataSource() throws SQLException {
        Properties props = loadProperties();

        PoolProperties p = new PoolProperties();

        // Parametri di connessione letti dal file di configurazione
        p.setUrl(props.getProperty("db.url"));
        p.setDriverClassName(props.getProperty("db.driver"));
        p.setUsername(props.getProperty("db.username"));
        p.setPassword(props.getProperty("db.password"));

        // Configurazione del pool di connessioni
        p.setMaxActive(100);
        p.setInitialSize(10);
        p.setMinIdle(10);

        // Timeout massimo di attesa per ottenere una connessione (10 secondi)
        // Evita che i thread restino bloccati indefinitamente se il pool è esaurito
        p.setMaxWait(10000);

        // Valida la connessione prima di consegnarla: evita "stale connection" silenti
        p.setTestOnBorrow(true);
        p.setValidationQuery("SELECT 1");

        // Recupero automatico delle connessioni abbandonate dopo 60 secondi
        p.setRemoveAbandonedTimeout(60);
        p.setRemoveAbandoned(true);

        DataSource ds = new DataSource();
        ds.setPoolProperties(p);
        return ds;
    }

    /**
     * Carica il file db.properties dal classpath.
     *
     * @return Properties con i parametri di connessione.
     * @throws SQLException se il file non viene trovato o non è leggibile.
     */
    private static Properties loadProperties() throws SQLException {
        Properties props = new Properties();
        try (InputStream in = ConPool.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new SQLException("File db.properties non trovato nel classpath. " +
                        "Verificare che sia presente in src/main/resources/.");
            }
            props.load(in);
        } catch (IOException e) {
            throw new SQLException("Impossibile leggere db.properties.", e);
        }
        return props;
    }
}