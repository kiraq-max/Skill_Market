<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="it.unisa.skillmarket.model.OrdineBean" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Ordine confermato su SkillMarket — grazie per il tuo acquisto!">
    <title>Ordine Confermato — SkillMarket</title>

    <!-- CSS esterno (specifica: separare CSS dal JSP, cartella styles/) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
</head>
<body class="confirm-page">

    <%
        // Recupero attributi impostati dalla CheckoutServlet dopo il checkout riuscito
        OrdineBean ordine = (OrdineBean) request.getAttribute("ordine");

        // Utente loggato (dalla sessione)
        UtenteBean utente = (UtenteBean) session.getAttribute("utente");

        // Formattazione data ordine
        String dataFormattata = "";
        if (ordine != null && ordine.getDataOrdine() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy 'alle' HH:mm");
            dataFormattata = sdf.format(ordine.getDataOrdine());
        }
    %>

    <!-- ============================================
         NAVBAR
         ============================================ -->
    <nav class="navbar" id="mainNavbar">
        <div class="navbar-inner">
            <!-- Brand -->
            <a href="${pageContext.request.contextPath}/catalogo" class="navbar-brand" id="navBrand">
                <span class="navbar-brand-icon">&#128188;</span>
                <span class="navbar-brand-text">Skill<span>Market</span></span>
            </a>

            <!-- Navigation Links -->
            <div class="navbar-links">
                <a href="${pageContext.request.contextPath}/catalogo" class="nav-link" id="navCatalogo">
                    &#128218; Catalogo
                </a>
                <a href="${pageContext.request.contextPath}/carrello" class="nav-link" id="navCarrello">
                    &#128722; Carrello
                </a>

                <% if (utente != null) { %>
                    <span class="nav-user" id="navUser">
                        &#128100; <%= utente.getNome() %>
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-link-logout" id="navLogout">
                        Esci
                    </a>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- ============================================
         CONTENUTO PRINCIPALE — CONFERMA ORDINE
         ============================================ -->
    <main class="confirm-layout">

        <% if (ordine != null) { %>

            <!-- Icona e messaggio di successo -->
            <div class="confirm-hero" id="confirmHero">
                <div class="confirm-checkmark" id="confirmCheckmark">
                    <svg viewBox="0 0 52 52" class="checkmark-svg">
                        <circle class="checkmark-circle" cx="26" cy="26" r="25" fill="none"/>
                        <path class="checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                    </svg>
                </div>
                <h1>Ordine Confermato!</h1>
                <p class="confirm-subtitle">
                    Grazie, <strong><%= utente != null ? utente.getNome() : "" %></strong>! Il tuo ordine è stato elaborato con successo.
                </p>
            </div>

            <!-- Dettagli ordine -->
            <div class="confirm-card" id="confirmCard">
                <h2>Dettagli dell'ordine</h2>

                <div class="confirm-details">
                    <div class="confirm-detail-row">
                        <span class="confirm-label">&#128196; Numero Ordine</span>
                        <span class="confirm-value confirm-order-id">#<%= ordine.getIdOrdine() %></span>
                    </div>

                    <div class="confirm-detail-row">
                        <span class="confirm-label">&#128197; Data</span>
                        <span class="confirm-value"><%= dataFormattata %></span>
                    </div>

                    <div class="confirm-detail-row">
                        <span class="confirm-label">&#128176; Totale Pagato</span>
                        <span class="confirm-value confirm-total">&euro; <%= ordine.getTotaleOrdine() %></span>
                    </div>

                    <div class="confirm-detail-row">
                        <span class="confirm-label">&#128205; Indirizzo di Spedizione</span>
                        <span class="confirm-value"><%= ordine.getIndirizzoSpedizione() %></span>
                    </div>

                    <div class="confirm-detail-row">
                        <span class="confirm-label">&#128179; Metodo di Pagamento</span>
                        <span class="confirm-value"><%= ordine.getDatiPagamento() %></span>
                    </div>
                </div>
            </div>

            <!-- Azioni post-conferma -->
            <div class="confirm-actions" id="confirmActions">
                <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-checkout" id="btnBackToCatalog">
                    &#128218; Continua ad esplorare
                </a>
            </div>

        <% } else { %>
            <!-- Ordine non trovato (accesso diretto alla pagina) -->
            <div class="empty-state" id="emptyConfirm">
                <div class="empty-state-icon">&#128533;</div>
                <h2>Nessun ordine da visualizzare</h2>
                <p>Sembra che tu sia arrivato qui per errore.<br>Torna al catalogo per iniziare un nuovo acquisto.</p>
                <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-primary" id="btnGoToCatalog">
                    Vai al catalogo
                </a>
            </div>
        <% } %>

    </main>

    <!-- Footer -->
    <footer class="site-footer" id="siteFooter">
        <p>&copy; 2026 SkillMarket — Progetto TSW, Università degli Studi di Salerno</p>
    </footer>

</body>
</html>
