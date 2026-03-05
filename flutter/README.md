# World Credit Badge SDK — Flutter

Embed verified trust badges in any Flutter app. Supports all platforms (iOS, Android, Web, macOS, Windows, Linux).

[![pub.dev](https://img.shields.io/pub/v/worldcredit_badge.svg)](https://pub.dev/packages/worldcredit_badge)

## Installation

```yaml
# pubspec.yaml
dependencies:
  worldcredit_badge: ^1.2.2
```

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:worldcredit_badge/worldcredit_badge.dart';

// Initialize with your API key (call once, typically in main())
WorldCreditBadge.configure(apiKey: 'your-api-key');

// Look up by email (recommended for integrations)
WCPillBadge(email: 'user@example.com')

// Or by World Credit handle
WCPillBadge(handle: 'ryannapp')
```

> **API key required.** Get yours at [world-credit.com](https://world-credit.com) — sign up for a plan under [Pricing](https://world-credit.com/#pricing).

## Badge Widgets

### WCInlineBadge — sits next to usernames

```dart
Row(
  children: [
    Text('Sarah K.'),
    const SizedBox(width: 8),
    WCInlineBadge(email: 'sarah@example.com'),
  ],
)
```

### WCPillBadge — compact capsule

```dart
WCPillBadge(
  email: 'user@example.com',
  theme: WCBadgeTheme.light,
  size: WCBadgeSize.sm,
)
```

### WCCardBadge — rich sidebar display

```dart
WCCardBadge(email: 'user@example.com')
```

### WCShieldBadge — minimal checkmark

```dart
WCShieldBadge(email: 'user@example.com')
```

## Options

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `email` | `String?` | User email for lookup (recommended) | `null` |
| `handle` | `String` | World Credit handle | `''` |
| `theme` | `WCBadgeTheme` | `.dark` `.light` | auto-detect |
| `size` | `WCBadgeSize` | `.xs` `.sm` `.md` `.lg` `.xl` | `.md` |

> **Tip:** Use `email` for B2B integrations — your platform already knows your users' emails. No need to know their World Credit handle.

## Themes

```dart
// Dark theme — for dark backgrounds
WCPillBadge(email: 'user@example.com', theme: WCBadgeTheme.dark)

// Light theme — for white/light backgrounds
WCPillBadge(email: 'user@example.com', theme: WCBadgeTheme.light)

// Auto-detect from app theme (default)
WCPillBadge(email: 'user@example.com')
```

## Programmatic Fetch

```dart
// Fetch by email
final data = await WorldCreditBadge.fetch('', email: 'user@example.com');

// Or by handle
final data = await WorldCreditBadge.fetch('ryannapp');

print(data.verified);    // true
print(data.worldScore);  // 52
print(data.tier);        // "Gold"
print(data.tierColor);   // "#FFD700"
print(data.categories);  // [{label: "Reliability", score: 60}, ...]
```

## Unverified Badges

When a user doesn't have a World Credit account, all badges automatically render an **unverified state** — no extra code needed.

| Style | Unverified Behavior |
|-------|-------------------|
| `WCInlineBadge` | Shows "Not Verified" in muted gray |
| `WCPillBadge` | Shows "—" score with "NOT VERIFIED" tag |
| `WCCardBadge` | Shows "Not Verified" with "GET VERIFIED →" CTA |
| `WCShieldBadge` | Shows "?" instead of checkmark |

Tapping an unverified badge takes the user to sign up for World Credit. Once they verify, the badge automatically shows their real score.

```dart
// Works for both verified and unverified users — no special handling needed
WCPillBadge(email: 'anyone@example.com')

// Check programmatically
final data = await WorldCreditBadge.fetch('', email: 'user@example.com');
if (!data.verified) {
  // User hasn't signed up yet — badge shows unverified state
}
```

## Trust Tiers

| Tier | Score | Color |
|------|-------|-------|
| Bronze | 1 – 19 | `#CD7F32` |
| Silver | 20 – 49 | `#C0C0C0` |
| Gold | 50 – 79 | `#FFD700` |
| Platinum | 80 – 100 | `#00FFC8` |

## Features

- **Email lookup** — Look up users by email, no handle needed
- **Auto-caching** — API responses cached in-memory with TTL
- **Loading states** — Subtle shimmer placeholder while fetching
- **Error handling** — Fails silently, never breaks host app UI
- **Tap to profile** — Badges open public profile via `url_launcher`
- **Self-contained** — Pass an email or handle, widget handles everything
- **Cross-platform** — iOS, Android, Web, macOS, Windows, Linux

## Requirements

- Flutter >= 3.0
- Dart >= 3.0

## Links

- [SDK Documentation](https://world-credit.com/sdk/)
- [Get API Key](https://world-credit.com/#pricing)
- [pub.dev Package](https://pub.dev/packages/worldcredit_badge)

## License

MIT — see [LICENSE](./LICENSE)
