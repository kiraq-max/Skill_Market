<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.skillmarket.model.ServizioBean" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<%@ page import="java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Il tuo carrello su SkillMarket — gestisci i servizi selezionati e procedi all'acquisto.">
    <title>Carrello — SkillMarket</title>

    <!-- CSS esterno (specifica: separare CSS dal JSP, cartella styles/) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
</head>
<body class="cart-page">

    <%
        // Recupero attributi impostati dalla CarrelloServlet
        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) request.getAttribute("carrello");

        // Utente loggato (dalla sessione)
        UtenteBean utente = (UtenteBean) session.getAttribute("utente");

        // Calcolo totale carrello
        BigDecimal totale = BigDecimal.ZERO;
        if (carrello != null) {
            for (ServizioBean s : carrello) {
                totale = totale.add(s.getPrezzoCorrente());
            }
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
                <a href="${pageContext.request.contextPath}/carrello" class="nav-link active" id="navCarrello">
                    &#128722; Carrello
                    <% if (carrello != null && !carrello.isEmpty()) { %>
                        <span class="cart-badge" id="cartBadge"><%= carrello.size() %></span>
                    <% } %>
                </a>

                <% if (utente != null) { %>
                    <a href="${pageContext.request.contextPath}/area-personale" class="nav-link" id="navAreaPersonale">
                        &#128100; Area Personale
                    </a>
                    <span class="nav-user" id="navUser">
                        &#128100; <%= utente.getNome() %>
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-link-logout" id="navLogout">
                        Esci
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-nav" id="navLogin">
                        Accedi
                    </a>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- ============================================
         CONTENUTO PRINCIPALE — CARRELLO
         ============================================ -->
    <main class="cart-layout">

        <div class="cart-header">
            <h1>&#128722; Il tuo carrello</h1>
            <p class="cart-subtitle">
                <% if (carrello != null && !carrello.isEmpty()) { %>
                    <strong><%= carrello.size() %></strong> serviz<%= carrello.size() == 1 ? "io" : "i" %> nel carrello
                <% } else { %>
                    Nessun servizio nel carrello
                <% } %>
            </p>
        </div>

        <% if (carrello != null && !carrello.isEmpty()) { %>

            <div class="cart-content" id="cartContent">

                <!-- Lista elementi carrello -->
                <div class="cart-items" id="cartItems">
                    <% for (ServizioBean s : carrello) { %>
                        <article class="cart-item" id="cartItem_<%= s.getIdServizio() %>">

                            <!-- Immagine -->
                            <div class="cart-item-img">
                                <img src="${pageContext.request.contextPath}/images/<%= s.getImmaginePath() != null ? s.getImmaginePath() : "default_service.png" %>"
                                     alt="<%= s.getTitolo() %>"
                                     loading="lazy">
                            </div>

                            <!-- Info -->
                            <div class="cart-item-info">
                                <h3 class="cart-item-title">
                                    <a href="${pageContext.request.contextPath}/servizio?id=<%= s.getIdServizio() %>">
                                        <%= s.getTitolo() %>
                                    </a>
                                </h3>
                                <p class="cart-item-desc">
                                    <%
                                        String desc = s.getDescrizione();
                                        if (desc != null && desc.length() > 80) {
                                            desc = desc.substring(0, 80) + "…";
                                        }
                                    %>
                                    <%= desc != null ? desc : "" %>
                                </p>
                            </div>

                            <!-- Prezzo -->
                            <div class="cart-item-price">
                                &euro; <%= s.getPrezzoCorrente() %>
                            </div>

                            <!-- Rimuovi -->
                            <form action="${pageContext.request.contextPath}/carrello" method="post" class="cart-item-remove">
                                <input type="hidden" name="action" value="rimuovi">
                                <input type="hidden" name="id" value="<%= s.getIdServizio() %>">
                                <button type="submit" class="btn-remove" id="btnRemove_<%= s.getIdServizio() %>"
                                        title="Rimuovi dal carrello" aria-label="Rimuovi <%= s.getTitolo() %> dal carrello">
                                    &#128465;
                                </button>
                            </form>

                        </article>
                    <% } %>
                </div>

                <!-- Riepilogo laterale -->
                <aside class="cart-summary" id="cartSummary">
                    <h2>Riepilogo Ordine</h2>

                    <div class="cart-summary-rows">
                        <div class="cart-summary-row">
                            <span>Servizi (<%= carrello.size() %>)</span>
                            <span>&euro; <%= totale %></span>
                        </div>
                        <div class="cart-summary-row">
                            <span>Commissioni piattaforma</span>
                            <span class="text-free">Gratis</span>
                        </div>
                    </div>

                    <div class="cart-summary-total">
                        <span>Totale</span>
                        <span class="cart-total-value">&euro; <%= totale %></span>
                    </div>

                    <% if (utente != null) { %>
                        <a href="${pageContext.request.contextPath}/checkout" class="btn btn-checkout" id="btnCheckout">
                            Procedi al Checkout &#8594;
                        </a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-checkout" id="btnLoginToCheckout">
                            Accedi per acquistare &#8594;
                        </a>
                        <p class="cart-login-hint">Devi effettuare il login per completare l'acquisto.</p>
                    <% } %>

                    <a href="${pageContext.request.contextPath}/catalogo" class="btn-continue-shopping" id="btnContinueShopping">
                        &#8592; Continua lo shopping
                    </a>
                </aside>

            </div>

        <% } else { %>
            <!-- Stato vuoto -->
            <div class="empty-state" id="emptyCart">
                <div class="empty-state-icon">&#128722;</div>
                <h2>Il carrello è vuoto</h2>
                <p>Non hai ancora aggiunto nessun servizio al carrello.<br>Esplora il catalogo e trova il professionista perfetto per il tuo progetto!</p>
                <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-primary" id="btnExploreCatalog">
                    Esplora il catalogo
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
