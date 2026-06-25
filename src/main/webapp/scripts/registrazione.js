/**
 * SkillMarket — Validazione form di Registrazione
 *
 * Requisiti rispettati (da specifica TSW):
 * - Validazione con espressioni regolari
 * - Messaggi di errore visualizzati nel DOM (NO alert!)
 * - Errori mostrati sia su evento "change" che su "submit"
 * - I dati vengono inviati al server solo se la validazione è positiva
 */

document.addEventListener('DOMContentLoaded', function () {

    const form = document.getElementById('registrazioneForm');
    const nomeInput = document.getElementById('nome');
    const cognomeInput = document.getElementById('cognome');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const confermaPasswordInput = document.getElementById('confermaPassword');

    // Regex per validazione
    const EMAIL_REGEX = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;
    const NOME_REGEX = /^[A-Za-zÀ-ÖØ-öø-ÿ'\- ]{2,50}$/;
    const PASSWORD_MIN_LENGTH = 8;

    // -------------------------------------------------------
    // TOGGLE MOSTRA/NASCONDI PASSWORD
    // -------------------------------------------------------

    /**
     * Inizializza un bottone toggle per mostrare/nascondere la password.
     * Alterna il type dell'input tra "password" e "text" e aggiorna l'icona.
     */
    function setupPasswordToggle(toggleBtnId, inputId) {
        const btn = document.getElementById(toggleBtnId);
        const input = document.getElementById(inputId);
        if (!btn || !input) return;

        btn.addEventListener('click', function () {
            const isHidden = input.type === 'password';
            input.type = isHidden ? 'text' : 'password';
            // 👁 occhio aperto = password visibile, 👁‍🗨 occhio con bolla = password nascosta
            btn.textContent = isHidden ? '\u{1F441}\u{200D}\u{1F5E8}' : '\u{1F441}';
            btn.setAttribute('aria-label', isHidden ? 'Nascondi password' : 'Mostra password');
            btn.setAttribute('title', isHidden ? 'Nascondi password' : 'Mostra password');
        });
    }

    setupPasswordToggle('togglePassword', 'password');
    setupPasswordToggle('toggleConfermaPassword', 'confermaPassword');

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
     * Valida il campo nome.
     * @returns {boolean} true se il campo è valido.
     */
    function validateNome() {
        const value = nomeInput.value.trim();

        if (value === '') {
            showError(nomeInput, 'Il campo nome è obbligatorio.');
            return false;
        }

        if (!NOME_REGEX.test(value)) {
            showError(nomeInput, 'Il nome può contenere solo lettere, spazi, apostrofi e trattini (2-50 caratteri).');
            return false;
        }

        markValid(nomeInput);
        return true;
    }

    /**
     * Valida il campo cognome.
     * @returns {boolean} true se il campo è valido.
     */
    function validateCognome() {
        const value = cognomeInput.value.trim();

        if (value === '') {
            showError(cognomeInput, 'Il campo cognome è obbligatorio.');
            return false;
        }

        if (!NOME_REGEX.test(value)) {
            showError(cognomeInput, 'Il cognome può contenere solo lettere, spazi, apostrofi e trattini (2-50 caratteri).');
            return false;
        }

        markValid(cognomeInput);
        return true;
    }

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

        if (value.length < PASSWORD_MIN_LENGTH) {
            showError(passwordInput, 'La password deve essere di almeno ' + PASSWORD_MIN_LENGTH + ' caratteri.');
            return false;
        }

        markValid(passwordInput);

        // Se l'utente ha già inserito la conferma, rivalidala
        if (confermaPasswordInput.value !== '') {
            validateConfermaPassword();
        }

        return true;
    }

    /**
     * Valida il campo conferma password.
     * @returns {boolean} true se il campo è valido.
     */
    function validateConfermaPassword() {
        const value = confermaPasswordInput.value;

        if (value === '') {
            showError(confermaPasswordInput, 'Conferma la tua password.');
            return false;
        }

        if (value !== passwordInput.value) {
            showError(confermaPasswordInput, 'Le password non corrispondono.');
            return false;
        }

        markValid(confermaPasswordInput);
        return true;
    }

    // -------------------------------------------------------
    // EVENT LISTENERS — Validazione su "change" di ogni campo
    // -------------------------------------------------------

    nomeInput.addEventListener('change', validateNome);
    nomeInput.addEventListener('input', function () {
        if (nomeInput.classList.contains('input-error')) {
            clearError(nomeInput);
        }
    });

    cognomeInput.addEventListener('change', validateCognome);
    cognomeInput.addEventListener('input', function () {
        if (cognomeInput.classList.contains('input-error')) {
            clearError(cognomeInput);
        }
    });

    emailInput.addEventListener('change', validateEmail);
    emailInput.addEventListener('input', function () {
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

    confermaPasswordInput.addEventListener('change', validateConfermaPassword);
    confermaPasswordInput.addEventListener('input', function () {
        if (confermaPasswordInput.classList.contains('input-error')) {
            clearError(confermaPasswordInput);
        }
    });

    // -------------------------------------------------------
    // EVENT LISTENER — Validazione su "submit" del form
    // -------------------------------------------------------

    form.addEventListener('submit', function (e) {
        const isNomeValid = validateNome();
        const isCognomeValid = validateCognome();
        const isEmailValid = validateEmail();
        const isPasswordValid = validatePassword();
        const isConfermaValid = validateConfermaPassword();

        // Blocco l'invio del form se almeno un campo non è valido
        if (!isNomeValid || !isCognomeValid || !isEmailValid || !isPasswordValid || !isConfermaValid) {
            e.preventDefault();

            // Focus sul primo campo con errore
            const firstInvalid = form.querySelector('.input-error');
            if (firstInvalid) {
                firstInvalid.focus();
            }
        }
    });
});
