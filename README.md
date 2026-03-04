# World Credit Trust Badge SDK

Embed verified trust scores anywhere — websites, mobile apps, marketplaces.

## SDKs

| Platform | Status | Location |
|----------|--------|----------|
| JavaScript (Web) | ✅ Ready | [`js/`](./js/) |
| iOS (Swift) | ✅ Ready | [`ios/`](./ios/) |
| Android (Kotlin) | ✅ Ready | [`android/`](./android/) |
| Flutter | ✅ Ready | [`flutter/`](./flutter/) |

## Badge Styles

Every SDK supports 4 badge styles:

| Style | Use Case |
|-------|----------|
| `inline` | Compact pill that sits next to a username |
| `pill` | Logo + score + tier in a capsule |
| `card` | Rich display for profile sidebars |
| `shield` | Minimal logo + verified checkmark |

All badges support **dark/light themes** and **sm/md/lg sizes**.

---

## Quick Start — Web

```html
<div data-worldcredit="handle" data-style="inline"></div>
<script src="https://world-credit.com/sdk/badge.js"></script>
```

## Quick Start — iOS (Swift Package)

Add via SPM: `https://github.com/World-Credit-Inc/worldcredit-sdk`

```swift
import WorldCreditBadge

InlineBadge(handle: "handle")
PillBadge(handle: "handle", theme: .light, size: .sm)
CardBadge(handle: "handle")
ShieldBadge(handle: "handle")
```

## Quick Start — Android (Jetpack Compose)

```kotlin
import com.worldcredit.badge.ui.*

InlineBadge(handle = "handle")
PillBadge(handle = "handle", theme = BadgeTheme.Light, size = BadgeSize.Small)
CardBadge(handle = "handle")
ShieldBadge(handle = "handle")
```

## Quick Start — Flutter

```yaml
# pubspec.yaml
dependencies:
  worldcredit_badge: ^1.0.0
```

```dart
import 'package:worldcredit_badge/worldcredit_badge.dart';

WCInlineBadge(handle: 'handle')
WCPillBadge(handle: 'handle', theme: WCBadgeTheme.light, size: WCBadgeSize.sm)
WCCardBadge(handle: 'handle')
WCShieldBadge(handle: 'handle')
```

## Options

| Option | Values | Default |
|--------|--------|---------|
| Style | `inline` `pill` `card` `shield` | `inline` |
| Theme | `dark` `light` | `dark` |
| Size | `sm` `md` `lg` | `md` |

## Badge API

All SDKs use the same REST API:

```
GET https://world-credit.com/api/badge?handle=handle
```

```json
{
  "ok": true,
  "handle": "handle",
  "displayName": "Sarah K.",
  "worldScore": 87,
  "tier": "Platinum",
  "tierColor": "#00FFC8",
  "linkedNetworks": 10,
  "profileUrl": "https://world-credit.com/profile?handle=handle",
  "categories": [
    { "label": "Reliability", "score": 92 },
    { "label": "Financial Integrity", "score": 85 },
    { "label": "Social Proof", "score": 88 }
  ]
}
```

## Trust Tiers

| Tier | Score | Color |
|------|-------|-------|
| Bronze | 1 – 19 | `#CD7F32` |
| Silver | 20 – 49 | `#C0C0C0` |
| Gold | 50 – 79 | `#FFD700` |
| Platinum | 80 – 100 | `#00FFC8` |

## License

© 2025 World Credit Inc. All Rights Reserved.
