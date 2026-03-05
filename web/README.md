# World Credit Badge SDK (Web)

Embed verified trust badges on any website. Four styles: inline, pill, card, shield.

## Quick Start

```html
<!-- Configure your API key -->
<script>
  window.WorldCredit = { apiKey: "your-api-key" };
</script>

<!-- Add badges anywhere -->
<div data-worldcredit="handle" data-style="inline"></div>

<!-- Load SDK -->
<script src="https://world-credit.com/sdk/badge.js"></script>
```

Or install via npm:

```bash
npm install worldcredit-badge
```

## Badge Styles

- `inline` — compact, sits next to a username
- `pill` — logo + score + tier capsule
- `card` — rich display for profile sidebars
- `shield` — minimal verified checkmark

## Options

| Attribute | Values | Default |
|-----------|--------|---------|
| `data-style` | `inline`, `pill`, `card`, `shield` | `inline` |
| `data-theme` | `dark`, `light` | `dark` |
| `data-size` | `sm`, `md`, `lg` | `md` |

## Email-Based Lookup (Recommended for B2B)

Look up users by email instead of World Credit handle:

```html
<!-- Look up by email (recommended for B2B integrations) -->
<div data-email="user@example.com" data-style="inline"></div>

<!-- Or by handle -->
<div data-worldcredit="handle" data-style="inline"></div>
```

## Unverified Badges

When a handle doesn't have a World Credit account, badges automatically render in a grayed-out **unverified state** that links to `world-credit.com/signup`. No extra code needed.

| Style | Unverified Behavior |
|-------|-------------------|
| `inline` | Shows "Not Verified" in muted gray |
| `pill` | Shows "—" score with "NOT VERIFIED" tag |
| `card` | Shows "Not Verified" with "GET VERIFIED →" CTA |
| `shield` | Shows "?" instead of checkmark |

## Get API Key

Sign up at [world-credit.com](https://world-credit.com) to get your API key.

## Docs

Full documentation at [world-credit.com/sdk](https://world-credit.com/sdk/)
