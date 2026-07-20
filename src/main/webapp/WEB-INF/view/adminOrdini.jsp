<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.text.SimpleDateFormat" %>
<%@ page import="it.unisa.skillmarket.model.OrdineBean" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<%
    UtenteBean admin = (UtenteBean) session.getAttribute("utente");
    if (admin == null || (!"AMMINISTRATORE".equals(admin.getRuolo()) && !"VENDITORE".equals(admin.getRuolo()))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    Map<OrdineBean, UtenteBean> ordiniConClienti =
        (Map<OrdineBean, UtenteBean>) request.getAttribute("ordiniConClienti");

    String errore        = (String) request.getAttribute("errore");
    Integer totaleOrdini = (Integer) request.getAttribute("totaleOrdini");
    String filtroEmail   = (String) request.getAttribute("filtroEmail");
    String filtroDataI   = (String) request.getAttribute("filtroDataInizio");
    String filtroDataF   = (String) request.getAttribute("filtroDataFine");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestione Ordini — SkillMarket Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
    <style>
        /* =============================================
           ADMIN ORDINI — Stili specifici
           ============================================= */

        .admin-ordini-layout {
            max-width: 1100px;
            margin: 0 auto;
            padding: 2em 1.5em 4em;
        }

        /* Header pagina */
        .admin-page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1em;
            margin-bottom: 2em;
        }

        .admin-page-header h1 {
            color: #ffffff;
            font-size: 1.8em;
        }

        .admin-badge-count {
            background: rgba(123, 104, 238, 0.15);
            border: 1px solid rgba(123, 104, 238, 0.3);
            color: #ad8bff;
            padding: 0.4em 1em;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
        }

        /* Card filtri */
        .filter-card {
            background: #1e1e3c;
            border: 1px solid #2a2a4a;
            border-radius: 16px;
            padding: 1.5em 2em;
            margin-bottom: 2em;
        }

        .filter-card h2 {
            font-size: 0.9em;
            color: #a0a0c0;
            font-weight: 600;
            margin-bottom: 1em;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .filter-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 1em;
            align-items: end;
        }

        .filter-group label {
            display: block;
            font-size: 0.78em;
            color: #8888aa;
            font-weight: 600;
            margin-bottom: 0.4em;
        }

        .filter-group input {
            width: 100%;
            padding: 0.7em 1em;
            background: #1a1a2e;
            border: 1px solid #333355;
            border-radius: 10px;
            color: #f0f0f0;
            font-size: 0.9em;
        }

        .filter-group input:focus {
            border-color: #7b68ee;
            outline: none;
        }

        .filter-divider {
            text-align: center;
            color: #555577;
            font-size: 0.85em;
            padding: 2em 0 0.5em;
            border-top: 1px solid #2a2a4a;
            margin-top: 1em;
        }

        .filter-grid-email {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 1em;
            align-items: end;
            margin-top: 1em;
        }

        .btn-filter {
            padding: 0.7em 1.5em;
            background: #7b68ee;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 0.9em;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            white-space: nowrap;
        }

        .btn-filter:hover { background: #6b58de; }

        .btn-reset {
            padding: 0.7em 1.2em;
            background: transparent;
            color: #8888aa;
            border: 1px solid #333355;
            border-radius: 10px;
            font-size: 0.85em;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-reset:hover { color: #ffffff; border-color: #555577; text-decoration: none; }

        /* Tabella ordini */
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            background: #1e1e3c;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid #2a2a4a;
        }

        .orders-table th {
            padding: 1em 1.2em;
            text-align: left;
            background: #222244;
            color: #a0a0c0;
            font-weight: 600;
            font-size: 0.8em;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            border-bottom: 1px solid #2a2a4a;
        }

        .orders-table td {
            padding: 1em 1.2em;
            color: #e0e0e0;
            font-size: 0.9em;
            border-bottom: 1px solid #1a1a38;
            vertical-align: middle;
        }

        .orders-table tr:last-child td { border-bottom: none; }

        .orders-table tbody tr:hover {
            background: rgba(123, 104, 238, 0.05);
        }

        .order-id-cell {
            font-weight: 700;
            color: #7b68ee;
        }

        .order-total-cell {
            font-weight: 700;
            color: #4ecdc4;
        }

        .order-client-cell {
            display: flex;
            flex-direction: column;
            gap: 0.2em;
        }

        .order-client-name { font-weight: 600; color: #f0f0f0; }
        .order-client-email { font-size: 0.78em; color: #606080; }

        /* Filtro attivo */
        .filter-active-banner {
            background: rgba(123, 104, 238, 0.1);
            border: 1px solid rgba(123, 104, 238, 0.25);
            border-radius: 10px;
            padding: 0.75em 1.2em;
            margin-bottom: 1.5em;
            color: #ad8bff;
            font-size: 0.88em;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* Stato vuoto */
        .empty-orders {
            text-align: center;
            padding: 4em 2em;
            color: #8888aa;
        }

        .empty-orders-icon { font-size: 3em; margin-bottom: 0.5em; }

        @media (max-width: 768px) {
            .filter-grid { grid-template-columns: 1fr 1fr; }
            .filter-grid-email { grid-template-columns: 1fr; }
            .orders-table th:nth-child(4),
            .orders-table td:nth-child(4) { display: none; }
        }
    </style>
</head>
<body class="catalog-page">

    <!-- NAVBAR -->
    <nav class="navbar" id="mainNavbar">
        <div class="navbar-inner">
            <a href="${pageContext.request.contextPath}/catalogo" class="navbar-brand" id="navBrand">
                <span class="navbar-brand-icon">&#128188;</span>
                <span class="navbar-brand-text">Skill<span>Market</span></span>
            </a>
            <div class="navbar-links">
                <a href="${pageContext.request.contextPath}/catalogo" class="nav-link" id="navCatalogo">&#128218; Catalogo</a>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link" id="navAdminCatalogo">&#128230; Servizi</a>
                <a href="${pageContext.request.contextPath}/admin/ordini" class="nav-link active" id="navAdminOrdini">&#128196; Ordini</a>
            </div>
            <div class="navbar-user">
                <span class="user-greeting">&#128100; <%= admin.getNome() %></span>
                <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-logout" id="navLogout">Esci</a>
            </div>
        </div>
    </nav>

    <main class="admin-ordini-layout">

        <!-- Header -->
        <div class="admin-page-header">
            <h1>&#128196; Gestione Ordini</h1>
            <% if (totaleOrdini != null) { %>
                <span class="admin-badge-count"><%= totaleOrdini %> ordine<%= totaleOrdini == 1 ? "" : "i" %></span>
            <% } %>
        </div>

        <!-- Messaggio errore -->
        <% if (errore != null) { %>
            <div class="alert alert-error" id="alertErrore">&#9888; <%= errore %></div>
        <% } %>

        <!-- Card Filtri -->
        <div class="filter-card" id="filterCard">
            <h2>&#128270; Filtra ordini</h2>

            <!-- Filtro per data -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/ordini" id="formFiltroData">
                <div class="filter-grid">
                    <div class="filter-group">
                        <label for="dataInizio">Data inizio</label>
                        <input type="date" id="dataInizio" name="dataInizio"
                               value="<%= filtroDataI != null ? filtroDataI : "" %>">
                    </div>
                    <div class="filter-group">
                        <label for="dataFine">Data fine</label>
                        <input type="date" id="dataFine" name="dataFine"
                               value="<%= filtroDataF != null ? filtroDataF : "" %>">
                    </div>
                    <div class="filter-group" style="display:flex; gap:0.5em; align-items:flex-end;">
                        <button type="submit" class="btn-filter" id="btnFiltraData">Filtra</button>
                        <a href="${pageContext.request.contextPath}/admin/ordini" class="btn-reset" id="btnResetData">Reset</a>
                    </div>
                </div>
            </form>

            <!-- Separatore -->
            <div class="filter-divider">oppure filtra per cliente</div>

            <!-- Filtro per email cliente -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/ordini" id="formFiltroEmail">
                <div class="filter-grid-email">
                    <div class="filter-group">
                        <label for="emailCliente">Email cliente</label>
                        <input type="email" id="emailCliente" name="emailCliente"
                               placeholder="es. mario.rossi@email.com"
                               value="<%= filtroEmail != null ? filtroEmail : "" %>">
                    </div>
                    <div style="display:flex; gap:0.5em;">
                        <button type="submit" class="btn-filter" id="btnFiltraEmail">Cerca</button>
                        <a href="${pageContext.request.contextPath}/admin/ordini" class="btn-reset" id="btnResetEmail">Reset</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Banner filtro attivo -->
        <% if (filtroEmail != null) { %>
            <div class="filter-active-banner" id="filtroActiveBanner">
                &#128269; Risultati per cliente: <strong><%= filtroEmail %></strong>
                <a href="${pageContext.request.contextPath}/admin/ordini" class="btn-reset">Rimuovi filtro</a>
            </div>
        <% } else if (filtroDataI != null && filtroDataF != null) { %>
            <div class="filter-active-banner" id="filtroActiveBanner">
                &#128197; Ordini dal <strong><%= filtroDataI %></strong> al <strong><%= filtroDataF %></strong>
                <a href="${pageContext.request.contextPath}/admin/ordini" class="btn-reset">Rimuovi filtro</a>
            </div>
        <% } %>

        <!-- Tabella ordini -->
        <% if (ordiniConClienti == null || ordiniConClienti.isEmpty()) { %>
            <div class="empty-orders" id="emptyOrders">
                <div class="empty-orders-icon">&#128196;</div>
                <p><% if (filtroEmail != null || filtroDataI != null) { %>
                    Nessun ordine trovato con i filtri selezionati.
                <% } else { %>
                    Non ci sono ancora ordini sulla piattaforma.
                <% } %></p>
            </div>
        <% } else { %>
            <table class="orders-table" id="ordersTable">
                <thead>
                    <tr>
                        <th>ID Ordine</th>
                        <th>Cliente</th>
                        <th>Data</th>
                        <th>Indirizzo</th>
                        <th>Totale</th>
                    </tr>
                </thead>
                <tbody>
                    <% int rowIdx = 0;
                       for (Map.Entry<OrdineBean, UtenteBean> entry : ordiniConClienti.entrySet()) {
                           OrdineBean ordine = entry.getKey();
                           UtenteBean cliente = entry.getValue();
                           String dataFormattata = (ordine.getDataOrdine() != null) ? sdf.format(ordine.getDataOrdine()) : "N/D";
                           rowIdx++;
                    %>
                    <tr id="orderRow<%= rowIdx %>">
                        <td class="order-id-cell">#<%= ordine.getIdOrdine() %></td>
                        <td>
                            <div class="order-client-cell">
                                <% if (cliente != null) { %>
                                    <span class="order-client-name"><%= cliente.getNome() %> <%= cliente.getCognome() %></span>
                                    <span class="order-client-email"><%= cliente.getEmail() %></span>
                                <% } else { %>
                                    <span class="order-client-email">Cliente #<%= ordine.getIdCliente() %></span>
                                <% } %>
                            </div>
                        </td>
                        <td><%= dataFormattata %></td>
                        <td style="color:#8888aa; font-size:0.85em;"><%= ordine.getIndirizzoSpedizione() %></td>
                        <td class="order-total-cell">&#8364; <%= String.format("%.2f", ordine.getTotaleOrdine()) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>

    </main>

    <footer class="site-footer" id="siteFooter">
        <p>&copy; 2026 SkillMarket — Progetto TSW, Università degli Studi di Salerno</p>
    </footer>

</body>
</html>
