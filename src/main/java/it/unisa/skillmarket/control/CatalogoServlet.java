package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.CategoriaDAO;
import it.unisa.skillmarket.dao.ServizioDAO;
import it.unisa.skillmarket.model.CategoriaBean;
import it.unisa.skillmarket.model.ServizioBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet per la visualizzazione del catalogo servizi.
 * GET (normale) → Carica la pagina JSP completa.
 * GET (AJAX)    → Risponde con un JSON array dei servizi (header X-Requested-With: XMLHttpRequest).
 */
@WebServlet("/catalogo")
public class CatalogoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            ServizioDAO servizioDAO = new ServizioDAO();
            CategoriaDAO categoriaDAO = new CategoriaDAO();

            // Recupero il parametro di filtro per categoria (opzionale)
            String idCategoriaParam = request.getParameter("categoria");
            List<ServizioBean> servizi;

            if (idCategoriaParam != null && !idCategoriaParam.trim().isEmpty()) {
                int idCategoria = Integer.parseInt(idCategoriaParam);
                servizi = servizioDAO.doRetrieveByCategory(idCategoria);
                request.setAttribute("categoriaSelezionata", idCategoria);
            } else {
                servizi = servizioDAO.doRetrieveAll();
            }

            // -------------------------------------------------------
            // AJAX: se la richiesta proviene da fetch() (header custom),
            // rispondiamo con JSON invece di fare il forward alla JSP.
            // -------------------------------------------------------
            String ajaxHeader = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(ajaxHeader)) {
                response.setContentType("application/json;charset=UTF-8");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                out.print(serviziToJson(servizi, request.getContextPath()));
                out.flush();
                return;
            }

            // Richiesta normale: carico le categorie e faccio forward alla JSP
            List<CategoriaBean> categorie = categoriaDAO.doRetrieveAll();
            request.setAttribute("categorie", categorie);
            request.setAttribute("servizi", servizi);
            request.getRequestDispatcher("/WEB-INF/view/catalogo.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parametro categoria non valido.");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore nel caricamento del catalogo.");
            request.getRequestDispatcher("/WEB-INF/view/catalogo.jsp").forward(request, response);
        }
    }

    /**
     * Converte una lista di ServizioBean in una stringa JSON.
     * Costruzione manuale per evitare dipendenze esterne (es. Gson/Jackson).
     */
    private String serviziToJson(List<ServizioBean> servizi, String contextPath) {
        StringBuilder sb = new StringBuilder("[");
        if (servizi != null) {
            for (int i = 0; i < servizi.size(); i++) {
                ServizioBean s = servizi.get(i);
                String imgPath = (s.getImmaginePath() != null) ? s.getImmaginePath() : "default_service.png";

                // Troncamento descrizione (max 100 char) lato server, coerente con la JSP
                String desc = (s.getDescrizione() != null) ? s.getDescrizione() : "";
                if (desc.length() > 100) desc = desc.substring(0, 100) + "\u2026";

                sb.append("{");
                sb.append("\"id\":").append(s.getIdServizio()).append(",");
                sb.append("\"titolo\":\"").append(escapeJson(s.getTitolo())).append("\",");
                sb.append("\"descrizione\":\"").append(escapeJson(desc)).append("\",");
                sb.append("\"prezzo\":\"").append(s.getPrezzoCorrente()).append("\",");
                sb.append("\"immagine\":\"").append(escapeJson(contextPath + "/images/" + imgPath)).append("\"");
                sb.append("}");
                if (i < servizi.size() - 1) sb.append(",");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    /** Escaping minimale per stringhe JSON (caratteri speciali). */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
