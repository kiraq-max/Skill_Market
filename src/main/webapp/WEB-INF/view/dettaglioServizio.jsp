<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="it.unisa.skillmarket.model.ServizioBean" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%
        // Recupero attributo impostato dalla DettaglioServizioServlet
        ServizioBean servizio = (ServizioBean) request.getAttribute("servizio");

        // Utente loggato (dalla sessione)
        UtenteBean utente = (UtenteBean) session.getAttribute("utente");

        // Carrello (per verificare se il servizio è già nel carrello)
        @SuppressWarnings("unchecked")
        List<ServizioBean> carrello = (List<ServizioBean>) session.getAttribute("carrello");
        boolean nelCarrello = false;
        if (carrello != null && servizio != null) {
            for (ServizioBean s : carrello) {
                if (s.getIdServizio() == servizio.getIdServizio()) {
                    nelCarrello = true;
                    break;
                }
            }
        }
    %>
    <meta name="description" content="<%= servizio != null ? servizio.getTitolo() + " — Scopri tutti i dettagli di questo servizio su SkillMarket" : "Dettaglio servizio — SkillMarket" %>">
    <title><%= servizio != null ? servizio.getTitolo() : "Servizio" %> — SkillMarket</title>

    <!-- CSS esterno (specifica: separare CSS dal JSP, cartella styles/) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
</head>
<body class="detail-page">

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
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-nav" id="navLogin">
                        Accedi
                    </a>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- ============================================
         CONTENUTO PRINCIPALE — DETTAGLIO SERVIZIO
         ============================================ -->
    <main class="detail-layout">

        <% if (servizio != null) { %>

            <!-- Breadcrumb di navigazione -->
            <nav class="detail-breadcrumb" id="breadcrumb" aria-label="Percorso di navigazione">
                <a href="${pageContext.request.contextPath}/catalogo">&#128218; Catalogo</a>
                <span class="breadcrumb-separator">&#10095;</span>
                <span class="breadcrumb-current"><%= servizio.getTitolo() %></span>
            </nav>

            <div class="detail-grid">

                <!-- Colonna Immagine -->
                <div class="detail-image-col" id="detailImageCol">
                    <div class="detail-image-wrapper">
                        <img src="${pageContext.request.contextPath}/images/<%= servizio.getImmaginePath() != null ? servizio.getImmaginePath() : "default_service.png" %>"
                             alt="<%= servizio.getTitolo() %>"
                             id="detailImage">
                    </div>
                </div>

                <!-- Colonna Informazioni -->
                <div class="detail-info-col" id="detailInfoCol">

                    <!-- Badge Categoria -->
                    <span class="detail-badge" id="detailBadge">
                        &#128193; Categoria #<%= servizio.getIdCategoria() %>
                    </span>

                    <!-- Titolo -->
                    <h1 class="detail-title" id="detailTitle"><%= servizio.getTitolo() %></h1>

                    <!-- Prezzo -->
                    <div class="detail-price" id="detailPrice">
                        &euro; <%= servizio.getPrezzoCorrente() %>
                    </div>

                    <!-- Descrizione completa -->
                    <div class="detail-description" id="detailDescription">
                        <h2>Descrizione</h2>
                        <p><%= servizio.getDescrizione() != null ? servizio.getDescrizione() : "Nessuna descrizione disponibile per questo servizio." %></p>
                    </div>

                    <!-- Info venditore -->
                    <div class="detail-meta" id="detailMeta">
                        <div class="detail-meta-item">
                            <span class="detail-meta-icon">&#128100;</span>
                            <span>Venditore #<%= servizio.getIdVenditore() %></span>
                        </div>
                        <div class="detail-meta-item">
                            <span class="detail-meta-icon">&#128196;</span>
                            <span>ID Servizio: <%= servizio.getIdServizio() %></span>
                        </div>
                    </div>

                    <!-- Azioni -->
                    <div class="detail-actions" id="detailActions">
                        <% if (nelCarrello) { %>
                            <!-- Già nel carrello -->
                            <a href="${pageContext.request.contextPath}/carrello" class="btn btn-detail-secondary" id="btnGoToCart">
                                &#10004; Già nel carrello — Visualizza
                            </a>
                        <% } else { %>
                            <!-- Aggiungi al carrello -->
                            <form action="${pageContext.request.contextPath}/carrello" method="post" id="formAddToCart">
                                <input type="hidden" name="action" value="aggiungi">
                                <input type="hidden" name="id" value="<%= servizio.getIdServizio() %>">
                                <button type="submit" class="btn btn-detail-primary" id="btnAddToCart">
                                    &#128722; Aggiungi al carrello
                                </button>
                            </form>
                        <% } %>

                        <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-detail-outline" id="btnBackToCatalog">
                            &#8592; Torna al catalogo
                        </a>
                    </div>

                </div>
            </div>

        <% } else { %>
            <!-- Servizio non trovato -->
            <div class="empty-state" id="emptyState">
                <div class="empty-state-icon">&#128533;</div>
                <h2>Servizio non disponibile</h2>
                <p>Il servizio richiesto non è stato trovato o non è più disponibile.</p>
                <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-primary" id="btnBackCatalog">
                    Torna al catalogo
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
