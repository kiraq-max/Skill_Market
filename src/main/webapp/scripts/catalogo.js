/**
 * SkillMarket — Filtro Catalogo via AJAX
 *
 * Requisiti TSW rispettati:
 * - Usa AJAX (fetch API) per scambiare dati con il server senza ricaricare la pagina
 * - Aggiorna il DOM dinamicamente con i risultati ricevuti in JSON
 * - Mantiene il comportamento tradizionale (link normali) come fallback se JS non funziona
 */

document.addEventListener('DOMContentLoaded', function () {

    const categoryLinks = document.querySelectorAll('.category-item');
    const servicesGrid  = document.getElementById('servicesGrid');
    const catalogContent = document.getElementById('catalogContent');
    const countEl       = document.querySelector('.catalog-subtitle');

    // Recuperiamo il contextPath dal meta tag che aggiungiamo nella JSP
    const contextPath = document.getElementById('contextPathMeta')
        ? document.getElementById('contextPathMeta').getAttribute('content')
        : '';

    // -------------------------------------------------------
    // Intercetta i click sui link delle categorie
    // -------------------------------------------------------
    categoryLinks.forEach(function (link) {
        link.addEventListener('click', function (e) {
            e.preventDefault(); // Blocca la navigazione normale

            const href = link.getAttribute('href');

            // Aggiorna la classe "active" nella sidebar
            categoryLinks.forEach(l => l.classList.remove('active'));
            link.classList.add('active');

            // Mostra un indicatore di caricamento
            showLoading();

            // Costruisce l'URL per la chiamata AJAX
            // (stesso URL del link normale, la servlet distingue per header)
            fetch(href, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'  // Header che la servlet controlla
                }
            })
            .then(function (res) {
                if (!res.ok) {
                    throw new Error('Risposta server non valida: ' + res.status);
                }
                return res.json();
            })
            .then(function (servizi) {
                renderServizi(servizi, contextPath);
                updateCount(servizi.length);
                // Aggiorna l'URL nella barra del browser senza ricaricare la pagina
                window.history.pushState({}, '', href);
            })
            .catch(function (err) {
                console.error('Errore AJAX catalogo:', err);
                showError('Errore nel caricamento dei servizi. Riprova.');
            });
        });
    });

    // -------------------------------------------------------
    // Gestione del pulsante avanti/indietro del browser
    // -------------------------------------------------------
    window.addEventListener('popstate', function () {
        const url = window.location.href;
        fetch(url, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => res.json())
        .then(servizi => {
            renderServizi(servizi, contextPath);
            updateCount(servizi.length);
        })
        .catch(err => console.error('Errore popstate:', err));
    });

    // -------------------------------------------------------
    // FUNZIONI DI RENDERING
    // -------------------------------------------------------

    /**
     * Mostra un indicatore di caricamento nella griglia.
     */
    function showLoading() {
        const container = getOrCreateGridContainer();
        container.innerHTML = '<div class="ajax-loading" id="ajaxLoading">'
            + '<div class="ajax-spinner"></div>'
            + '<p>Caricamento servizi&hellip;</p>'
            + '</div>';
    }

    /**
     * Mostra un messaggio di errore nella griglia.
     */
    function showError(msg) {
        const container = getOrCreateGridContainer();
        container.innerHTML = '<div class="alert alert-error">'
            + '&#9888;&#65039; ' + msg
            + '</div>';
    }

    /**
     * Aggiorna il contatore dei servizi mostrati.
     */
    function updateCount(n) {
        if (countEl) {
            const label = n === 1 ? 'servizio disponibile' : 'servizi disponibili';
            countEl.innerHTML = '<strong>' + n + '</strong> ' + label;
        }
    }

    /**
     * Restituisce il contenitore della griglia, creandolo se non esiste.
     */
    function getOrCreateGridContainer() {
        // Proviamo prima con la griglia esistente
        let grid = document.getElementById('servicesGrid');
        if (!grid) {
            // Se non esiste (stato vuoto), usiamo la section catalogContent
            grid = catalogContent;
        }
        return grid;
    }

    /**
     * Ricostruisce la griglia delle card servizi dal JSON ricevuto.
     * @param {Array} servizi - Array di oggetti servizio ricevuti dal server.
     * @param {string} ctxPath - Context path dell'applicazione.
     */
    function renderServizi(servizi, ctxPath) {
        // Svuotiamo tutto ciò che era nel content (griglia o stato vuoto)
        // e ricostruiamo dal JSON
        const section = catalogContent;

        // Rimuoviamo eventuale stato vuoto o vecchia griglia
        const oldGrid   = section.querySelector('.services-grid');
        const oldEmpty  = section.querySelector('.empty-state');
        const oldError  = section.querySelector('.alert');
        const oldLoader = section.querySelector('.ajax-loading');
        if (oldGrid)   oldGrid.remove();
        if (oldEmpty)  oldEmpty.remove();
        if (oldError)  oldError.remove();
        if (oldLoader) oldLoader.remove();

        if (!servizi || servizi.length === 0) {
            // Stato vuoto
            const emptyDiv = document.createElement('div');
            emptyDiv.className = 'empty-state';
            emptyDiv.id = 'emptyState';
            emptyDiv.innerHTML = '<div class="empty-state-icon">&#128269;</div>'
                + '<h2>Nessun servizio trovato</h2>'
                + '<p>Non ci sono servizi disponibili per questa categoria.<br>Prova a selezionare un\'altra categoria.</p>'
                + '<a href="' + ctxPath + '/catalogo" class="btn btn-primary" id="btnResetFilter">Mostra tutti i servizi</a>';
            section.appendChild(emptyDiv);
            return;
        }

        // Griglia con le card
        const grid = document.createElement('div');
        grid.className = 'services-grid';
        grid.id = 'servicesGrid';

        servizi.forEach(function (s) {
            const link = document.createElement('a');
            link.href = ctxPath + '/servizio?id=' + s.id;
            link.className = 'service-card';
            link.id = 'service_' + s.id;

            link.innerHTML =
                '<div class="service-card-img">'
                +   '<img src="' + s.immagine + '" alt="' + escapeHtml(s.titolo) + '" loading="lazy">'
                + '</div>'
                + '<div class="service-card-body">'
                +   '<h3 class="service-card-title">' + escapeHtml(s.titolo) + '</h3>'
                +   '<p class="service-card-desc">' + escapeHtml(s.descrizione) + '</p>'
                + '</div>'
                + '<div class="service-card-footer">'
                +   '<span class="service-price">&euro; ' + s.prezzo + '</span>'
                +   '<span class="btn btn-card" id="btnDetail_' + s.id + '">Dettagli</span>'
                + '</div>';

            grid.appendChild(link);
        });

        section.appendChild(grid);
    }

    /**
     * Escaping HTML per prevenire XSS quando si inserisce testo nel DOM.
     */
    function escapeHtml(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }
});
