<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.skillmarket.model.ServizioBean" %>
<%@ page import="it.unisa.skillmarket.model.CategoriaBean" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Esplora il catalogo di servizi digitali freelance su SkillMarket. Trova il professionista perfetto per il tuo progetto.">
    <title>Catalogo — SkillMarket</title>

    <!-- CSS esterno (specifica: separare CSS dal JSP, cartella styles/) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
</head>
<body class="catalog-page">

    <%
        // Recupero attributi impostati dalla CatalogoServlet
        List<ServizioBean> servizi = (List<ServizioBean>) request.getAttribute("servizi");
        List<CategoriaBean> categorie = (List<CategoriaBean>) request.getAttribute("categorie");
        Integer categoriaSelezionata = (Integer) request.getAttribute("categoriaSelezionata");
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
                <a href="${pageContext.request.contextPath}/catalogo" class="nav-link active" id="navCatalogo">
                    &#128218; Catalogo
                </a>
                <a href="${pageContext.request.contextPath}/carrello" class="nav-link" id="navCarrello">
                    &#128722; Carrello
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
         CONTENUTO PRINCIPALE
         ============================================ -->
    <main class="catalog-layout">

        <!-- Sidebar Filtro Categorie -->
        <aside class="catalog-sidebar" id="categorySidebar">
            <h2>&#128193; Categorie</h2>

            <ul class="category-list" id="categoryList">
                <!-- Opzione "Tutte" -->
                <li>
                    <a href="${pageContext.request.contextPath}/catalogo"
                       class="category-item<%= (categoriaSelezionata == null) ? " active" : "" %>"
                       id="catAll">
                        Tutte le categorie
                    </a>
                </li>

                <% if (categorie != null) {
                    for (CategoriaBean cat : categorie) { %>
                        <li>
                            <a href="${pageContext.request.contextPath}/catalogo?categoria=<%= cat.getIdCategoria() %>"
                               class="category-item<%= (categoriaSelezionata != null && categoriaSelezionata == cat.getIdCategoria()) ? " active" : "" %>"
                               id="cat_<%= cat.getIdCategoria() %>"
                               title="<%= cat.getDescrizione() != null ? cat.getDescrizione() : cat.getNome() %>">
                                <%= cat.getNome() %>
                            </a>
                        </li>
                <%  }
                } %>
            </ul>
        </aside>

        <!-- Griglia Servizi -->
        <section class="catalog-content" id="catalogContent">

            <!-- Header catalogo -->
            <div class="catalog-header">
                <h1>Esplora i servizi</h1>
                <p class="catalog-subtitle">
                    <% if (servizi != null) { %>
                        <strong><%= servizi.size() %></strong> serviz<%= servizi.size() == 1 ? "io" : "i" %> disponibil<%= servizi.size() == 1 ? "e" : "i" %>
                    <% } else { %>
                        Caricamento in corso&hellip;
                    <% } %>
                </p>
            </div>

            <!-- Messaggio di errore -->
            <% if (errore != null) { %>
                <div class="alert alert-error">
                    &#9888;&#65039; <%= errore %>
                </div>
            <% } %>

            <!-- Griglia Card Servizi -->
            <% if (servizi != null && !servizi.isEmpty()) { %>
                <div class="services-grid" id="servicesGrid">
                    <% for (ServizioBean s : servizi) { %>
                        <a href="${pageContext.request.contextPath}/servizio?id=<%= s.getIdServizio() %>" class="service-card" id="service_<%= s.getIdServizio() %>">

                            <!-- Immagine -->
                            <div class="service-card-img">
                                <img src="${pageContext.request.contextPath}/images/<%= s.getImmaginePath() != null ? s.getImmaginePath() : "default_service.png" %>"
                                     alt="<%= s.getTitolo() %>"
                                     loading="lazy">
                            </div>

                            <!-- Contenuto -->
                            <div class="service-card-body">
                                <h3 class="service-card-title"><%= s.getTitolo() %></h3>
                                <p class="service-card-desc">
                                    <%
                                        String desc = s.getDescrizione();
                                        if (desc != null && desc.length() > 100) {
                                            desc = desc.substring(0, 100) + "…";
                                        }
                                    %>
                                    <%= desc != null ? desc : "" %>
                                </p>
                            </div>

                            <!-- Footer: prezzo e azione -->
                            <div class="service-card-footer">
                                <span class="service-price">
                                    &euro; <%= s.getPrezzoCorrente() %>
                                </span>
                                <span class="btn btn-card" id="btnDetail_<%= s.getIdServizio() %>">
                                    Dettagli
                                </span>
                            </div>

                        </a>
                    <% } %>
                </div>

            <% } else if (errore == null) { %>
                <!-- Stato vuoto -->
                <div class="empty-state" id="emptyState">
                    <div class="empty-state-icon">&#128269;</div>
                    <h2>Nessun servizio trovato</h2>
                    <p>Non ci sono servizi disponibili per questa categoria.<br>Prova a selezionare un'altra categoria.</p>
                    <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-primary" id="btnResetFilter">
                        Mostra tutti i servizi
                    </a>
                </div>
            <% } %>

        </section>

    </main>

    <!-- Footer -->
    <footer class="site-footer" id="siteFooter">
        <p>&copy; 2026 SkillMarket — Progetto TSW, Università degli Studi di Salerno</p>
    </footer>

</body>
</html>
