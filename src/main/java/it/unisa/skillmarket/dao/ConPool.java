package it.unisa.skillmarket.dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Classe di utilità per la gestione delle connessioni al database.
 * Utilizza DriverManager (API standard Java SE) per aprire connessioni
 * leggendo i parametri da db.properties nel classpath.
 *
 * Non richiede librerie esterne oltre al driver JDBC del DBMS.
 */
public class ConPool {

    private static String url;
    private static String username;
    private static String password;

    // Blocco di inizializzazione statica: carica le proprietà una sola volta
    static {
        try {
            Properties props = loadProperties();
            url      = props.getProperty("db.url");
            username = props.getProperty("db.username");
            password = props.getProperty("db.password");

            // Carica esplicitamente il driver JDBC (necessario in alcuni ambienti)
            String driver = props.getProperty("db.driver");
            if (driver != null && !driver.isEmpty()) {
                Class.forName(driver);
            }
        } catch (Exception e) {
            throw new ExceptionInInitializerError("Impossibile inizializzare ConPool: " + e.getMessage());
        }
    }

    // Costruttore privato: impedisce l'istanziazione
    private ConPool() {}

    /**
     * Restituisce una nuova connessione al database.
     *
     * @return Connection attiva verso il database configurato.
     * @throws SQLException in caso di problemi di connessione.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }

    /**
     * Carica db.properties dal classpath (src/main/resources).
     */
    private static Properties loadProperties() throws IOException, SQLException {
        Properties props = new Properties();
        try (InputStream in = ConPool.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new SQLException("File db.properties non trovato nel classpath. " +
                        "Verificare che sia presente in src/main/resources/.");
            }
            props.load(in);
        }
        return props;
    }
}