<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Accedi a SkillMarket — il marketplace di servizi digitali freelance.">
    <title>Login — SkillMarket</title>

    <!-- CSS esterno (specifica: separare CSS dal JSP, cartella styles/) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/style.css">
</head>
<body class="auth-page">

    <div class="auth-container">
        <div class="auth-card">

            <!-- Branding -->
            <div class="brand">
                <div class="brand-icon">&#128188;</div>
                <h1>Skill<span>Market</span></h1>
                <p>Accedi al tuo account</p>
            </div>

            <!-- Messaggio di errore dal server -->
            <% if (request.getAttribute("errore") != null) { %>
                <div class="alert alert-error">
                    &#9888;&#65039; ${errore}
                </div>
            <% } %>

            <!-- Messaggio di successo (post-registrazione) -->
            <% if (request.getAttribute("successo") != null) { %>
                <div class="alert alert-success">
                    &#9989; ${successo}
                </div>
            <% } %>

            <!-- Form di Login -->
            <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm" novalidate>

                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email"
                           placeholder="nome@esempio.com"
                           autocomplete="email">
                    <span class="field-error" id="email-error"></span>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password"
                           placeholder="La tua password"
                           autocomplete="current-password">
                    <span class="field-error" id="password-error"></span>
                </div>

                <button type="submit" class="btn btn-primary" id="btnLogin">
                    Accedi
                </button>
            </form>

            <!-- Link registrazione -->
            <div class="card-footer">
                <p>Non hai un account?
                    <a href="${pageContext.request.contextPath}/registrazione">Registrati</a>
                </p>
            </div>

        </div>
    </div>

    <!-- JS esterno (specifica: separare JS dal JSP, cartella scripts/) -->
    <script src="${pageContext.request.contextPath}/scripts/login.js"></script>

</body>
</html>
