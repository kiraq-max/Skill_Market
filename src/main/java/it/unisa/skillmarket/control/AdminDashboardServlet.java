package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.CategoriaDAO;
import it.unisa.skillmarket.dao.ServizioDAO;
import it.unisa.skillmarket.model.CategoriaBean;
import it.unisa.skillmarket.model.ServizioBean;
import it.unisa.skillmarket.model.UtenteBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UtenteBean utente = (UtenteBean) session.getAttribute("utente");
        if (!"AMMINISTRATORE".equals(utente.getRuolo()) && !"VENDITORE".equals(utente.getRuolo())) {
            response.sendRedirect(request.getContextPath() + "/catalogo");
            return;
        }

        try {
            ServizioDAO servizioDAO = new ServizioDAO();
            CategoriaDAO categoriaDAO = new CategoriaDAO();

            List<ServizioBean> servizi = servizioDAO.doRetrieveAll();
            List<CategoriaBean> categorie = categoriaDAO.doRetrieveAll();

            request.setAttribute("servizi", servizi);
            request.setAttribute("categorie", categorie);

            request.getRequestDispatcher("/WEB-INF/view/adminCatalogo.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore nel caricamento del pannello di amministrazione.");
            request.getRequestDispatcher("/WEB-INF/view/adminCatalogo.jsp").forward(request, response);
        }
    }
}
