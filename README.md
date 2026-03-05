# WorldCreditBadge

A SwiftUI SDK for embedding verified World Credit trust badges in iOS apps.

## Installation

Add via Swift Package Manager in Xcode:

```
https://github.com/World-Credit-Inc/worldcredit-sdk
```

## Quick Start

```swift
import WorldCreditBadge

// Initialize with your API key (call once, typically in AppDelegate or @main App)
WorldCreditBadge.configure(apiKey: "your-api-key")

// Look up by email (recommended for integrations)
InlineBadge(email: "user@example.com")
PillBadge(email: "user@example.com", theme: .light, size: .sm)
CardBadge(email: "user@example.com")
ShieldBadge(email: "user@example.com")

// Or by World Credit handle
PillBadge(handle: "ryannapp")

// Programmatic fetch
let data = try await WorldCreditBadge.fetch(email: "user@example.com")
print(data.worldScore)  // 52
print(data.tier)        // "Gold"
```

> **API key required.** Get yours at [world-credit.com/#pricing](https://world-credit.com/#pricing)

## Badge Styles

| Style | Use Case |
|-------|----------|
| `InlineBadge` | Compact pill next to usernames |
| `PillBadge` | Logo + score + tier capsule |
| `CardBadge` | Rich display for profile sidebars |
| `ShieldBadge` | Minimal logo + verified checkmark |

All badges support `email` or `handle` lookup, **dark/light themes**, and **sm/md/lg sizes**.

## Unverified Badges

When a user doesn't have a World Credit account, badges render in a grayed-out **unverified state** — "Not Verified" text, "?" checkmarks, and a CTA linking to signup. No special handling needed.

```swift
// Works for any email — verified or not
PillBadge(email: "anyone@example.com")

// Check programmatically
let data = try await WorldCreditBadge.fetch(email: "user@example.com")
print(data.verified) // false if no account
```

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
