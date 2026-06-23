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
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet per la visualizzazione del catalogo servizi.
 * GET → Mostra tutti i servizi attivi, con filtro opzionale per categoria.
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

            // Carico tutte le categorie per il menu di navigazione/filtro
            List<CategoriaBean> categorie = categoriaDAO.doRetrieveAll();
            request.setAttribute("categorie", categorie);

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
}
