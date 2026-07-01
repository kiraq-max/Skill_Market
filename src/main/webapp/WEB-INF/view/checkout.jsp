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
    <meta name="description" content="Completa il tuo acquisto su SkillMarket — inserisci i dati di spedizione e pagamento.">
    <title>Checkout — SkillMarket</title>

    <!-- CSS esterno (specifica: separare CSS dal JSP, cartella styles/) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
</head>
<body class="checkout-page">

    <%
        // Recupero attributi impostati dalla CheckoutServlet
        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) request.getAttribute("carrello");
        BigDecimal totale = (BigDecimal) request.getAttribute("totale");
        String errore = (String) request.getAttribute("errore");

        // Utente loggato (dalla sessione)
        UtenteBean utente = (UtenteBean) session.getAttribute("utente");
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
         CONTENUTO PRINCIPALE — CHECKOUT
         ============================================ -->
    <main class="checkout-layout">

        <!-- Breadcrumb -->
        <nav class="detail-breadcrumb" id="breadcrumb" aria-label="Percorso di navigazione">
            <a href="${pageContext.request.contextPath}/carrello">&#128722; Carrello</a>
            <span class="breadcrumb-separator">&#10095;</span>
            <span class="breadcrumb-current">Checkout</span>
        </nav>

        <h1 class="checkout-title">Completa l'acquisto</h1>

        <!-- Messaggio di errore -->
        <% if (errore != null) { %>
            <div class="alert alert-error">
                &#9888;&#65039; <%= errore %>
            </div>
        <% } %>

        <div class="checkout-grid" id="checkoutGrid">

            <!-- Colonna sinistra: Form dati -->
            <div class="checkout-form-col" id="checkoutFormCol">

                <form action="${pageContext.request.contextPath}/checkout" method="POST" id="checkoutForm" novalidate>

                    <!-- Sezione Dati di Spedizione -->
                    <fieldset class="checkout-fieldset" id="fieldsetSpedizione">
                        <legend>&#128205; Dati di Spedizione</legend>

                        <div class="form-group">
                            <label for="indirizzo">Indirizzo completo</label>
                            <textarea id="indirizzo" name="indirizzo" rows="3"
                                      placeholder="Via, numero civico, CAP, città, provincia"
                                      autocomplete="street-address"><%= request.getParameter("indirizzo") != null ? request.getParameter("indirizzo") : "" %></textarea>
                            <span class="field-error" id="indirizzo-error"></span>
                        </div>
                    </fieldset>

                    <!-- Sezione Dati di Pagamento -->
                    <fieldset class="checkout-fieldset" id="fieldsetPagamento">
                        <legend>&#128179; Dati di Pagamento</legend>

                        <div class="form-group">
                            <label for="titolareCarta">Titolare della carta</label>
                            <input type="text" id="titolareCarta" name="titolareCarta"
                                   placeholder="Nome e cognome come sulla carta"
                                   autocomplete="cc-name">
                            <span class="field-error" id="titolareCarta-error"></span>
                        </div>

                        <div class="form-group">
                            <label for="numeroCarta">Numero carta</label>
                            <input type="text" id="numeroCarta" name="numeroCarta"
                                   placeholder="1234 5678 9012 3456"
                                   autocomplete="cc-number"
                                   maxlength="19"
                                   inputmode="numeric">
                            <span class="field-error" id="numeroCarta-error"></span>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="scadenza">Scadenza</label>
                                <input type="text" id="scadenza" name="scadenza"
                                       placeholder="MM/AA"
                                       autocomplete="cc-exp"
                                       maxlength="5"
                                       inputmode="numeric">
                                <span class="field-error" id="scadenza-error"></span>
                            </div>

                            <div class="form-group">
                                <label for="cvv">CVV</label>
                                <input type="text" id="cvv" name="cvv"
                                       placeholder="123"
                                       autocomplete="cc-csc"
                                       maxlength="4"
                                       inputmode="numeric">
                                <span class="field-error" id="cvv-error"></span>
                            </div>
                        </div>

                        <!-- Campo hidden che combina i dati di pagamento per il server -->
                        <input type="hidden" id="datiPagamento" name="datiPagamento" value="">
                    </fieldset>

                    <button type="submit" class="btn btn-checkout btn-confirm-order" id="btnConfirmOrder">
                        &#128274; Conferma e Paga &euro; <%= totale != null ? totale : "0.00" %>
                    </button>

                    <p class="checkout-disclaimer">
                        &#128274; I tuoi dati di pagamento sono al sicuro. Questo è un ambiente di test.
                    </p>

                </form>

            </div>

            <!-- Colonna destra: Riepilogo ordine -->
            <aside class="checkout-summary" id="checkoutSummary">
                <h2>Riepilogo Ordine</h2>

                <% if (carrello != null && !carrello.isEmpty()) { %>
                    <div class="checkout-items">
                        <% for (ServizioBean s : carrello) { %>
                            <div class="checkout-item" id="checkoutItem_<%= s.getIdServizio() %>">
                                <div class="checkout-item-img">
                                    <img src="${pageContext.request.contextPath}/images/<%= s.getImmaginePath() != null ? s.getImmaginePath() : "default_service.png" %>"
                                         alt="<%= s.getTitolo() %>"
                                         loading="lazy">
                                </div>
                                <div class="checkout-item-info">
                                    <span class="checkout-item-title"><%= s.getTitolo() %></span>
                                    <span class="checkout-item-price">&euro; <%= s.getPrezzoCorrente() %></span>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <div class="checkout-summary-totals">
                        <div class="checkout-summary-row">
                            <span>Subtotale (<%= carrello.size() %> serviz<%= carrello.size() == 1 ? "io" : "i" %>)</span>
                            <span>&euro; <%= totale %></span>
                        </div>
                        <div class="checkout-summary-row">
                            <span>Commissioni</span>
                            <span class="text-free">Gratis</span>
                        </div>
                        <div class="checkout-summary-row checkout-summary-total">
                            <span>Totale</span>
                            <span>&euro; <%= totale %></span>
                        </div>
                    </div>
                <% } %>

                <a href="${pageContext.request.contextPath}/carrello" class="btn-back-to-cart" id="btnBackToCart">
                    &#8592; Modifica carrello
                </a>
            </aside>

        </div>

    </main>

    <!-- Footer -->
    <footer class="site-footer" id="siteFooter">
        <p>&copy; 2026 SkillMarket — Progetto TSW, Università degli Studi di Salerno</p>
    </footer>

    <!-- JS esterno (specifica: separare JS dal JSP, cartella scripts/) -->
    <script src="${pageContext.request.contextPath}/scripts/checkout.js"></script>

</body>
</html>
