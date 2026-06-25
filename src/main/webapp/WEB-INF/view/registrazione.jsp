<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Registrati su SkillMarket — crea il tuo account e inizia a esplorare servizi digitali freelance.">
    <title>Registrati — SkillMarket</title>

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
                <p>Crea il tuo account</p>
            </div>

            <!-- Messaggio di errore dal server -->
            <% if (request.getAttribute("errore") != null) { %>
                <div class="alert alert-error">
                    &#9888;&#65039; ${errore}
                </div>
            <% } %>

            <!-- Form di Registrazione -->
            <form action="${pageContext.request.contextPath}/registrazione" method="POST" id="registrazioneForm" novalidate>

                <div class="form-row">
                    <div class="form-group">
                        <label for="nome">Nome</label>
                        <input type="text" id="nome" name="nome"
                               placeholder="Il tuo nome"
                               autocomplete="given-name">
                        <span class="field-error" id="nome-error"></span>
                    </div>

                    <div class="form-group">
                        <label for="cognome">Cognome</label>
                        <input type="text" id="cognome" name="cognome"
                               placeholder="Il tuo cognome"
                               autocomplete="family-name">
                        <span class="field-error" id="cognome-error"></span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email"
                           placeholder="nome@esempio.com"
                           autocomplete="email">
                    <span class="field-error" id="email-error"></span>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="password-wrapper">
                        <input type="password" id="password" name="password"
                               placeholder="Minimo 8 caratteri"
                               autocomplete="new-password">
                        <button type="button" class="btn-toggle-password" id="togglePassword"
                                aria-label="Mostra password" title="Mostra password">&#128065;</button>
                    </div>
                    <span class="field-error" id="password-error"></span>
                </div>

                <div class="form-group">
                    <label for="confermaPassword">Conferma Password</label>
                    <div class="password-wrapper">
                        <input type="password" id="confermaPassword" name="confermaPassword"
                               placeholder="Ripeti la password"
                               autocomplete="new-password">
                        <button type="button" class="btn-toggle-password" id="toggleConfermaPassword"
                                aria-label="Mostra conferma password" title="Mostra password">&#128065;</button>
                    </div>
                    <span class="field-error" id="confermaPassword-error"></span>
                </div>

                <button type="submit" class="btn btn-primary" id="btnRegistrazione">
                    Crea Account
                </button>
            </form>

            <!-- Link login -->
            <div class="card-footer">
                <p>Hai già un account?
                    <a href="${pageContext.request.contextPath}/login">Accedi</a>
                </p>
            </div>

        </div>
    </div>

    <!-- JS esterno (specifica: separare JS dal JSP, cartella scripts/) -->
    <script src="${pageContext.request.contextPath}/scripts/registrazione.js"></script>

</body>
</html>
