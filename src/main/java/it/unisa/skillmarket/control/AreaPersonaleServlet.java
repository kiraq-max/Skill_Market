package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.DettaglioOrdineDAO;
import it.unisa.skillmarket.dao.OrdineDAO;
import it.unisa.skillmarket.dao.ServizioDAO;
import it.unisa.skillmarket.model.DettaglioOrdineBean;
import it.unisa.skillmarket.model.OrdineBean;
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
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet per la gestione dell'area personale del cliente.
 *
 * GET → Recupera lo storico ordini dell'utente loggato e lo invia alla view
 *       areaPersonale.jsp. Per ogni ordine vengono caricati anche i dettagli
 *       (servizi acquistati con il prezzo congelato al momento dell'acquisto).
 *
 * Accesso: solo utenti autenticati (qualsiasi ruolo).
 */
@WebServlet("/area-personale")
public class AreaPersonaleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Verifica autenticazione
        if (session == null || session.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UtenteBean utente = (UtenteBean) session.getAttribute("utente");

        try {
            OrdineDAO ordineDAO = new OrdineDAO();
            DettaglioOrdineDAO dettaglioDAO = new DettaglioOrdineDAO();
            ServizioDAO servizioDAO = new ServizioDAO();

            // Recupero lo storico ordini del cliente, dal più recente
            List<OrdineBean> ordini = ordineDAO.doRetrieveByCliente(utente.getIdUtente());

            // Per ogni ordine, carico i dettagli (righe d'ordine + dati servizio)
            // Utilizzo una LinkedHashMap per mantenere l'ordine di inserimento
            Map<OrdineBean, List<DettaglioOrdineBean>> ordiniConDettagli = new LinkedHashMap<>();

            for (OrdineBean ordine : ordini) {
                List<DettaglioOrdineBean> dettagli = dettaglioDAO.doRetrieveByOrdine(ordine.getIdOrdine());

                // Arricchisco ogni dettaglio con i dati del servizio (titolo, immagine)
                // in modo che la JSP possa mostrarli senza logica aggiuntiva
                for (DettaglioOrdineBean dettaglio : dettagli) {
                    ServizioBean servizio = servizioDAO.doRetrieveById(dettaglio.getIdServizio());
                    dettaglio.setServizio(servizio); // Vedi nota: aggiunta campo transiente al bean
                }

                ordiniConDettagli.put(ordine, dettagli);
            }

            request.setAttribute("utente", utente);
            request.setAttribute("ordiniConDettagli", ordiniConDettagli);
            request.getRequestDispatcher("/WEB-INF/view/areaPersonale.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore nel caricamento dello storico ordini.");
            request.getRequestDispatcher("/WEB-INF/view/areaPersonale.jsp").forward(request, response);
        }
    }
}
