# World Credit Badge SDK — Flutter

Embed verified trust badges in any Flutter app. Supports all platforms (iOS, Android, Web, macOS, Windows, Linux).

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

// Drop any badge into your widget tree
WCInlineBadge(handle: 'handle')
```

> **API key required.** Get yours at [world-credit.com](https://world-credit.com) — sign up for a plan under [Pricing](https://world-credit.com/#pricing).

## Badge Widgets

### WCInlineBadge — sits next to usernames

```dart
Row(
  children: [
    Text('Sarah K.'),
    const SizedBox(width: 8),
    WCInlineBadge(handle: 'handle'),
  ],
)
```

### WCPillBadge — compact capsule

```dart
WCPillBadge(
  handle: 'handle',
  theme: WCBadgeTheme.light,
  size: WCBadgeSize.sm,
)
```

### WCCardBadge — rich sidebar display

```dart
WCCardBadge(handle: 'handle')
```

### WCShieldBadge — minimal checkmark

```dart
WCShieldBadge(handle: 'handle')
```

## Options

| Parameter | Type | Values | Default |
|-----------|------|--------|---------|
| `handle` | `String` | User handle | Required |
| `theme` | `WCBadgeTheme` | `.dark` `.light` | `.dark` |
| `size` | `WCBadgeSize` | `.sm` `.md` `.lg` | `.md` |

## Themes

```dart
// Dark theme (default) — for dark backgrounds
WCPillBadge(handle: 'handle', theme: WCBadgeTheme.dark)

// Light theme — for white/light backgrounds
WCPillBadge(handle: 'handle', theme: WCBadgeTheme.light)
```

## Programmatic Fetch

```dart
// Fetch badge data directly
final data = await WorldCreditBadge.fetch('handle');

print(data.worldScore);  // 87
print(data.tier);        // "Platinum"
print(data.tierColor);   // "#00FFC8"
print(data.categories);  // [{label: "Reliability", score: 92}, ...]
```

## Email-Based Lookup (Recommended for B2B)

Companies integrating the SDK can look up users by **email** instead of World Credit handle — your platform already knows your users' emails.

```dart
// Look up by email (recommended)
WCInlineBadge(email: 'user@example.com')
WCPillBadge(email: 'user@example.com')

// Or by World Credit handle
WCInlineBadge(handle: 'ryannapp')

// Programmatic fetch by email
final data = await WorldCreditBadge.fetch('', email: 'user@example.com');
print(data.verified); // true if user has a World Credit account
```

## Unverified Badges

When a user doesn't have a World Credit account, all badges automatically render an **unverified state** — no extra code needed.

| Style | Unverified Behavior |
|-------|-------------------|
| `WCInlineBadge` | Shows "Not Verified" in muted gray |
| `WCPillBadge` | Shows "—" score with "NOT VERIFIED" tag |
| `WCCardBadge` | Shows "Not Verified" with "GET VERIFIED →" CTA |
| `WCShieldBadge` | Shows "?" instead of checkmark |

Tapping an unverified badge takes the user to `world-credit.com/signup`. Once they sign up and verify, the badge automatically shows their real score.

```dart
// This works for both verified and unverified users — no special handling needed
WCInlineBadge(handle: 'any-handle')

// Check programmatically
final data = await WorldCreditBadge.fetch('handle');
if (!data.verified) {
  // User hasn't signed up yet
}
```

## Features

- **Auto-caching** — API responses cached in-memory with TTL
- **Loading states** — Subtle placeholder while fetching
- **Error handling** — Fails silently, never breaks host app UI
- **Tap to profile** — Badges open public profile via `url_launcher`
- **Self-contained** — Just pass a handle string, widget handles everything
- **Cross-platform** — Works on iOS, Android, Web, macOS, Windows, Linux

## Dependencies

- `http` — API calls
- `cached_network_image` — Logo caching
- `url_launcher` — Profile link tap handling

## Requirements

- Flutter >= 3.0
- Dart >= 3.0

## Trust Tiers

| Tier | Score | Color |
|------|-------|-------|
| Bronze | 1 – 19 | `#CD7F32` |
| Silver | 20 – 49 | `#C0C0C0` |
| Gold | 50 – 79 | `#FFD700` |
| Platinum | 80 – 100 | `#00FFC8` |

## Example App

See the full example app in [`example/`](./example/) showing all badge variants.

## Live Demo

See badge styles in action: [world-credit.com/sdk](https://world-credit.com/sdk/)

## License

© 2026 World Credit Inc. All Rights Reserved.
