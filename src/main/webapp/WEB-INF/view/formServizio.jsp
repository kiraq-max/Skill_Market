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
    
    ServizioBean servizio = (ServizioBean) request.getAttribute("servizio");
    List<CategoriaBean> categorie = (List<CategoriaBean>) request.getAttribute("categorie");
    boolean isEdit = (servizio != null);
%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Modifica Servizio" : "Nuovo Servizio" %> - SkillMarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
    <style>
        .form-container { max-width: 600px; margin: 0 auto; background: #1e1e3c; padding: 2em; border-radius: 16px; border: 1px solid #2a2a4a; }
        .form-title { font-size: 1.5em; color: white; margin-bottom: 1.5em; text-align: center; }
        .form-group { margin-bottom: 1.5em; display: flex; flex-direction: column; gap: 0.5em; }
        .form-group label { color: #a0a0c0; font-weight: 600; font-size: 0.9em; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 0.85em 1em; background: #1a1a2e; border: 1px solid #333355;
            border-radius: 12px; color: #f0f0f0; font-size: 0.95em; font-family: inherit;
        }
        .form-group textarea { resize: vertical; min-height: 120px; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #7b68ee; outline: none; background: rgba(123, 104, 238, 0.06);
        }
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
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link active">&#9881; Admin</a>
            </div>
            <div class="navbar-user">
                <span class="user-greeting">&#128100; Ciao, <%= utente.getNome() %></span>
                <a href="${pageContext.request.contextPath}/logout" class="nav-link nav-logout">Esci</a>
            </div>
        </div>
    </nav>

    <main class="catalog-layout" style="display: block;">
        
        <div class="form-container">
            <h1 class="form-title"><%= isEdit ? "Modifica Servizio #" + servizio.getIdServizio() : "Aggiungi Nuovo Servizio" %></h1>
            
            <form action="${pageContext.request.contextPath}/admin/gestione" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                <% if(isEdit) { %>
                    <input type="hidden" name="id" value="<%= servizio.getIdServizio() %>">
                <% } %>

                <div class="form-group">
                    <label for="titolo">Titolo del Servizio</label>
                    <input type="text" id="titolo" name="titolo" value="<%= isEdit ? servizio.getTitolo() : "" %>" required>
                </div>

                <div class="form-group">
                    <label for="prezzo">Prezzo (&euro;)</label>
                    <input type="number" id="prezzo" name="prezzo" step="0.01" min="1" value="<%= isEdit ? servizio.getPrezzoCorrente() : "" %>" required>
                </div>

                <div class="form-group">
                    <label for="categoria">Categoria</label>
                    <select id="categoria" name="categoria" required>
                        <option value="">-- Seleziona una categoria --</option>
                        <% if(categorie != null) {
                            for(CategoriaBean cat : categorie) { 
                                boolean isSelected = (isEdit && servizio.getIdCategoria() == cat.getIdCategoria());
                        %>
                            <option value="<%= cat.getIdCategoria() %>" <%= isSelected ? "selected" : "" %>><%= cat.getNome() %></option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="immagine">Immagine (Nome File Es. 'design.jpg')</label>
                    <input type="text" id="immagine" name="immagine" value="<%= isEdit && servizio.getImmaginePath() != null ? servizio.getImmaginePath() : "" %>" placeholder="Lascia vuoto per immagine default">
                </div>

                <div class="form-group">
                    <label for="descrizione">Descrizione</label>
                    <textarea id="descrizione" name="descrizione" required><%= isEdit ? servizio.getDescrizione() : "" %></textarea>
                </div>

                <div style="display: flex; gap: 1em; margin-top: 2em;">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-detail-outline" style="flex: 1; text-align: center;">Annulla</a>
                    <button type="submit" class="btn btn-detail-primary" style="flex: 1;"><%= isEdit ? "Salva Modifiche" : "Crea Servizio" %></button>
                </div>
            </form>
        </div>

    </main>

    <footer class="site-footer">
        &copy; 2026 SkillMarket - Progetto Universitario TSW
    </footer>
</body>
</html>
