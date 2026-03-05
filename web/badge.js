/**
 * World Credit Trust Badge SDK v1.0
 * https://world-credit.com/sdk
 *
 * Usage:
 *   <div data-worldcredit="handle" data-style="inline|pill|card|shield"></div>
 *   <script src="https://world-credit.com/sdk/badge.js"></script>
 *
 * Styles:
 *   inline  — compact, sits next to a username (default)
 *   pill    — logo + score + tier in a capsule
 *   card    — rich display for profile sidebars
 *   shield  — minimal logo + checkmark
 *
 * Options (data attributes):
 *   data-worldcredit  — user handle (required)
 *   data-style        — badge style: inline|pill|card|shield (default: inline)
 *   data-theme        — dark|light (default: dark)
 *   data-size         — sm|md|lg (default: md)
 */
(function() {
  'use strict';

  const API = 'https://badgeapi-czne44luta-uc.a.run.app';
  const LOGO = 'https://worldcredit-c266e.web.app/WorldCreditAppLogo.png';
  const FONT_URL = 'https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700&display=swap';
  const CACHE = {};

  // Read API key from pre-configured global or default to empty
  const _cfg = window.WorldCredit || {};
  const API_KEY = _cfg.apiKey || '';

  // Inject font
  if (!document.querySelector('link[href*="Inter"]')) {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = FONT_URL;
    document.head.appendChild(link);
  }

  // Inject base styles
  const style = document.createElement('style');
  style.textContent = `
    .wc-badge{font-family:'Inter',system-ui,sans-serif;-webkit-font-smoothing:antialiased;text-decoration:none;display:inline-flex;transition:all .2s ease}
    .wc-badge:hover{text-decoration:none}
    .wc-badge *{box-sizing:border-box;margin:0;padding:0}

    /* ── Inline ── */
    .wc-inline{align-items:center;gap:5px;padding:2px 9px 2px 4px;border-radius:16px;font-size:11px;font-weight:600;cursor:pointer;white-space:nowrap}
    .wc-inline img{width:14px;height:14px;border-radius:3px}
    .wc-inline:hover{filter:brightness(1.15)}
    .wc-inline.wc-sm{font-size:10px;padding:1px 7px 1px 3px;border-radius:12px}
    .wc-inline.wc-sm img{width:12px;height:12px}
    .wc-inline.wc-lg{font-size:13px;padding:3px 12px 3px 6px;gap:6px}
    .wc-inline.wc-lg img{width:18px;height:18px;border-radius:4px}

    /* ── Pill ── */
    .wc-pill{align-items:center;gap:7px;padding:5px 12px 5px 7px;border-radius:20px;cursor:pointer}
    .wc-pill img{width:20px;height:20px;border-radius:5px}
    .wc-pill .wc-pill-score{font-weight:700;font-size:14px}
    .wc-pill .wc-pill-tier{font-size:9px;font-weight:700;letter-spacing:.8px;padding:2px 7px;border-radius:8px}
    .wc-pill:hover{filter:brightness(1.08)}
    .wc-pill.wc-sm img{width:16px;height:16px}.wc-pill.wc-sm .wc-pill-score{font-size:12px}.wc-pill.wc-sm{padding:3px 10px 3px 5px;gap:5px}
    .wc-pill.wc-lg img{width:24px;height:24px;border-radius:6px}.wc-pill.wc-lg .wc-pill-score{font-size:16px}.wc-pill.wc-lg{padding:7px 16px 7px 10px;gap:9px}

    /* ── Card ── */
    .wc-card{flex-direction:column;align-items:center;padding:18px 24px;border-radius:12px;min-width:140px;cursor:pointer;text-align:center}
    .wc-card img{width:24px;height:24px;border-radius:5px;margin-bottom:8px}
    .wc-card .wc-card-label{font-size:9px;font-weight:600;letter-spacing:.8px;text-transform:uppercase;margin-bottom:4px}
    .wc-card .wc-card-score{font-weight:700;font-size:32px;line-height:1;margin-bottom:5px}
    .wc-card .wc-card-tier{font-size:9px;font-weight:700;letter-spacing:1.2px;padding:3px 10px;border-radius:8px}
    .wc-card:hover{transform:translateY(-2px)}
    .wc-card.wc-sm{padding:14px 18px;min-width:110px}.wc-card.wc-sm .wc-card-score{font-size:24px}.wc-card.wc-sm img{width:20px;height:20px}
    .wc-card.wc-lg{padding:24px 32px;min-width:180px}.wc-card.wc-lg .wc-card-score{font-size:42px}.wc-card.wc-lg img{width:32px;height:32px;border-radius:7px}

    /* ── Shield ── */
    .wc-shield{align-items:center;gap:3px;cursor:pointer}
    .wc-shield img{width:18px;height:18px;border-radius:4px}
    .wc-shield .wc-shield-check{width:12px;height:12px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:7px;font-weight:bold;line-height:1}
    .wc-shield:hover{filter:brightness(1.2)}
    .wc-shield.wc-sm img{width:14px;height:14px}.wc-shield.wc-sm .wc-shield-check{width:10px;height:10px;font-size:6px}
    .wc-shield.wc-lg img{width:24px;height:24px;border-radius:5px}.wc-shield.wc-lg .wc-shield-check{width:16px;height:16px;font-size:9px}

    /* ── Themes ── */
    .wc-dark.wc-inline{border:1px solid rgba(255,255,255,.12)}
    .wc-dark.wc-pill{background:#0A1128;border:1px solid rgba(255,255,255,.08)}
    .wc-dark.wc-card{background:#0A1128;border:1px solid rgba(255,255,255,.08);color:#fff}
    .wc-dark .wc-card-label{color:rgba(255,255,255,.5)}

    .wc-light.wc-inline{border:1px solid rgba(0,0,0,.1)}
    .wc-light.wc-pill{background:#fff;border:1px solid rgba(0,0,0,.08);box-shadow:0 1px 4px rgba(0,0,0,.08)}
    .wc-light.wc-card{background:#fff;border:1px solid rgba(0,0,0,.08);color:#1a1a2e;box-shadow:0 2px 12px rgba(0,0,0,.06)}
    .wc-light .wc-card-label{color:rgba(0,0,0,.45)}
  `;
  document.head.appendChild(style);

  const UNVERIFIED_COLOR = '#4A5568';
  const UNVERIFIED_BG = 'rgba(74,85,104,.1)';
  const UNVERIFIED_BORDER = 'rgba(74,85,104,.2)';

  function tierColors(tier) {
    const t = (tier || '').toLowerCase();
    return {
      platinum:   { color: '#00FFC8', bg: 'rgba(0,255,200,.1)',  border: 'rgba(0,255,200,.2)'  },
      gold:       { color: '#FFD700', bg: 'rgba(255,215,0,.1)',  border: 'rgba(255,215,0,.2)'  },
      silver:     { color: '#C0C0C0', bg: 'rgba(192,192,192,.1)',border: 'rgba(192,192,192,.2)'},
      bronze:     { color: '#CD7F32', bg: 'rgba(205,127,50,.1)', border: 'rgba(205,127,50,.2)' },
      unrated:    { color: UNVERIFIED_COLOR, bg: UNVERIFIED_BG,  border: UNVERIFIED_BORDER     },
      unverified: { color: UNVERIFIED_COLOR, bg: UNVERIFIED_BG,  border: UNVERIFIED_BORDER     },
    }[t] || { color: UNVERIFIED_COLOR, bg: UNVERIFIED_BG, border: UNVERIFIED_BORDER };
  }

  function tierColorsLight(tier) {
    const t = (tier || '').toLowerCase();
    return {
      platinum:   { color: '#009B7D', bg: 'rgba(0,155,125,.08)',  border: 'rgba(0,155,125,.18)'  },
      gold:       { color: '#B8960F', bg: 'rgba(184,150,15,.08)', border: 'rgba(184,150,15,.18)' },
      silver:     { color: '#6B7280', bg: 'rgba(107,114,128,.08)',border: 'rgba(107,114,128,.18)'},
      bronze:     { color: '#92600A', bg: 'rgba(146,96,10,.08)', border: 'rgba(146,96,10,.18)'  },
      unrated:    { color: '#9CA3AF', bg: 'rgba(156,163,175,.08)',border: 'rgba(156,163,175,.18)'},
      unverified: { color: '#9CA3AF', bg: 'rgba(156,163,175,.08)',border: 'rgba(156,163,175,.18)'},
    }[t] || { color: '#9CA3AF', bg: 'rgba(156,163,175,.08)', border: 'rgba(156,163,175,.18)' };
  }

  function isUnverified(data) { return data.verified === false; }

  function renderInline(data, tc, theme) {
    const a = document.createElement('a');
    a.href = data.profileUrl;
    a.target = '_blank';
    a.rel = 'noopener';
    a.style.cssText = `background:${tc.bg};border-color:${tc.border};color:${tc.color}${isUnverified(data) ? ';opacity:.7' : ''}`;
    if (isUnverified(data)) {
      a.innerHTML = `<img src="${LOGO}" alt="WC" style="opacity:.5">Not Verified`;
    } else {
      a.innerHTML = `<img src="${LOGO}" alt="WC">${data.worldScore} · ${data.tier}`;
    }
    return a;
  }

  function renderPill(data, tc, theme) {
    const a = document.createElement('a');
    a.href = data.profileUrl;
    a.target = '_blank';
    a.rel = 'noopener';
    if (isUnverified(data)) {
      a.innerHTML = `<img src="${LOGO}" alt="WC" style="opacity:.5"><span class="wc-pill-score" style="color:${tc.color}">—</span><span class="wc-pill-tier" style="background:${tc.bg};color:${tc.color}">NOT VERIFIED</span>`;
    } else {
      a.innerHTML = `<img src="${LOGO}" alt="WC"><span class="wc-pill-score" style="color:${tc.color}">${data.worldScore}</span><span class="wc-pill-tier" style="background:${tc.bg};color:${tc.color}">${data.tier.toUpperCase()}</span>`;
    }
    return a;
  }

  function renderCard(data, tc, theme) {
    const a = document.createElement('a');
    a.href = data.profileUrl;
    a.target = '_blank';
    a.rel = 'noopener';
    if (isUnverified(data)) {
      a.innerHTML = `<img src="${LOGO}" alt="WC" style="opacity:.5"><div class="wc-card-label">World Credit</div><div class="wc-card-score" style="color:${tc.color};font-size:16px">Not Verified</div><div class="wc-card-tier" style="background:${tc.bg};color:${tc.color}">GET VERIFIED →</div>`;
    } else {
      a.innerHTML = `<img src="${LOGO}" alt="WC"><div class="wc-card-label">World Credit</div><div class="wc-card-score" style="color:${tc.color}">${data.worldScore}</div><div class="wc-card-tier" style="background:${tc.bg};color:${tc.color}">${data.tier.toUpperCase()}</div>`;
    }
    return a;
  }

  function renderShield(data, tc, theme) {
    const a = document.createElement('a');
    a.href = data.profileUrl;
    a.target = '_blank';
    a.rel = 'noopener';
    if (isUnverified(data)) {
      a.title = 'World Credit: Not Verified';
      a.innerHTML = `<img src="${LOGO}" alt="WC" style="opacity:.4"><div class="wc-shield-check" style="background:${tc.color};color:${theme === 'light' ? '#fff' : '#060B1E'}">?</div>`;
    } else {
      a.title = `World Credit: ${data.worldScore} (${data.tier})`;
      a.innerHTML = `<img src="${LOGO}" alt="WC"><div class="wc-shield-check" style="background:${tc.color};color:${theme === 'light' ? '#fff' : '#060B1E'}">✓</div>`;
    }
    return a;
  }

  const renderers = { inline: renderInline, pill: renderPill, card: renderCard, shield: renderShield };
  const styleClasses = { inline: 'wc-inline', pill: 'wc-pill', card: 'wc-card', shield: 'wc-shield' };

  function fetchBadge(handle) {
    if (CACHE[handle]) return Promise.resolve(CACHE[handle]);
    let url = `${API}?handle=${encodeURIComponent(handle)}`;
    if (API_KEY) url += `&key=${encodeURIComponent(API_KEY)}`;
    return fetch(url)
      .then(r => r.json())
      .then(d => { if (d.ok) CACHE[handle] = d; return d; });
  }

  function renderBadge(el) {
    const handle = (el.getAttribute('data-worldcredit') || '').replace(/^@/, '');
    if (!handle) return;

    const badgeStyle = el.getAttribute('data-style') || 'inline';
    const theme = el.getAttribute('data-theme') || 'dark';
    const size = el.getAttribute('data-size') || 'md';
    const isSelf = el.getAttribute('data-self') === 'true';

    fetchBadge(handle).then(data => {
      if (!data || !data.ok) return;

      // If this is the user's own profile and they're unverified, override profileUrl to signup CTA
      if (isSelf && isUnverified(data)) {
        data.profileUrl = data.profileUrl || 'https://world-credit.com/signup';
      }

      const tc = theme === 'light' ? tierColorsLight(data.tier) : tierColors(data.tier);
      const renderer = renderers[badgeStyle] || renderers.inline;
      const badge = renderer(data, tc, theme);

      badge.className = `wc-badge ${styleClasses[badgeStyle] || 'wc-inline'} wc-${theme}`;
      if (size !== 'md') badge.classList.add(`wc-${size}`);

      el.innerHTML = '';
      el.appendChild(badge);
    }).catch(() => {});
  }

  // Init: find all elements with data-worldcredit and render
  function init() {
    document.querySelectorAll('[data-worldcredit]').forEach(renderBadge);
  }

  // Auto-init on DOMContentLoaded or immediately if already loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expose global API for dynamic badge creation (preserve apiKey if set before load)
  window.WorldCredit = Object.assign({}, _cfg, {
    render: renderBadge,
    renderAll: init,
    fetch: fetchBadge,
  });
})();
