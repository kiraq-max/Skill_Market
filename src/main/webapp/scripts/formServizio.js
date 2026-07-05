/**
 * SkillMarket — Validazione form Inserimento/Modifica Servizio
 *
 * Requisiti rispettati (da specifica TSW):
 * - Validazione con espressioni regolari
 * - Messaggi di errore visualizzati nel DOM (NO alert!)
 * - Errori mostrati sia su evento "change" che su "submit"
 * - I dati vengono inviati al server solo se la validazione è positiva
 */

document.addEventListener('DOMContentLoaded', function () {

    const form = document.getElementById('formServizio');
    const titoloInput    = document.getElementById('titolo');
    const prezzoInput    = document.getElementById('prezzo');
    const categoriaInput = document.getElementById('categoria');
    const immagineInput  = document.getElementById('immagine');
    const descrizioneInput = document.getElementById('descrizione');

    // Regex: titolo — almeno 3 caratteri, no spazi iniziali/finali
    const TITOLO_REGEX = /^.{3,100}$/;

    // Regex: prezzo — numero positivo con al massimo 2 decimali (es. 49.99)
    const PREZZO_REGEX = /^\d+(\.\d{1,2})?$/;

    // Regex: immagine — nome file opzionale con estensione immagine valida
    const IMMAGINE_REGEX = /^$|^[\w\-. ]+\.(jpg|jpeg|png|gif|webp|svg)$/i;

    // -------------------------------------------------------
    // UTILITY: Mostra/Nascondi errore su un campo
    // -------------------------------------------------------

    /**
     * Mostra un messaggio di errore sotto il campo specificato.
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
     * Valida il campo Titolo.
     * @returns {boolean} true se il campo è valido.
     */
    function validateTitolo() {
        const value = titoloInput.value.trim();

        if (value === '') {
            showError(titoloInput, 'Il titolo è obbligatorio.');
            return false;
        }
        if (!TITOLO_REGEX.test(value)) {
            showError(titoloInput, 'Il titolo deve essere tra 3 e 100 caratteri.');
            return false;
        }

        markValid(titoloInput);
        return true;
    }

    /**
     * Valida il campo Prezzo.
     * @returns {boolean} true se il campo è valido.
     */
    function validatePrezzo() {
        const value = prezzoInput.value.trim();

        if (value === '') {
            showError(prezzoInput, 'Il prezzo è obbligatorio.');
            return false;
        }
        if (!PREZZO_REGEX.test(value)) {
            showError(prezzoInput, 'Inserisci un prezzo valido (es. 49 oppure 49.99).');
            return false;
        }
        const numeric = parseFloat(value);
        if (numeric <= 0) {
            showError(prezzoInput, 'Il prezzo deve essere maggiore di zero.');
            return false;
        }
        if (numeric > 99999.99) {
            showError(prezzoInput, 'Il prezzo non può superare € 99.999,99.');
            return false;
        }

        markValid(prezzoInput);
        return true;
    }

    /**
     * Valida il campo Categoria (select).
     * @returns {boolean} true se il campo è valido.
     */
    function validateCategoria() {
        const value = categoriaInput.value;

        if (!value || value === '') {
            showError(categoriaInput, 'Seleziona una categoria per il servizio.');
            return false;
        }

        markValid(categoriaInput);
        return true;
    }

    /**
     * Valida il campo Immagine (facoltativo, ma se compilato deve avere estensione valida).
     * @returns {boolean} true se il campo è valido.
     */
    function validateImmagine() {
        const value = immagineInput.value.trim();

        if (!IMMAGINE_REGEX.test(value)) {
            showError(immagineInput, 'Estensione non valida. Usa jpg, jpeg, png, gif, webp o svg.');
            return false;
        }

        markValid(immagineInput);
        return true;
    }

    /**
     * Valida il campo Descrizione.
     * @returns {boolean} true se il campo è valido.
     */
    function validateDescrizione() {
        const value = descrizioneInput.value.trim();

        if (value === '') {
            showError(descrizioneInput, 'La descrizione è obbligatoria.');
            return false;
        }
        if (value.length < 20) {
            showError(descrizioneInput, 'La descrizione deve contenere almeno 20 caratteri.');
            return false;
        }
        if (value.length > 5000) {
            showError(descrizioneInput, 'La descrizione non può superare i 5000 caratteri.');
            return false;
        }

        markValid(descrizioneInput);
        return true;
    }

    // -------------------------------------------------------
    // EVENT LISTENERS — Validazione live su "input"/"change"
    // -------------------------------------------------------

    titoloInput.addEventListener('change', validateTitolo);
    titoloInput.addEventListener('input', function () {
        if (titoloInput.classList.contains('input-error')) clearError(titoloInput);
    });

    prezzoInput.addEventListener('change', validatePrezzo);
    prezzoInput.addEventListener('input', function () {
        if (prezzoInput.classList.contains('input-error')) clearError(prezzoInput);
    });

    categoriaInput.addEventListener('change', validateCategoria);

    immagineInput.addEventListener('change', validateImmagine);
    immagineInput.addEventListener('input', function () {
        if (immagineInput.classList.contains('input-error')) clearError(immagineInput);
    });

    descrizioneInput.addEventListener('change', validateDescrizione);
    descrizioneInput.addEventListener('input', function () {
        if (descrizioneInput.classList.contains('input-error')) clearError(descrizioneInput);
    });

    // -------------------------------------------------------
    // EVENT LISTENER — Validazione completa su "submit"
    // -------------------------------------------------------

    form.addEventListener('submit', function (e) {
        // Eseguo tutte le validazioni (non uso short-circuit || per mostrarle tutte)
        const isTitoloValid     = validateTitolo();
        const isPrezzoValid     = validatePrezzo();
        const isCategoriaValid  = validateCategoria();
        const isImmagineValid   = validateImmagine();
        const isDescrizioneValid = validateDescrizione();

        const isFormValid = isTitoloValid && isPrezzoValid && isCategoriaValid
                         && isImmagineValid && isDescrizioneValid;

        if (!isFormValid) {
            e.preventDefault();

            // Porta il focus al primo campo con errore
            if (!isTitoloValid)          titoloInput.focus();
            else if (!isPrezzoValid)     prezzoInput.focus();
            else if (!isCategoriaValid)  categoriaInput.focus();
            else if (!isImmagineValid)   immagineInput.focus();
            else if (!isDescrizioneValid) descrizioneInput.focus();
        }
    });

    // -------------------------------------------------------
    // Validazione iniziale in caso di form in modalità "edit"
    // (evidenzia subito i campi che potrebbero essere precompilati)
    // -------------------------------------------------------
    if (form.dataset.mode === 'edit') {
        // Segno i campi già compilati come validi al caricamento
        [titoloInput, prezzoInput, categoriaInput, descrizioneInput].forEach(function(input) {
            if (input.value && input.value.trim() !== '') {
                input.classList.add('input-valid');
            }
        });
    }
});
