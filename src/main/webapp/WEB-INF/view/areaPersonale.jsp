<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.text.SimpleDateFormat" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<%@ page import="it.unisa.skillmarket.model.OrdineBean" %>
<%@ page import="it.unisa.skillmarket.model.DettaglioOrdineBean" %>
<%@ page import="it.unisa.skillmarket.model.ServizioBean" %>
<%
    UtenteBean utente = (UtenteBean) session.getAttribute("utente");
    if (utente == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    Map<OrdineBean, List<DettaglioOrdineBean>> ordiniConDettagli =
        (Map<OrdineBean, List<DettaglioOrdineBean>>) request.getAttribute("ordiniConDettagli");

    String errore = (String) request.getAttribute("errore");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy 'alle' HH:mm");

    boolean isAdmin = "AMMINISTRATORE".equals(utente.getRuolo());
    boolean isVenditore = "VENDITORE".equals(utente.getRuolo());
%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="La tua area personale su SkillMarket — visualizza il tuo storico ordini e i servizi acquistati.">
    <title>Area Personale — SkillMarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
    <style>
        /* =============================================
           AREA PERSONALE — Stili specifici
           ============================================= */

        .ap-layout {
            max-width: 900px;
            margin: 0 auto;
            padding: 2em 1.5em 4em;
        }

        /* Hero di benvenuto */
        .ap-hero {
            display: flex;
            align-items: center;
            gap: 1.5em;
            background: linear-gradient(135deg, rgba(123, 104, 238, 0.15), rgba(78, 205, 196, 0.08));
            border: 1px solid rgba(123, 104, 238, 0.25);
            border-radius: 20px;
            padding: 2em 2.5em;
            margin-bottom: 2.5em;
        }

        .ap-avatar {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: linear-gradient(135deg, #7b68ee, #4ecdc4);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            flex-shrink: 0;
            box-shadow: 0 4px 20px rgba(123, 104, 238, 0.4);
        }

        .ap-hero-info h1 {
            font-size: 1.6rem;
            color: #f0f0f0;
            margin: 0 0 0.25em;
        }

        .ap-hero-info p {
            color: #a0a0c0;
            font-size: 0.9rem;
            margin: 0;
        }

        .ap-badge {
            display: inline-block;
            padding: 0.2em 0.75em;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            margin-top: 0.5em;
        }
        .badge-cliente      { background: rgba(78, 205, 196, 0.15); color: #4ecdc4; border: 1px solid rgba(78, 205, 196, 0.3); }
        .badge-venditore    { background: rgba(255, 193, 7, 0.15);  color: #ffc107; border: 1px solid rgba(255, 193, 7, 0.3); }
        .badge-admin        { background: rgba(239, 68, 68, 0.15);  color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.3); }

        /* Sezione titolo storico */
        .ap-section-title {
            font-size: 1.2rem;
            color: #c0c0e0;
            margin-bottom: 1.2em;
            display: flex;
            align-items: center;
            gap: 0.5em;
        }

        /* Singolo ordine */
        .order-card {
            background: #1e1e3c;
            border: 1px solid #2a2a4a;
            border-radius: 16px;
            margin-bottom: 1.5em;
            overflow: hidden;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .order-card:hover {
            border-color: rgba(123, 104, 238, 0.4);
            box-shadow: 0 4px 20px rgba(123, 104, 238, 0.08);
        }

        /* Header dell'ordine */
        .order-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 0.75em;
            padding: 1.2em 1.5em;
            background: rgba(123, 104, 238, 0.06);
            border-bottom: 1px solid #2a2a4a;
        }

        .order-id {
            font-size: 1rem;
            font-weight: 700;
            color: #7b68ee;
        }

        .order-date {
            color: #a0a0c0;
            font-size: 0.85rem;
        }

        .order-total {
            font-size: 1.1rem;
            font-weight: 700;
            color: #4ecdc4;
        }

        /* Lista servizi nell'ordine */
        .order-items {
            padding: 1em 1.5em;
            display: flex;
            flex-direction: column;
            gap: 0.85em;
        }

        .order-item {
            display: flex;
            align-items: center;
            gap: 1em;
        }

        .order-item-img {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            object-fit: cover;
            background: #1a1a2e;
            flex-shrink: 0;
        }

        .order-item-img-placeholder {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            background: linear-gradient(135deg, rgba(123, 104, 238, 0.2), rgba(78, 205, 196, 0.15));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            flex-shrink: 0;
        }

        .order-item-info {
            flex: 1;
        }

        .order-item-title {
            font-size: 0.95rem;
            color: #f0f0f0;
            font-weight: 600;
        }

        .order-item-id {
            font-size: 0.8rem;
            color: #606080;
        }

        .order-item-price {
            font-size: 0.95rem;
            font-weight: 700;
            color: #c0c0e0;
            white-space: nowrap;
        }

        /* Stato vuoto */
        .ap-empty {
            text-align: center;
            padding: 4em 2em;
            color: #a0a0c0;
        }
        .ap-empty-icon { font-size: 3.5rem; margin-bottom: 0.5em; }
        .ap-empty h2 { font-size: 1.3rem; color: #c0c0e0; margin-bottom: 0.5em; }
        .ap-empty p  { font-size: 0.95rem; margin-bottom: 1.5em; }

        /* Messaggio di errore */
        .ap-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.3);
            border-radius: 12px;
            padding: 1em 1.5em;
            color: #ef4444;
            margin-bottom: 1.5em;
        }

        @media (max-width: 600px) {
            .ap-hero { flex-direction: column; text-align: center; }
            .order-header { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body class="catalog-page">

    <!-- =============================================
         NAVBAR
         ============================================= -->
    <nav class="navbar" id="mainNavbar">
        <div class="navbar-inner">
            <a href="${pageContext.request.contextPath}/catalogo" class="navbar-brand" id="navBrand">
                <span class="navbar-brand-icon">&#128188;</span>
                <span class="navbar-brand-text">Skill<span>Market</span></span>
            </a>
            <div class="navbar-links">
                <a href="${pageContext.request.contextPath}/catalogo" class="nav-link" id="navCatalogo">&#128218; Catalogo</a>
                <a href="${pageContext.request.contextPath}/carrello" class="nav-link" id="navCarrello">&#128722; Carrello</a>
                <a href="${pageContext.request.contextPath}/area-personale" class="nav-link active" id="navAreaPersonale">&#128100; Area Personale</a>
                <% if (isAdmin || isVenditore) { %>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link" id="navAdmin">&#9881; Admin</a>
                <% } %>
            </div>
            <div class="navbar-user">
                <span class="user-greeting">&#128100; Ciao, <%= utente.getNome() %></span>
                <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-logout" id="navLogout">Esci</a>
            </div>
        </div>
    </nav>

    <!-- =============================================
         CONTENUTO PRINCIPALE
         ============================================= -->
    <main class="ap-layout">

        <!-- Hero di benvenuto -->
        <div class="ap-hero" id="apHero">
            <div class="ap-avatar">&#128100;</div>
            <div class="ap-hero-info">
                <h1><%= utente.getNome() %> <%= utente.getCognome() %></h1>
                <p>&#128231; <%= utente.getEmail() %></p>
                <%
                    String badgeClass = "badge-cliente";
                    String badgeLabel = "Cliente";
                    if ("VENDITORE".equals(utente.getRuolo())) {
                        badgeClass = "badge-venditore"; badgeLabel = "Venditore";
                    } else if ("AMMINISTRATORE".equals(utente.getRuolo())) {
                        badgeClass = "badge-admin"; badgeLabel = "Amministratore";
                    }
                %>
                <span class="ap-badge <%= badgeClass %>"><%= badgeLabel %></span>
            </div>
        </div>

        <!-- Messaggio di errore, se presente -->
        <% if (errore != null) { %>
            <div class="ap-error" id="apError">&#9888; <%= errore %></div>
        <% } %>

        <!-- Sezione storico ordini -->
        <div class="ap-section-title">
            &#128196; I miei ordini
        </div>

        <% if (ordiniConDettagli == null || ordiniConDettagli.isEmpty()) { %>

            <!-- Stato vuoto -->
            <div class="ap-empty" id="apEmpty">
                <div class="ap-empty-icon">&#128722;</div>
                <h2>Nessun ordine ancora</h2>
                <p>Non hai ancora effettuato nessun acquisto su SkillMarket.<br>Esplora il catalogo e trova il servizio che fa per te!</p>
                <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-detail-primary" id="btnGoToCatalog">
                    &#128218; Vai al catalogo
                </a>
            </div>

        <% } else {
            int orderIndex = 0;
            for (Map.Entry<OrdineBean, List<DettaglioOrdineBean>> entry : ordiniConDettagli.entrySet()) {
                OrdineBean ordine = entry.getKey();
                List<DettaglioOrdineBean> dettagli = entry.getValue();
                String dataFormattata = (ordine.getDataOrdine() != null) ? sdf.format(ordine.getDataOrdine()) : "N/D";
                orderIndex++;
        %>

            <div class="order-card" id="orderCard<%= orderIndex %>">
                <!-- Header ordine -->
                <div class="order-header">
                    <span class="order-id" id="orderId<%= orderIndex %>">&#128196; Ordine #<%= ordine.getIdOrdine() %></span>
                    <span class="order-date" id="orderDate<%= orderIndex %>">&#128197; <%= dataFormattata %></span>
                    <span class="order-total" id="orderTotal<%= orderIndex %>">&#8364; <%= String.format("%.2f", ordine.getTotaleOrdine()) %></span>
                </div>

                <!-- Lista servizi acquistati -->
                <div class="order-items" id="orderItems<%= orderIndex %>">
                    <% if (dettagli == null || dettagli.isEmpty()) { %>
                        <p style="color: #606080; font-size: 0.85rem;">Nessun dettaglio disponibile per questo ordine.</p>
                    <% } else {
                        for (DettaglioOrdineBean dettaglio : dettagli) {
                            ServizioBean srv = dettaglio.getServizio();
                            String titoloServizio = (srv != null) ? srv.getTitolo() : "Servizio #" + dettaglio.getIdServizio();
                            String imgPath = (srv != null && srv.getImmaginePath() != null) ? srv.getImmaginePath() : null;
                    %>
                        <div class="order-item">
                            <% if (imgPath != null) { %>
                                <img
                                    src="${pageContext.request.contextPath}/images/<%= imgPath %>"
                                    alt="<%= titoloServizio %>"
                                    class="order-item-img"
                                    onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                                >
                                <div class="order-item-img-placeholder" style="display:none;">&#128188;</div>
                            <% } else { %>
                                <div class="order-item-img-placeholder">&#128188;</div>
                            <% } %>
                            <div class="order-item-info">
                                <div class="order-item-title"><%= titoloServizio %></div>
                                <div class="order-item-id">ID Servizio: <%= dettaglio.getIdServizio() %> &middot; Qtà: <%= dettaglio.getQuantita() %></div>
                            </div>
                            <div class="order-item-price">&#8364; <%= String.format("%.2f", dettaglio.getPrezzoAcquisto()) %></div>
                        </div>
                    <%  }
                    } %>
                </div>
            </div>

        <% } } %>

    </main>

    <!-- Footer -->
    <footer class="site-footer" id="siteFooter">
        <p>&copy; 2026 SkillMarket — Progetto TSW, Università degli Studi di Salerno</p>
    </footer>

</body>
</html>
