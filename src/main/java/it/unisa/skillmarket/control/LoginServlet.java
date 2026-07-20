package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.UtenteDAO;
import it.unisa.skillmarket.model.UtenteBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.UUID;

/**
 * Servlet per la gestione del login utente.
 * GET → Mostra il form di login (login.jsp).
 * POST → Autentica l'utente e crea la sessione.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Se l'utente viene dalla registrazione, mostro un messaggio di successo
        if ("true".equals(request.getParameter("registrato"))) {
            request.setAttribute("successo", "Registrazione completata! Effettua il login.");
        }

        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validazione base
        if (email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            request.setAttribute("errore", "Inserisci email e password.");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            return;
        }

        try {
            UtenteDAO dao = new UtenteDAO();
            UtenteBean utente = dao.doRetrieveByEmailAndPassword(email.trim(), hashPassword(password));

            if (utente != null) {
                // Autenticazione riuscita: creo la sessione
                HttpSession session = request.getSession(true);
                session.setAttribute("utente", utente);
                session.setMaxInactiveInterval(30 * 60); // 30 minuti di timeout

                // Genero un token univoco e lo salvo nella sessione.
                // Requisito non funzionale TSW: "token nella sessione per il controllo degli accessi".
                // Il filtro AccessControlFilter verifica la presenza di questo token
                // su tutte le URL protette (/admin/*, /area-personale, /checkout).
                String sessionToken = UUID.randomUUID().toString();
                session.setAttribute("sessionToken", sessionToken);

                // Redirect basato sul ruolo
                switch (utente.getRuolo()) {
                    case "AMMINISTRATORE":
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/catalogo");
                        break;
                }
            } else {
                // Credenziali errate
                request.setAttribute("errore", "Email o password non corrette.");
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            request.setAttribute("errore", "Errore di sistema. Riprova più tardi.");
            e.printStackTrace();
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
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
                if (hex.length() == 1)
                    hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 non disponibile", e);
        }
    }
}

// "Questa Servlet gestisce il ciclo di vita dell'autenticazione. Via GET serve
// il modulo JSP protetto nel WEB-INF. Via POST valida l'input, applica
// l'hashing SHA-256 alla password per confrontarla col database tramite il DAO,
// e se l'esito è positivo istanzia una HttpSession impostando un timeout di 30
// minuti. Infine, smista l'utente sulla dashboard o sul catalogo a seconda del
// suo Ruolo, usando una redirect per prevenire il reinvio del form."