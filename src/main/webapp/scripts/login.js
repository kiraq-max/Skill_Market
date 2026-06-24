/**
 * SkillMarket — Validazione form di Login
 *
 * Requisiti rispettati (da specifica TSW):
 * - Validazione con espressioni regolari
 * - Messaggi di errore visualizzati nel DOM (NO alert!)
 * - Errori mostrati sia su evento "change" che su "submit"
 * - I dati vengono inviati al server solo se la validazione è positiva
 */

document.addEventListener('DOMContentLoaded', function () {

    const form = document.getElementById('loginForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');

    // Regex per validazione email (formato standard)
    const EMAIL_REGEX = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;

    // -------------------------------------------------------
    // UTILITY: Mostra/Nascondi errore su un campo
    // -------------------------------------------------------

    /**
     * Mostra un messaggio di errore sotto il campo specificato.
     * Aggiunge la classe CSS per lo stile di errore.
     */
    function showError(input, message) {
        const errorSpan = document.getElementById(input.id + '-error');
        if (errorSpan) {
            errorSpan.textContent = message;
            errorSpan.classList.add('visible');
        }
        input.classList.add('input-error');
        input.classList.remove('input-valid');
    }

    /**
     * Rimuove il messaggio di errore e ripristina lo stile del campo.
     */
    function clearError(input) {
        const errorSpan = document.getElementById(input.id + '-error');
        if (errorSpan) {
            errorSpan.textContent = '';
            errorSpan.classList.remove('visible');
        }
        input.classList.remove('input-error');
    }

    /**
     * Segna il campo come valido visivamente.
     */
    function markValid(input) {
        clearError(input);
        if (input.value.trim() !== '') {
            input.classList.add('input-valid');
        }
    }

    // -------------------------------------------------------
    // VALIDAZIONE SINGOLI CAMPI
    // -------------------------------------------------------

    /**
     * Valida il campo email.
     * @returns {boolean} true se il campo è valido.
     */
    function validateEmail() {
        const value = emailInput.value.trim();

        if (value === '') {
            showError(emailInput, 'Il campo email è obbligatorio.');
            return false;
        }

        if (!EMAIL_REGEX.test(value)) {
            showError(emailInput, 'Inserisci un indirizzo email valido (es. nome@esempio.com).');
            return false;
        }

        markValid(emailInput);
        return true;
    }

    /**
     * Valida il campo password.
     * @returns {boolean} true se il campo è valido.
     */
    function validatePassword() {
        const value = passwordInput.value;

        if (value === '') {
            showError(passwordInput, 'Il campo password è obbligatorio.');
            return false;
        }

        markValid(passwordInput);
        return true;
    }

    // -------------------------------------------------------
    // EVENT LISTENERS — Validazione su "change" di ogni campo
    // -------------------------------------------------------

    emailInput.addEventListener('change', validateEmail);
    emailInput.addEventListener('input', function () {
        // Rimuovo errore mentre l'utente digita (UX migliore)
        if (emailInput.classList.contains('input-error')) {
            clearError(emailInput);
        }
    });

    passwordInput.addEventListener('change', validatePassword);
    passwordInput.addEventListener('input', function () {
        if (passwordInput.classList.contains('input-error')) {
            clearError(passwordInput);
        }
    });

    // -------------------------------------------------------
    // EVENT LISTENER — Validazione su "submit" del form
    // -------------------------------------------------------

    form.addEventListener('submit', function (e) {
        const isEmailValid = validateEmail();
        const isPasswordValid = validatePassword();

        // Blocco l'invio del form se almeno un campo non è valido
        if (!isEmailValid || !isPasswordValid) {
            e.preventDefault();

            // Focus sul primo campo con errore
            if (!isEmailValid) {
                emailInput.focus();
            } else {
                passwordInput.focus();
            }
        }
    });
});
