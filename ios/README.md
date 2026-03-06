# WorldCreditBadge iOS SDK

A SwiftUI package for embedding verified World Credit trust badges in iOS apps.

## Installation

### Swift Package Manager

1. In Xcode → **Package Dependencies** → **+**
2. Enter: `https://github.com/World-Credit-Inc/worldcredit-sdk`
3. Choose **Up to Next Major Version** → **Add Package**

## Quick Start

```swift
import WorldCreditBadge

// Initialize with your API key (call once, in AppDelegate or @main App)
WorldCreditBadge.configure(apiKey: "your-api-key")

// Look up by email (recommended for integrations)
PillBadge(email: "user@example.com")

// Or by World Credit handle
PillBadge(handle: "johndoe12")
```

> **API key required.** Get yours at [world-credit.com/#pricing](https://world-credit.com/#pricing)

## Badge Types

### InlineBadge — next to usernames
```swift
HStack {
    Text("Sarah K.")
    InlineBadge(email: "sarah@example.com")
}
```

### PillBadge — compact capsule
```swift
PillBadge(email: "user@example.com", theme: .light, size: .sm)
```

### CardBadge — rich display
```swift
CardBadge(email: "user@example.com")
```

### ShieldBadge — minimal checkmark
```swift
ShieldBadge(email: "user@example.com")
```

## Options

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `email` | `String?` | User email for lookup (recommended) | `nil` |
| `handle` | `String` | World Credit handle | `""` |
| `theme` | `BadgeTheme` | `.dark` `.light` | auto |
| `size` | `BadgeSize` | `.xs` `.sm` `.md` `.lg` `.xl` | `.md` |

## Programmatic Fetch

```swift
// Fetch by email
let data = try await WorldCreditBadge.fetch(email: "user@example.com")

// Or by handle
let data = try await WorldCreditBadge.fetch(handle: "johndoe12")

print(data.verified)     // true
print(data.worldScore)   // 52
print(data.tier)         // "Gold"
```

## Unverified Badges

When a user doesn't have a World Credit account, badges automatically render an unverified state. No special handling needed.

| Style | Unverified Behavior |
|-------|-------------------|
| `InlineBadge` | "Not Verified" in muted gray |
| `PillBadge` | "—" score with "NOT VERIFIED" tag |
| `CardBadge` | "Not Verified" with "GET VERIFIED →" CTA |
| `ShieldBadge` | "?" instead of checkmark |

## Trust Tiers

| Tier | Score | Color |
|------|-------|-------|
| Bronze | 1 – 19 | `#CD7F32` |
| Silver | 20 – 49 | `#C0C0C0` |
| Gold | 50 – 79 | `#FFD700` |
| Platinum | 80 – 100 | `#00FFC8` |

## Requirements

- iOS 15.0+
- SwiftUI
- Xcode 15+

## Other Platforms

- **Web** — [npm: worldcredit-badge](https://www.npmjs.com/package/worldcredit-badge)
- **Android** — [JitPack](https://jitpack.io/#World-Credit-Inc/worldcredit-sdk)
- **Flutter** — [pub.dev: worldcredit_badge](https://pub.dev/packages/worldcredit_badge)

## Links

- [SDK Documentation](https://world-credit.com/sdk/)
- [Get API Key](https://world-credit.com/#pricing)

## License

MIT — © 2026 World Credit Inc.
