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
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/gestione")
public class GestioneServizioServlet extends HttpServlet {

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

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            CategoriaDAO categoriaDAO = new CategoriaDAO();
            List<CategoriaBean> categorie = categoriaDAO.doRetrieveAll();
            request.setAttribute("categorie", categorie);

            if ("add".equals(action)) {
                // Mostra il form vuoto
                request.getRequestDispatcher("/WEB-INF/view/formServizio.jsp").forward(request, response);
            } else if ("edit".equals(action)) {
                // Carica il servizio e mostra il form compilato
                int id = Integer.parseInt(request.getParameter("id"));
                ServizioDAO servizioDAO = new ServizioDAO();
                ServizioBean servizio = servizioDAO.doRetrieveById(id);
                
                if (servizio != null) {
                    request.setAttribute("servizio", servizio);
                    request.getRequestDispatcher("/WEB-INF/view/formServizio.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?errore=Servizio+non+trovato");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            }

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?errore=Errore+di+sistema");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String action = request.getParameter("action");
        ServizioDAO dao = new ServizioDAO();

        try {
            if ("insert".equals(action) || "update".equals(action)) {
                String titolo = request.getParameter("titolo");
                String descrizione = request.getParameter("descrizione");
                String prezzoStr = request.getParameter("prezzo");
                String idCategoriaStr = request.getParameter("categoria");
                String immagine = request.getParameter("immagine");
                
                // Immagine default se vuota
                if(immagine == null || immagine.trim().isEmpty()) {
                    immagine = "default_service.png";
                }

                ServizioBean servizio = new ServizioBean();
                servizio.setTitolo(titolo);
                servizio.setDescrizione(descrizione);
                servizio.setPrezzoCorrente(new BigDecimal(prezzoStr));
                servizio.setImmaginePath(immagine);
                servizio.setIdCategoria(Integer.parseInt(idCategoriaStr));
                servizio.setIdVenditore(utente.getIdUtente());

                if ("insert".equals(action)) {
                    dao.doSave(servizio);
                } else if ("update".equals(action)) {
                    servizio.setIdServizio(Integer.parseInt(request.getParameter("id")));
                    dao.doUpdate(servizio);
                }
                
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?successo=Operazione+completata");

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.doDelete(id);
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?successo=Servizio+eliminato");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?errore=Errore+nel+salvataggio");
        }
    }
}
