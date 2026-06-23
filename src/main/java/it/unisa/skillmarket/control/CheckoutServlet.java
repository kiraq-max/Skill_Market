package it.unisa.skillmarket.control;

import it.unisa.skillmarket.dao.DettaglioOrdineDAO;
import it.unisa.skillmarket.dao.OrdineDAO;
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
import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet per la gestione del checkout.
 * GET  → Mostra il form di checkout con riepilogo carrello (checkout.jsp).
 * POST → Processa l'ordine: crea la testata e i dettagli, poi svuota il carrello.
 */
@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Verifico che l'utente sia autenticato
        if (session == null || session.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Verifico che il carrello non sia vuoto
        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) session.getAttribute("carrello");
        if (carrello == null || carrello.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/carrello");
            return;
        }

        // Calcolo il totale per la visualizzazione nel form
        BigDecimal totale = carrello.stream()
                .map(ServizioBean::getPrezzoCorrente)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        request.setAttribute("carrello", carrello);
        request.setAttribute("totale", totale);
        request.getRequestDispatcher("/WEB-INF/view/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Controllo autenticazione
        if (session == null || session.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UtenteBean utente = (UtenteBean) session.getAttribute("utente");

        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) session.getAttribute("carrello");
        if (carrello == null || carrello.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/carrello");
            return;
        }

        // Recupero dati dal form di checkout
        String indirizzo = request.getParameter("indirizzo");
        String datiPagamento = request.getParameter("datiPagamento");

        if (indirizzo == null || indirizzo.trim().isEmpty() ||
            datiPagamento == null || datiPagamento.trim().isEmpty()) {

            request.setAttribute("errore", "Tutti i campi sono obbligatori.");
            doGet(request, response);
            return;
        }

        try {
            // Calcolo il totale dell'ordine congelando i prezzi attuali
            BigDecimal totale = carrello.stream()
                    .map(ServizioBean::getPrezzoCorrente)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // 1. Creo la testata dell'ordine
            OrdineBean ordine = new OrdineBean();
            ordine.setIdCliente(utente.getIdUtente());
            ordine.setDataOrdine(new Timestamp(System.currentTimeMillis()));
            ordine.setTotaleOrdine(totale);
            ordine.setIndirizzoSpedizione(indirizzo.trim());
            ordine.setDatiPagamento(datiPagamento.trim());

            OrdineDAO ordineDAO = new OrdineDAO();
            int idOrdine = ordineDAO.doSave(ordine);

            if (idOrdine <= 0) {
                request.setAttribute("errore", "Errore nella creazione dell'ordine.");
                doGet(request, response);
                return;
            }

            // 2. Creo un dettaglio per ogni servizio nel carrello (prezzo congelato)
            DettaglioOrdineDAO dettaglioDAO = new DettaglioOrdineDAO();
            for (ServizioBean servizio : carrello) {
                DettaglioOrdineBean dettaglio = new DettaglioOrdineBean();
                dettaglio.setIdOrdine(idOrdine);
                dettaglio.setIdServizio(servizio.getIdServizio());
                dettaglio.setQuantita(1); // Ogni servizio digitale è acquistato in singola copia
                dettaglio.setPrezzoAcquisto(servizio.getPrezzoCorrente()); // PREZZO CONGELATO!
                dettaglioDAO.doSave(dettaglio);
            }

            // 3. Svuoto il carrello dopo il checkout riuscito
            session.removeAttribute("carrello");

            // Redirect alla pagina di conferma
            request.setAttribute("ordine", ordine);
            request.getRequestDispatcher("/WEB-INF/view/confermaOrdine.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore durante il checkout. Riprova.");
            doGet(request, response);
        }
    }
}
