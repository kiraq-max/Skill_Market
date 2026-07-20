<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.skillmarket.model.ServizioBean" %>
<%@ page import="it.unisa.skillmarket.model.CategoriaBean" %>
<%@ page import="it.unisa.skillmarket.model.UtenteBean" %>
<%
    UtenteBean utente = (UtenteBean) session.getAttribute("utente");
    if (utente == null || (!"AMMINISTRATORE".equals(utente.getRuolo()) && !"VENDITORE".equals(utente.getRuolo()))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<ServizioBean> servizi = (List<ServizioBean>) request.getAttribute("servizi");
    List<CategoriaBean> categorie = (List<CategoriaBean>) request.getAttribute("categorie");
    String errore = request.getParameter("errore");
    String successo = request.getParameter("successo");
%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pannello Amministrazione - SkillMarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
    <style>
        .admin-table { width: 100%; border-collapse: collapse; margin-top: 2em; background: #1e1e3c; border-radius: 12px; overflow: hidden; }
        .admin-table th, .admin-table td { padding: 1em; text-align: left; border-bottom: 1px solid #2a2a4a; }
        .admin-table th { background: #222244; color: #a0a0c0; font-weight: 600; }
        .admin-table td { color: #e0e0e0; }
        .admin-table tr:last-child td { border-bottom: none; }
        .btn-sm { padding: 0.5em 1em; font-size: 0.85em; }
        .action-cell { display: flex; gap: 0.5em; }
        .btn-danger { background-color: #7f1d1d; color: #fca5a5; border: 1px solid #991b1b; }
        .btn-danger:hover { background-color: #991b1b; }
    </style>
</head>
<body class="catalog-page">

    <nav class="navbar" id="mainNavbar">
        <div class="navbar-inner">
            <a href="${pageContext.request.contextPath}/catalogo" class="navbar-brand">
                <span class="navbar-brand-icon">&#128188;</span>
                <span class="navbar-brand-text">Skill<span>Market</span></span>
            </a>
            <div class="navbar-links">
                <a href="${pageContext.request.contextPath}/catalogo" class="nav-link">&#128218; Catalogo</a>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link active">&#128230; Servizi</a>
                <a href="${pageContext.request.contextPath}/admin/ordini" class="nav-link">&#128196; Ordini</a>
            </div>
            <div class="navbar-user">
                <span class="user-greeting">&#128100; Ciao, <%= utente.getNome() %></span>
                <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-logout">Esci</a>
            </div>
        </div>
    </nav>

    <main class="catalog-layout" style="display: block;">
        
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2em;">
            <h1 style="color: white; font-size: 1.8em;">Gestione Servizi</h1>
            <a href="${pageContext.request.contextPath}/admin/gestione?action=add" class="btn btn-detail-primary" style="width: auto;">&#10133; Aggiungi Servizio</a>
        </div>

        <% if (errore != null) { %>
            <div class="error-message" style="margin-bottom: 1em;"><%= errore %></div>
        <% } %>
        <% if (successo != null) { %>
            <div class="success-message" style="color: #86efac; background: #064e3b; padding: 1em; border-radius: 8px; margin-bottom: 1em; border: 1px solid #065f46;"><%= successo %></div>
        <% } %>

        <% if (servizi != null && !servizi.isEmpty()) { %>
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Immagine</th>
                        <th>Titolo</th>
                        <th>Prezzo</th>
                        <th>Azioni</th>
                    </tr>
                </thead>
                <tbody>
                    <% for(ServizioBean s : servizi) { %>
                    <tr>
                        <td>#<%= s.getIdServizio() %></td>
                        <td>
                            <img src="${pageContext.request.contextPath}/images/<%= s.getImmaginePath() != null ? s.getImmaginePath() : "default_service.png" %>" 
                                 style="width: 50px; height: 50px; border-radius: 8px; object-fit: cover;">
                        </td>
                        <td style="font-weight: 600;"><%= s.getTitolo() %></td>
                        <td style="color: #ad8bff; font-weight: 700;">&euro; <%= s.getPrezzoCorrente() %></td>
                        <td class="action-cell">
                            <a href="${pageContext.request.contextPath}/admin/gestione?action=edit&id=<%= s.getIdServizio() %>" class="btn btn-detail-secondary btn-sm">Modifica</a>
                            <form action="${pageContext.request.contextPath}/admin/gestione" method="post" style="margin: 0;" onsubmit="return confirm('Sei sicuro di voler eliminare questo servizio?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= s.getIdServizio() %>">
                                <button type="submit" class="btn btn-detail-primary btn-sm btn-danger">Elimina</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p style="color: #8888aa;">Nessun servizio presente nel catalogo.</p>
        <% } %>
    </main>

    <footer class="site-footer">
        &copy; 2026 SkillMarket - Progetto Universitario TSW
    </footer>
</body>
</html>
