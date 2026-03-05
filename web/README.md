# World Credit Badge SDK — Web

Embed verified trust badges on any website. Zero dependencies.

[![npm](https://img.shields.io/npm/v/worldcredit-badge.svg)](https://www.npmjs.com/package/worldcredit-badge)

## Quick Start

```html
<!-- Configure your API key -->
<script>
  window.WorldCredit = { apiKey: "your-api-key" };
</script>

<!-- Look up by email (recommended for integrations) -->
<div data-email="user@example.com" data-style="pill"></div>

<!-- Or by World Credit handle -->
<div data-worldcredit="ryannapp" data-style="pill"></div>

<!-- Load SDK (before </body>) -->
<script src="https://world-credit.com/sdk/badge.js"></script>
```

Or install via npm:

```bash
npm install worldcredit-badge
```

> **API key required.** Get yours at [world-credit.com/#pricing](https://world-credit.com/#pricing)

## Badge Styles

| Style | Use Case |
|-------|----------|
| `inline` | Compact, next to usernames |
| `pill` | Logo + score + tier capsule |
| `card` | Rich display for profile sidebars |
| `shield` | Minimal verified checkmark |

```html
<div data-email="user@example.com" data-style="inline"></div>
<div data-email="user@example.com" data-style="pill"></div>
<div data-email="user@example.com" data-style="card"></div>
<div data-email="user@example.com" data-style="shield"></div>
```

## Options

| Attribute | Values | Default |
|-----------|--------|---------|
| `data-email` | User email (recommended) | — |
| `data-worldcredit` | World Credit handle | — |
| `data-style` | `inline` `pill` `card` `shield` | `inline` |
| `data-theme` | `dark` `light` | `dark` |
| `data-size` | `sm` `md` `lg` | `md` |

> **Tip:** Use `data-email` for B2B integrations — your platform already knows your users' emails.

## Unverified Badges

When a user doesn't have a World Credit account, badges automatically render an unverified state. No special handling needed.

| Style | Unverified Behavior |
|-------|-------------------|
| `inline` | "Not Verified" in muted gray |
| `pill` | "—" score with "NOT VERIFIED" tag |
| `card` | "Not Verified" with "GET VERIFIED →" CTA |
| `shield` | "?" instead of checkmark |

## Trust Tiers

| Tier | Score | Color |
|------|-------|-------|
| Bronze | 1 – 19 | `#CD7F32` |
| Silver | 20 – 49 | `#C0C0C0` |
| Gold | 50 – 79 | `#FFD700` |
| Platinum | 80 – 100 | `#00FFC8` |

## Other Platforms

- **iOS** — [Swift Package Manager](https://github.com/World-Credit-Inc/worldcredit-sdk)
- **Android** — [JitPack](https://jitpack.io/#World-Credit-Inc/worldcredit-sdk)
- **Flutter** — [pub.dev: worldcredit_badge](https://pub.dev/packages/worldcredit_badge)

## Links

- [SDK Documentation](https://world-credit.com/sdk/)
- [Get API Key](https://world-credit.com/#pricing)

## License

MIT — © 2026 World Credit Inc.
