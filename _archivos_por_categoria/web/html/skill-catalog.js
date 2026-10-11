(() => {
  'use strict';
  const pageSize = 12;
  let currentPage = 1;
  let toastTimer;
  const cards = [...document.querySelectorAll('[data-skill-search]')];
  const search = document.getElementById('skill-search');
  const category = document.getElementById('skill-category');
  const scope = document.getElementById('skill-scope');
  const origin = document.getElementById('skill-origin-filter');
  const pack = document.getElementById('skill-package-filter');
  const normalize = text => text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  const searchable = new Map(cards.map(card => [card, normalize(card.dataset.skillSearch)]));
  const searchTokens = new Map(cards.map(card => [card, [...new Set(searchable.get(card).split(/[^a-z0-9]+/).filter(w => w.length > 2))]]));

  // Tolerancia a erratas al escribir en el buscador (ej. "graffify" encuentra "graphify"):
  // primero se prueba coincidencia exacta/parcial (rapida); si falla, se compara por distancia
  // de edicion contra cada palabra indexada de la ficha, con un margen segun la longitud de lo escrito.
  function levenshtein(a, b) {
    const m = a.length, n = b.length;
    if (m === 0) return n;
    if (n === 0) return m;
    let prev = Array.from({length: n + 1}, (_, j) => j);
    for (let i = 1; i <= m; i++) {
      const curr = [i];
      for (let j = 1; j <= n; j++) {
        curr[j] = a[i - 1] === b[j - 1]
          ? prev[j - 1]
          : 1 + Math.min(prev[j - 1], prev[j], curr[j - 1]);
      }
      prev = curr;
    }
    return prev[n];
  }

  function typoTolerance(word) {
    if (word.length <= 3) return 0;
    if (word.length <= 5) return 1;
    if (word.length <= 8) return 2;
    return 3;
  }

  function textMatches(word, text, tokens) {
    if (text.includes(word)) return true;
    const tolerance = typoTolerance(word);
    if (tolerance === 0) return false;
    return tokens.some(token => {
      if (Math.abs(token.length - word.length) > tolerance) return false;
      return levenshtein(word, token) <= tolerance;
    });
  }

  function wordMatches(word, card) {
    return textMatches(word, searchable.get(card), searchTokens.get(card));
  }

  // Fichas agrupadas (varias skills en una): se cuentan las skills que encajan, no la ficha.
  const members = new Map(cards.filter(c => c.dataset.skillMembers).map(c => [c, c.dataset.skillMembers.split('|').map(t => {
    const n = normalize(t);
    return {text: n, tokens: [...new Set(n.split(/[^a-z0-9]+/).filter(w => w.length > 2))]};
  })]));

  const commons = new Map(cards.filter(c => c.dataset.skillCommon).map(c => {
    const n = normalize(c.dataset.skillCommon);
    return [c, {text: n, tokens: [...new Set(n.split(/[^a-z0-9]+/).filter(w => w.length > 2))]}];
  }));

  function skillsIn(card, words) {
    const list = members.get(card);
    if (!list) return 1;
    if (!words.length) return Number(card.dataset.skillCount) || list.length;
    const common = commons.get(card) || {text: '', tokens: []};
    const found = list.filter(m => words.every(w => textMatches(w, m.text, m.tokens) || textMatches(w, common.text, common.tokens))).length;
    return Math.max(1, found);
  }

  function render(reset = true) {
    if (reset) currentPage = 1;
    const words = normalize(search.value.trim()).split(/\s+/).filter(Boolean);
    const matches = cards.filter(card => words.every(word => wordMatches(word, card)) &&
      (!category.value || card.dataset.skillCategory === category.value) &&
      (!scope.value || card.dataset.skillScope === scope.value) &&
      (!origin.value || card.dataset.skillOrigin === origin.value) &&
      (!pack.value || card.dataset.skillPackage === pack.value));
    const pages = Math.max(1, Math.ceil(matches.length / pageSize));
    currentPage = Math.min(currentPage, pages);
    const offset = (currentPage - 1) * pageSize;
    cards.forEach(card => { card.hidden = true; });
    matches.slice(offset, offset + pageSize).forEach(card => { card.hidden = false; });
    const total = matches.reduce((n, card) => n + skillsIn(card, words), 0);
    const inCards = total !== matches.length ? ` en ${matches.length} ${matches.length === 1 ? 'ficha' : 'fichas'}` : '';
    document.getElementById('skill-search-count').textContent = matches.length
      ? `${total} ${total === 1 ? 'skill encontrada' : 'skills encontradas'}${inCards}. Mostrando ${offset + 1}–${Math.min(offset + pageSize, matches.length)}.`
      : 'No hay skills con estos filtros.';
    document.getElementById('skill-empty').hidden = matches.length > 0;
    document.getElementById('skill-page').textContent = `Página ${currentPage} de ${pages}`;
    document.getElementById('skill-prev').disabled = currentPage === 1;
    document.getElementById('skill-next').disabled = currentPage === pages;
    document.getElementById('skill-pagination').hidden = matches.length === 0;
  }

  function selectPanel(id, scroll = false) {
    const target = document.getElementById(id);
    if (!target || !target.classList.contains('portal-panel')) return;
    document.querySelectorAll('.portal-panel').forEach(panel => { panel.hidden = panel !== target; });
    document.querySelectorAll('[data-panel]').forEach(button => {
      const active = button.dataset.panel === id;
      button.classList.toggle('active', active);
      button.setAttribute('aria-pressed', String(active));
    });
    if (scroll) history.replaceState(null, '', `#${id}`);
    if (scroll) target.scrollIntoView({block: 'start'});
  }

  window.scrollToPortalSection = id => selectPanel(id, true);
  window.showAllSkills = () => {
    search.value = category.value = scope.value = origin.value = pack.value = '';
    render();
    selectPanel('panel-skills', true);
  };
  window.showSkillCategory = value => {
    search.value = '';
    category.value = value;
    render();
    selectPanel('panel-skills', true);
  };
  window.showOnlyOrigin = value => {
    search.value = category.value = scope.value = pack.value = '';
    origin.value = value;
    render();
    selectPanel('panel-skills', true);
  };
  window.filterSkills = () => render();

  document.querySelectorAll('[data-panel]').forEach(button => button.addEventListener('click', () => selectPanel(button.dataset.panel, true)));
  search.addEventListener('input', () => render());
  category.addEventListener('change', () => render());
  scope.addEventListener('change', () => render());
  origin.addEventListener('change', () => render());
  pack.addEventListener('change', () => render());
  document.querySelectorAll('[data-search-example]').forEach(button => button.addEventListener('click', () => {
    search.value = button.dataset.searchExample;
    category.value = scope.value = origin.value = pack.value = '';
    render();
    search.focus({preventScroll: true});
  }));
  document.querySelectorAll('[data-reset-skills]').forEach(button => button.addEventListener('click', window.showAllSkills));
  for (const [id, delta] of [['skill-prev', -1], ['skill-next', 1]]) {
    document.getElementById(id).addEventListener('click', () => {
      currentPage += delta;
      render(false);
      document.getElementById('skill-results-start').focus({preventScroll: true});
      document.getElementById('skill-results-start').scrollIntoView({block: 'start'});
    });
  }
  document.addEventListener('click', async event => {
    const button = event.target.closest('[data-copy-prompt]');
    if (!button) return;
    const prompt = button.closest('article').querySelector('.skill-prompt').textContent.trim();
    try {
      if (!navigator.clipboard?.writeText) throw new Error('Clipboard unavailable');
      await navigator.clipboard.writeText(prompt);
      document.getElementById('copy-status').textContent = 'Ejemplo copiado. Pégalo en el chat de tu agente y añade tus datos.';
      clearTimeout(toastTimer);
      toastTimer = setTimeout(() => { document.getElementById('copy-status').textContent = ''; }, 6000);
      button.textContent = 'Copiado';
      setTimeout(() => { button.textContent = 'Copiar ejemplo'; }, 2000);
    } catch {
      const dialog = document.getElementById('copy-dialog');
      const field = dialog.querySelector('textarea');
      field.value = prompt;
      dialog.showModal();
      field.focus();
      field.select();
    }
  });
  document.querySelector('#copy-dialog button').addEventListener('click', () => document.getElementById('copy-dialog').close());
  window.addEventListener('hashchange', () => selectPanel(location.hash.slice(1)));
  selectPanel(document.getElementById(location.hash.slice(1))?.classList.contains('portal-panel') ? location.hash.slice(1) : 'panel-skills');
  render();
})();
