package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.OrdineDAO;
import it.unisa.skillmarket.dao.UtenteDAO;
import it.unisa.skillmarket.model.OrdineBean;
import it.unisa.skillmarket.model.UtenteBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet per la visualizzazione e il filtraggio degli ordini nel pannello admin.
 *
 * GET → Mostra la lista di tutti gli ordini, con filtri opzionali:
 *       - dataInizio / dataFine  (formato yyyy-MM-dd)
 *       - emailCliente           (email esatta del cliente)
 *
 * Accesso: solo AMMINISTRATORE o VENDITORE (controllato anche da AccessControlFilter).
 */
@WebServlet("/admin/ordini")
public class AdminOrdiniServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Doppio controllo (il filtro AccessControlFilter già protegge /admin/*)
        if (session == null || session.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        UtenteBean admin = (UtenteBean) session.getAttribute("utente");
        if (!"AMMINISTRATORE".equals(admin.getRuolo()) && !"VENDITORE".equals(admin.getRuolo())) {
            response.sendRedirect(request.getContextPath() + "/catalogo");
            return;
        }

        // Leggo i parametri di filtro (tutti opzionali)
        String dataInizioStr = request.getParameter("dataInizio");
        String dataFineStr   = request.getParameter("dataFine");
        String emailCliente  = request.getParameter("emailCliente");

        try {
            OrdineDAO ordineDAO = new OrdineDAO();
            UtenteDAO utenteDAO = new UtenteDAO();
            List<OrdineBean> ordini;

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false);

            // Applico il filtro corretto in base ai parametri presenti
            if (emailCliente != null && !emailCliente.trim().isEmpty()) {
                // Filtro per email cliente
                ordini = ordineDAO.doRetrieveByClienteEmail(emailCliente.trim());
                request.setAttribute("filtroEmail", emailCliente.trim());

            } else if (dataInizioStr != null && !dataInizioStr.isEmpty()
                    && dataFineStr != null && !dataFineStr.isEmpty()) {
                // Filtro per intervallo di date
                Timestamp tsInizio = new Timestamp(sdf.parse(dataInizioStr).getTime());
                // Fine giornata: aggiungo 86399 secondi (23:59:59)
                Timestamp tsFine = new Timestamp(sdf.parse(dataFineStr).getTime() + 86399000L);
                ordini = ordineDAO.doRetrieveByDateRange(tsInizio, tsFine);
                request.setAttribute("filtroDataInizio", dataInizioStr);
                request.setAttribute("filtroDataFine", dataFineStr);

            } else {
                // Nessun filtro: tutti gli ordini
                ordini = ordineDAO.doRetrieveAll();
            }

            // Per ogni ordine recupero i dati del cliente (nome, cognome, email)
            // e li metto in una mappa parallela per la JSP
            Map<OrdineBean, UtenteBean> ordiniConClienti = new LinkedHashMap<>();
            for (OrdineBean ordine : ordini) {
                UtenteBean cliente = utenteDAO.doRetrieveById(ordine.getIdCliente());
                ordiniConClienti.put(ordine, cliente);
            }

            request.setAttribute("ordiniConClienti", ordiniConClienti);
            request.setAttribute("totaleOrdini", ordini.size());
            request.getRequestDispatcher("/WEB-INF/view/adminOrdini.jsp").forward(request, response);

        } catch (ParseException e) {
            request.setAttribute("errore", "Formato data non valido. Usa il formato gg/mm/aaaa.");
            request.getRequestDispatcher("/WEB-INF/view/adminOrdini.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore nel caricamento degli ordini.");
            request.getRequestDispatcher("/WEB-INF/view/adminOrdini.jsp").forward(request, response);
        }
    }
}
