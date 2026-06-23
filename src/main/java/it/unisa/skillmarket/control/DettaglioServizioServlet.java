package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.ServizioDAO;
import it.unisa.skillmarket.model.ServizioBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet per la visualizzazione del dettaglio di un singolo servizio.
 * GET → Mostra la pagina dettaglio con tutte le informazioni del servizio.
 * Parametro richiesto: id (id_servizio).
 */
@WebServlet("/servizio")
public class DettaglioServizioServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID servizio mancante.");
            return;
        }

        try {
            int idServizio = Integer.parseInt(idParam);
            ServizioDAO dao = new ServizioDAO();
            ServizioBean servizio = dao.doRetrieveById(idServizio);

            if (servizio == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Servizio non trovato.");
                return;
            }

            request.setAttribute("servizio", servizio);
            request.getRequestDispatcher("/WEB-INF/view/dettaglioServizio.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID servizio non valido.");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore di sistema.");
        }
    }
}
