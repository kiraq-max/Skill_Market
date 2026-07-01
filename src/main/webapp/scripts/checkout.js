/**
 * SkillMarket — Validazione form di Checkout
 *
 * Requisiti rispettati (da specifica TSW):
 * - Validazione con espressioni regolari
 * - Messaggi di errore visualizzati nel DOM (NO alert!)
 * - Errori mostrati sia su evento "change" che su "submit"
 * - I dati vengono inviati al server solo se la validazione è positiva
 * - Il campo hidden "datiPagamento" viene compilato prima dell'invio
 */

document.addEventListener('DOMContentLoaded', function () {

    const form = document.getElementById('checkoutForm');
    const indirizzoInput = document.getElementById('indirizzo');
    const titolareCartaInput = document.getElementById('titolareCarta');
    const numeroCartaInput = document.getElementById('numeroCarta');
    const scadenzaInput = document.getElementById('scadenza');
    const cvvInput = document.getElementById('cvv');
    const datiPagamentoHidden = document.getElementById('datiPagamento');

    // Regex per validazione
    const NOME_REGEX = /^[A-Za-zÀ-ÖØ-öø-ÿ'\- ]{2,100}$/;
    const CARTA_REGEX = /^\d{4}\s?\d{4}\s?\d{4}\s?\d{4}$/;
    const SCADENZA_REGEX = /^(0[1-9]|1[0-2])\/\d{2}$/;
    const CVV_REGEX = /^\d{3,4}$/;

    // -------------------------------------------------------
    // FORMATTAZIONE AUTOMATICA NUMERO CARTA
    // -------------------------------------------------------

    if (numeroCartaInput) {
        numeroCartaInput.addEventListener('input', function () {
            // Rimuove tutto ciò che non è un numero
            let value = this.value.replace(/\D/g, '');
            // Limita a 16 cifre
            value = value.substring(0, 16);
            // Aggiunge uno spazio ogni 4 cifre
            let formatted = value.replace(/(\d{4})(?=\d)/g, '$1 ');
            this.value = formatted;
        });
    }

    // -------------------------------------------------------
    // FORMATTAZIONE AUTOMATICA SCADENZA
    // -------------------------------------------------------

    if (scadenzaInput) {
        scadenzaInput.addEventListener('input', function () {
            let value = this.value.replace(/\D/g, '');
            value = value.substring(0, 4);
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2);
            }
            this.value = value;
        });
    }

    // -------------------------------------------------------
    // FORMATTAZIONE AUTOMATICA CVV (solo numeri)
    // -------------------------------------------------------

    if (cvvInput) {
        cvvInput.addEventListener('input', function () {
            this.value = this.value.replace(/\D/g, '').substring(0, 4);
        });
    }

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
     * Valida il campo indirizzo di spedizione.
     */
    function validateIndirizzo() {
        const value = indirizzoInput.value.trim();

        if (value === '') {
            showError(indirizzoInput, 'L\'indirizzo di spedizione è obbligatorio.');
            return false;
        }

        if (value.length < 10) {
            showError(indirizzoInput, 'Inserisci un indirizzo completo (almeno 10 caratteri).');
            return false;
        }

        markValid(indirizzoInput);
        return true;
    }

    /**
     * Valida il titolare della carta.
     */
    function validateTitolareCarta() {
        const value = titolareCartaInput.value.trim();

        if (value === '') {
            showError(titolareCartaInput, 'Il nome del titolare è obbligatorio.');
            return false;
        }

        if (!NOME_REGEX.test(value)) {
            showError(titolareCartaInput, 'Inserisci il nome come appare sulla carta (solo lettere e spazi).');
            return false;
        }

        markValid(titolareCartaInput);
        return true;
    }

    /**
     * Valida il numero della carta di credito.
     */
    function validateNumeroCarta() {
        const value = numeroCartaInput.value.trim();

        if (value === '') {
            showError(numeroCartaInput, 'Il numero della carta è obbligatorio.');
            return false;
        }

        if (!CARTA_REGEX.test(value)) {
            showError(numeroCartaInput, 'Inserisci un numero carta valido a 16 cifre.');
            return false;
        }

        markValid(numeroCartaInput);
        return true;
    }

    /**
     * Valida la data di scadenza della carta.
     */
    function validateScadenza() {
        const value = scadenzaInput.value.trim();

        if (value === '') {
            showError(scadenzaInput, 'La scadenza è obbligatoria.');
            return false;
        }

        if (!SCADENZA_REGEX.test(value)) {
            showError(scadenzaInput, 'Formato: MM/AA');
            return false;
        }

        // Verifica che la data non sia passata
        const parts = value.split('/');
        const month = parseInt(parts[0], 10);
        const year = parseInt('20' + parts[1], 10);
        const now = new Date();
        const expiry = new Date(year, month); // Il mese successivo, giorno 1

        if (expiry <= now) {
            showError(scadenzaInput, 'La carta risulta scaduta.');
            return false;
        }

        markValid(scadenzaInput);
        return true;
    }

    /**
     * Valida il codice CVV.
     */
    function validateCvv() {
        const value = cvvInput.value.trim();

        if (value === '') {
            showError(cvvInput, 'Il CVV è obbligatorio.');
            return false;
        }

        if (!CVV_REGEX.test(value)) {
            showError(cvvInput, 'Inserisci un CVV valido (3 o 4 cifre).');
            return false;
        }

        markValid(cvvInput);
        return true;
    }

    // -------------------------------------------------------
    // EVENT LISTENERS — Validazione su "change" di ogni campo
    // -------------------------------------------------------

    indirizzoInput.addEventListener('change', validateIndirizzo);
    indirizzoInput.addEventListener('input', function () {
        if (indirizzoInput.classList.contains('input-error')) {
            clearError(indirizzoInput);
        }
    });

    titolareCartaInput.addEventListener('change', validateTitolareCarta);
    titolareCartaInput.addEventListener('input', function () {
        if (titolareCartaInput.classList.contains('input-error')) {
            clearError(titolareCartaInput);
        }
    });

    numeroCartaInput.addEventListener('change', validateNumeroCarta);
    // L'input listener per il numero carta è già gestito dalla formattazione automatica
    // Aggiungiamo la rimozione dell'errore
    numeroCartaInput.addEventListener('input', function () {
        if (numeroCartaInput.classList.contains('input-error')) {
            clearError(numeroCartaInput);
        }
    });

    scadenzaInput.addEventListener('change', validateScadenza);
    scadenzaInput.addEventListener('input', function () {
        if (scadenzaInput.classList.contains('input-error')) {
            clearError(scadenzaInput);
        }
    });

    cvvInput.addEventListener('change', validateCvv);
    cvvInput.addEventListener('input', function () {
        if (cvvInput.classList.contains('input-error')) {
            clearError(cvvInput);
        }
    });

    // -------------------------------------------------------
    // EVENT LISTENER — Validazione su "submit" del form
    // -------------------------------------------------------

    form.addEventListener('submit', function (e) {
        const isIndirizzoValid = validateIndirizzo();
        const isTitolareValid = validateTitolareCarta();
        const isNumeroValid = validateNumeroCarta();
        const isScadenzaValid = validateScadenza();
        const isCvvValid = validateCvv();

        // Blocco l'invio del form se almeno un campo non è valido
        if (!isIndirizzoValid || !isTitolareValid || !isNumeroValid || !isScadenzaValid || !isCvvValid) {
            e.preventDefault();

            // Focus sul primo campo con errore
            const firstInvalid = form.querySelector('.input-error');
            if (firstInvalid) {
                firstInvalid.focus();
            }
            return;
        }

        // Compongo il campo hidden "datiPagamento" per il server
        // Maschero il numero della carta per sicurezza (mostrando solo le ultime 4 cifre)
        const numCarta = numeroCartaInput.value.replace(/\s/g, '');
        const ultime4 = numCarta.slice(-4);
        datiPagamentoHidden.value = 'Carta di Credito (**** **** **** ' + ultime4 + ')';
    });
});
