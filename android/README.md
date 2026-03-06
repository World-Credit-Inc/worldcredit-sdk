# World Credit Badge SDK — Android

Jetpack Compose library for embedding verified World Credit trust badges in Android apps.

[![JitPack](https://jitpack.io/v/World-Credit-Inc/worldcredit-sdk.svg)](https://jitpack.io/#World-Credit-Inc/worldcredit-sdk)

## Installation

Add JitPack repository and dependency:

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        maven { url = uri("https://jitpack.io") }
    }
}

// build.gradle.kts (app)
dependencies {
    implementation("com.github.World-Credit-Inc:worldcredit-sdk:v1.2.2")
}
```

## Quick Start

```kotlin
import com.worldcredit.badge.ui.*

// Initialize with your API key (call once, in Application.onCreate)
WorldCredit.configure(apiKey = "your-api-key")

// Look up by email (recommended for integrations)
PillBadge(email = "user@example.com")

// Or by World Credit handle
PillBadge(handle = "johndoe12")
```

> **API key required.** Get yours at [world-credit.com/#pricing](https://world-credit.com/#pricing)

## Badge Types

### InlineBadge — next to usernames
```kotlin
Row(verticalAlignment = Alignment.CenterVertically) {
    Text("Sarah K.")
    Spacer(modifier = Modifier.width(8.dp))
    InlineBadge(email = "sarah@example.com")
}
```

### PillBadge — compact capsule
```kotlin
PillBadge(email = "user@example.com", theme = BadgeTheme.Light, size = BadgeSize.Small)
```

### CardBadge — rich display
```kotlin
CardBadge(email = "user@example.com")
```

### ShieldBadge — minimal checkmark
```kotlin
ShieldBadge(email = "user@example.com")
```

## Options

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `email` | `String?` | User email for lookup (recommended) | `null` |
| `handle` | `String` | World Credit handle | `""` |
| `theme` | `BadgeTheme` | `.Light` `.Dark` | auto |
| `size` | `BadgeSize` | `.Small` `.Medium` `.Large` | `.Medium` |

## Programmatic Fetch

```kotlin
// Fetch by email
val data = WorldCreditBadge.fetch(email = "user@example.com")

// Or by handle
val data = WorldCreditBadge.fetch(handle = "johndoe12")

println(data.verified)     // true
println(data.worldScore)   // 52
println(data.tier)         // "Gold"
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

- Min SDK 24
- Jetpack Compose
- Kotlin 1.9+

## Other Platforms

- **iOS** — [Swift Package Manager](https://github.com/World-Credit-Inc/worldcredit-sdk)
- **Web** — [npm: worldcredit-badge](https://www.npmjs.com/package/worldcredit-badge)
- **Flutter** — [pub.dev: worldcredit_badge](https://pub.dev/packages/worldcredit_badge)

## Links

- [SDK Documentation](https://world-credit.com/sdk/)
- [Get API Key](https://world-credit.com/#pricing)

## License

MIT — © 2026 World Credit Inc.
