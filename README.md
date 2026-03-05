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

// Drop badges into any SwiftUI view
InlineBadge(handle: "handle")
PillBadge(handle: "handle", theme: .light, size: .sm)
CardBadge(handle: "handle")
ShieldBadge(handle: "handle")

// Programmatic fetch
let data = try await WorldCreditBadge.fetch(handle: "handle")
print(data.worldScore)  // 87
print(data.tier)        // "Platinum"
```

## Badge Styles

| Style | Use Case |
|-------|----------|
| `InlineBadge` | Compact pill next to usernames |
| `PillBadge` | Logo + score + tier capsule |
| `CardBadge` | Rich display for profile sidebars |
| `ShieldBadge` | Minimal logo + verified checkmark |

All badges support **dark/light themes** and **sm/md/lg sizes**.

## Email-Based Lookup (Recommended for B2B)

```swift
// Look up by email — no need to know World Credit handles
InlineBadge(email: "user@example.com")
```

## Unverified Badges

When a handle doesn't have a World Credit account, badges render in a grayed-out **unverified state** — "Not Verified" text, "?" checkmarks, and a CTA linking to signup. No special handling needed.

```swift
// Works for any handle — verified or not
InlineBadge(handle: "any-handle")

// Check programmatically
let data = try await WorldCreditBadge.fetch(handle: "handle")
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

## Get API Key

Sign up at [world-credit.com](https://world-credit.com)

## Docs

[world-credit.com/sdk](https://world-credit.com/sdk/)

## License

MIT — © 2025 World Credit Inc.
