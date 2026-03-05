# World Credit Badge SDK — Web

Embed verified trust badges on any website with 2 lines of HTML. No build tools, no dependencies.

## Quick Start

```html
<!-- Add a badge -->
<div data-worldcredit="handle" data-style="inline"></div>

<!-- Load SDK (before </body>) -->
<script src="https://world-credit.com/sdk/badge.js"></script>
```

That's it. The SDK auto-discovers all `data-worldcredit` elements and renders badges.

## Badge Styles

### Inline — sits next to usernames

```html
<div data-worldcredit="handle" data-style="inline"></div>
```

### Pill — compact capsule

```html
<div data-worldcredit="handle" data-style="pill"></div>
```

### Card — rich sidebar display

```html
<div data-worldcredit="handle" data-style="card"></div>
```

### Shield — minimal checkmark

```html
<div data-worldcredit="handle" data-style="shield"></div>
```

## Options

| Attribute | Values | Default |
|-----------|--------|---------|
| `data-worldcredit` | User handle | Required |
| `data-style` | `inline` `pill` `card` `shield` | `inline` |
| `data-theme` | `dark` `light` | `dark` |
| `data-size` | `sm` `md` `lg` | `md` |

## Themes

```html
<!-- Dark theme (default) — for dark backgrounds -->
<div data-worldcredit="handle" data-style="pill" data-theme="dark"></div>

<!-- Light theme — for white/light backgrounds -->
<div data-worldcredit="handle" data-style="pill" data-theme="light"></div>
```

## Sizes

```html
<div data-worldcredit="handle" data-style="pill" data-size="sm"></div>
<div data-worldcredit="handle" data-style="pill" data-size="md"></div>
<div data-worldcredit="handle" data-style="pill" data-size="lg"></div>
```

## Programmatic API

```javascript
// Fetch badge data directly
const response = await fetch('https://world-credit.com/api/badge?handle=handle');
const data = await response.json();

console.log(data.worldScore);  // 87
console.log(data.tier);        // "Platinum"
console.log(data.tierColor);   // "#00FFC8"
```

## How It Works

1. SDK scans the DOM for `[data-worldcredit]` elements
2. Fetches trust data from the World Credit Badge API
3. Renders the selected badge style inline
4. Clicking any badge opens the user's public profile
5. API responses are cached (5-minute TTL)

## Trust Tiers

| Tier | Score | Color |
|------|-------|-------|
| Bronze | 1 – 19 | `#CD7F32` |
| Silver | 20 – 49 | `#C0C0C0` |
| Gold | 50 – 79 | `#FFD700` |
| Platinum | 80 – 100 | `#00FFC8` |

## Browser Support

Works in all modern browsers (Chrome, Safari, Firefox, Edge). No polyfills needed.

## Live Demo

See all badge styles in action: [world-credit.com/sdk](https://world-credit.com/sdk/)

## License

© 2026 World Credit Inc. All Rights Reserved.
