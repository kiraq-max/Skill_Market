package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.UtenteDAO;
import it.unisa.skillmarket.model.UtenteBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;

/**
 * Servlet per la gestione della registrazione di un nuovo utente.
 * GET  → Mostra il form di registrazione (registrazione.jsp).
 * POST → Processa i dati del form, salva l'utente nel DB e redireziona al login.
 */
@WebServlet("/registrazione")
public class RegistrazioneServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Mostra il form di registrazione
        request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Recupero i parametri dal form
        String nome = request.getParameter("nome");
        String cognome = request.getParameter("cognome");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confermaPassword = request.getParameter("confermaPassword");

        // Validazione lato server
        if (nome == null || nome.trim().isEmpty() ||
            cognome == null || cognome.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("errore", "Tutti i campi sono obbligatori.");
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confermaPassword)) {
            request.setAttribute("errore", "Le password non corrispondono.");
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            return;
        }

        if (password.length() < 8) {
            request.setAttribute("errore", "La password deve essere di almeno 8 caratteri.");
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
            return;
        }

        try {
            // Creo il bean utente e lo salvo nel database
            UtenteBean utente = new UtenteBean();
            utente.setNome(nome.trim());
            utente.setCognome(cognome.trim());
            utente.setEmail(email.trim());
            utente.setPasswordHash(hashPassword(password));
            utente.setRuolo("CLIENTE"); // Registrazione standard → ruolo CLIENTE

            UtenteDAO dao = new UtenteDAO();
            dao.doSave(utente);

            // Registrazione riuscita: redirect al login con messaggio di successo
            response.sendRedirect(request.getContextPath() + "/login?registrato=true");

        } catch (SQLException e) {
            // Gestione email duplicata (violazione UNIQUE constraint)
            if (e.getMessage() != null && e.getMessage().contains("Duplicate")) {
                request.setAttribute("errore", "Esiste già un account con questa email.");
            } else {
                request.setAttribute("errore", "Errore di sistema. Riprova più tardi.");
                e.printStackTrace();
            }
            request.getRequestDispatcher("/WEB-INF/view/registrazione.jsp").forward(request, response);
        }
    }

    /**
     * Genera l'hash SHA-256 della password in formato esadecimale.
     */
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 non disponibile", e);
        }
    }
}
