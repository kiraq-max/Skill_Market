package it.unisa.skillmarket.control;

import it.unisa.skillmarket.model.UtenteBean;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtro centralizzato per il controllo degli accessi alle risorse protette.
 *
 * Strategia:
 *  - Tutte le URL sotto /admin/* sono accessibili solo ad AMMINISTRATORE o VENDITORE.
 *  - /area-personale e /checkout sono accessibili solo ad utenti autenticati.
 *  - Il controllo viene fatto verificando sia la presenza del token di sessione
 *    (impostato al login) sia la correttezza del ruolo dell'utente.
 *
 * Questo filtro implementa il requisito non funzionale della specifica TSW:
 * "Usare il token nella sessione per il controllo degli accessi alle Servlet".
 */
@WebFilter(urlPatterns = { "/admin/*", "/area-personale", "/checkout" })
public class AccessControlFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Nessuna inizializzazione necessaria
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);

        // 1. Verifica presenza sessione e token
        String token = (session != null) ? (String) session.getAttribute("sessionToken") : null;

        if (token == null || token.isEmpty()) {
            // Nessun token → utente non autenticato, redirect al login
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Token presente → recupera l'utente dalla sessione
        UtenteBean utente = (UtenteBean) session.getAttribute("utente");

        if (utente == null) {
            // Token orfano (situazione anomala): invalida la sessione e redirect
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 3. Controllo ruolo per le URL admin
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String adminPath = contextPath + "/admin/";

        if (requestURI.startsWith(adminPath)) {
            String ruolo = utente.getRuolo();
            if (!"AMMINISTRATORE".equals(ruolo) && !"VENDITORE".equals(ruolo)) {
                // Utente autenticato ma non autorizzato → redirect al catalogo
                response.sendRedirect(contextPath + "/catalogo");
                return;
            }
        }

        // 4. Tutto ok → passa la richiesta alla servlet di destinazione
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Nessuna pulizia necessaria
    }
}
