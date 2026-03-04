# World Credit Trust Badge SDK

Embed verified trust scores anywhere — websites, mobile apps, marketplaces.

## Quick Start (Web)

```html
<!-- Add a badge next to any username -->
<span>Ryan N.</span>
<div data-worldcredit="ryannapp" data-style="inline"></div>

<!-- Load SDK -->
<script src="https://world-credit.com/sdk/badge.js"></script>
```

## Badge Styles

| Style | Use Case | Preview |
|-------|----------|---------|
| `inline` | Next to usernames | `52 · Gold` pill |
| `pill` | Lists and cards | Logo + score + tier capsule |
| `card` | Profile sidebars | Rich card with large score |
| `shield` | Minimal spaces | Logo + checkmark |

## Options

| Attribute | Values | Default |
|-----------|--------|---------|
| `data-worldcredit` | User handle | Required |
| `data-style` | `inline` `pill` `card` `shield` | `inline` |
| `data-theme` | `dark` `light` | `dark` |
| `data-size` | `sm` `md` `lg` | `md` |

## JavaScript API

```js
// Render a specific element
WorldCredit.render(document.getElementById('badge'));

// Re-render all badges on page
WorldCredit.renderAll();

// Fetch badge data programmatically
const data = await WorldCredit.fetch('ryannapp');
// → { ok, handle, displayName, worldScore, tier, tierColor, profileUrl, ... }
```

## Badge API

```
GET https://badgeapi-czne44luta-uc.a.run.app?handle=ryannapp
```

Response:
```json
{
  "ok": true,
  "handle": "ryannapp",
  "displayName": "Ryan Napolitano",
  "worldScore": 52,
  "tier": "Gold",
  "tierColor": "#FFD700",
  "linkedNetworks": 8,
  "profileUrl": "https://profile-czne44luta-uc.a.run.app?handle=ryannapp",
  "categories": [
    { "label": "Reliability", "score": 25 },
    { "label": "Financial Integrity", "score": 0 },
    { "label": "Social Proof", "score": 35 }
  ]
}
```

## SDKs

| Platform | Status | Location |
|----------|--------|----------|
| JavaScript (Web) | ✅ Ready | [`js/`](./js/) |
| Flutter | 🔜 Coming | [`flutter/`](./flutter/) |
| iOS (Swift) | 🔜 Coming | [`ios/`](./ios/) |
| Android (Kotlin) | 🔜 Coming | [`android/`](./android/) |

## License

© 2025 World Credit Inc. All Rights Reserved.
