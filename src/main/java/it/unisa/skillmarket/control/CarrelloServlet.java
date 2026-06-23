package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.ServizioDAO;
import it.unisa.skillmarket.model.ServizioBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet per la gestione del carrello basato su sessione.
 * Il carrello è una List di ServizioBean salvata in sessione con la chiave "carrello".
 *
 * GET  → Mostra il contenuto del carrello (carrello.jsp).
 * POST → Aggiunge o rimuove un servizio dal carrello.
 *        Parametri: action ("aggiungi" o "rimuovi"), id (id_servizio).
 */
@WebServlet("/carrello")
public class CarrelloServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) session.getAttribute("carrello");
        if (carrello == null) {
            carrello = new ArrayList<>();
        }

        request.setAttribute("carrello", carrello);
        request.getRequestDispatcher("/WEB-INF/view/carrello.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if (action == null || idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parametri mancanti.");
            return;
        }

        HttpSession session = request.getSession();

        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) session.getAttribute("carrello");
        if (carrello == null) {
            carrello = new ArrayList<>();
        }

        try {
            int idServizio = Integer.parseInt(idParam);

            switch (action) {
                case "aggiungi":
                    // Verifico che il servizio non sia già nel carrello
                    boolean giaPresente = carrello.stream()
                            .anyMatch(s -> s.getIdServizio() == idServizio);

                    if (!giaPresente) {
                        ServizioDAO dao = new ServizioDAO();
                        ServizioBean servizio = dao.doRetrieveById(idServizio);
                        if (servizio != null) {
                            carrello.add(servizio);
                        }
                    }
                    break;

                case "rimuovi":
                    carrello.removeIf(s -> s.getIdServizio() == idServizio);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Azione non riconosciuta.");
                    return;
            }

            session.setAttribute("carrello", carrello);

            // Redirect POST → GET per evitare doppio invio
            response.sendRedirect(request.getContextPath() + "/carrello");

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID servizio non valido.");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore di sistema.");
        }
    }
}
