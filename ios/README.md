# WorldCreditBadge iOS SDK

A SwiftUI package for displaying World Credit trust badges in iOS applications.

## Installation

### Swift Package Manager

1. In Xcode, select your project
2. Go to **Package Dependencies** tab
3. Click the **+** button
4. Enter the repository URL: `https://github.com/your-org/worldcredit-badge-ios`
5. Choose **Up to Next Major Version** and click **Add Package**

### Manual Installation

1. Download or clone this repository
2. Drag the `WorldCreditBadge` folder into your Xcode project
3. Make sure **Copy items if needed** is checked

## Requirements

- iOS 15.0+
- SwiftUI
- Xcode 13+

## Quick Start

Import the package, configure your API key, and start using badges:

```swift
import SwiftUI
import WorldCreditBadge

// Initialize with your API key (call once, typically in AppDelegate or @main App)
WorldCreditBadge.configure(apiKey: "your-api-key")

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Simple inline badge
            HStack {
                Text("@janedoe")
                InlineBadge(handle: "janedoe")
            }
            
            // Compact pill badge
            PillBadge(handle: "janedoe", size: .md)
            
            // Rich card badge
            CardBadge(handle: "janedoe", width: 200)
            
            // Minimal shield badge
            ShieldBadge(handle: "janedoe", size: .lg)
        }
        .padding()
    }
}
```

## Badge Types

### 🏷️ InlineBadge
Tiny pill that sits inline next to text: **[WC logo] 52 · Gold**

```swift
// Basic usage
InlineBadge(handle: "janedoe")

// With customization
InlineBadge(handle: "janedoe", theme: .dark, size: .sm)
```

**Use cases:** Next to usernames, in lists, comments, mentions

### 💊 PillBadge  
Compact capsule with logo, score, and tier tag

```swift
// Basic usage
PillBadge(handle: "janedoe")

// Customized
PillBadge(handle: "janedoe", theme: .light, size: .lg, showTierTag: false)
```

**Use cases:** Profile headers, sidebar widgets, user cards

### 📋 CardBadge
Rich card showing full trust information

```swift
// Basic usage
CardBadge(handle: "janedoe")

// Fixed width, minimal info
CardBadge(handle: "janedoe", width: 180, showUserInfo: false)
```

**Use cases:** Profile sidebars, detailed user views, trust dashboards

### 🛡️ ShieldBadge
Minimal shield with logo and colored checkmark

```swift
// Basic usage
ShieldBadge(handle: "janedoe")

// Verification badge (always green)
ShieldBadge.verification(handle: "janedoe", size: .lg)

// Minimal version (no checkmark)
ShieldBadge.minimal(handle: "janedoe")
```

**Use cases:** Verification indicators, compact trust displays, avatars

## Themes

Three built-in themes adapt to your app's design:

```swift
// Automatic (follows system appearance)
InlineBadge(handle: "janedoe", theme: .automatic)

// Light theme
PillBadge(handle: "janedoe", theme: .light)

// Dark theme
CardBadge(handle: "janedoe", theme: .dark)
```

### Custom Themes

Create your own theme:

```swift
let customTheme = BadgeTheme(
    backgroundColor: .blue,
    textColor: .white,
    secondaryTextColor: .gray,
    borderColor: .clear,
    shadowColor: .black.opacity(0.2),
    cornerRadius: 12,
    borderWidth: 0
)

PillBadge(handle: "janedoe", theme: customTheme)
```

## Sizes

Five badge sizes available:

```swift
enum BadgeSize: CGFloat {
    case xs = 16    // Extra small
    case sm = 20    // Small  
    case md = 24    // Medium (default)
    case lg = 32    // Large
    case xl = 40    // Extra large
}
```

## Data Management

### Async/Await API

```swift
import WorldCreditBadge

// Fetch badge data
do {
    let badgeData = try await WorldCreditBadge.fetch(handle: "janedoe")
    print("Score: \(badgeData.worldScore), Tier: \(badgeData.tierType.rawValue)")
} catch {
    print("Error: \(error)")
}
```

### Completion Handler API

```swift
WorldCreditBadge.fetch(handle: "janedoe") { result in
    switch result {
    case .success(let badgeData):
        print("Score: \(badgeData.worldScore)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Pre-fetched Data

For better performance, pre-fetch and reuse data:

```swift
struct UserProfileView: View {
    @State private var badgeData: BadgeData?
    
    var body: some View {
        VStack {
            if let badgeData = badgeData {
                // Use pre-fetched data
                CardBadge(badgeData: badgeData)
                PillBadge(badgeData: badgeData)
                ShieldBadge(badgeData: badgeData)
            }
        }
        .task {
            do {
                badgeData = try await WorldCreditBadge.fetch(handle: "janedoe")
            } catch {
                print("Failed to load badge: \(error)")
            }
        }
    }
}
```

### Observable Data Model

For reactive UI updates:

```swift
struct ProfileView: View {
    @BadgeStore("janedoe") var badge
    
    var body: some View {
        VStack {
            if badge.isLoading {
                ProgressView("Loading trust score...")
            } else if let error = badge.error {
                Text("Error: \(error.localizedDescription)")
            } else if let badgeData = badge.badgeData {
                CardBadge(badgeData: badgeData)
                    .onTapGesture {
                        badge.openProfile()
                    }
            }
        }
        .onAppear {
            badge.loadData()
        }
    }
}
```

## Caching & Performance

The SDK automatically caches:
- ✅ Badge data (per handle)
- ✅ World Credit logo image
- ✅ Loading states

```swift
// Check cache status
if WorldCreditBadge.isCached(handle: "janedoe") {
    let cached = WorldCreditBadge.getCached(handle: "janedoe")
}

// Preload multiple badges
await WorldCreditBadge.preload(handles: ["user1", "user2", "user3"])

// Clear all caches
WorldCreditBadge.clearCache()
```

## Trust Tiers

World Credit uses a 0-100 scoring system with five tiers:

| Tier | Score Range | Color | Description |
|------|-------------|--------|-------------|
| 🔘 **Unrated** | 0 | Gray (#4A5568) | No score available |
| 🥉 **Bronze** | 1-19 | Bronze (#CD7F32) | Low trust score |
| 🥈 **Silver** | 20-49 | Silver (#C0C0C0) | Moderate trust |
| 🥇 **Gold** | 50-79 | Gold (#FFD700) | High trust |
| 💎 **Platinum** | 80+ | Cyan (#00FFC8) | Exceptional trust |

## Interaction

All badges are automatically tappable and open the user's World Credit profile:

```swift
// Badges automatically open profiles on tap
CardBadge(handle: "janedoe") // Tap opens https://worldcredit.app/janedoe

// Manual profile opening
let badgeData = try await WorldCreditBadge.fetch(handle: "janedoe")
badgeData.openProfile()
```

## Error Handling

The SDK handles common error scenarios gracefully:

```swift
enum BadgeError: Error {
    case invalidHandle      // Empty or invalid handle
    case invalidURL        // Malformed API URL
    case networkError(Error) // Network connectivity issues
    case decodingError(Error) // Invalid JSON response
    case noData           // Empty response
    case invalidResponse  // Non-200 HTTP status
}
```

Badges show appropriate loading and error states automatically.

## Examples

### User List with Badges

```swift
struct UserListView: View {
    let users = ["janedoe", "alexchen", "sarah_k"]
    
    var body: some View {
        List(users, id: \.self) { handle in
            HStack {
                AsyncImage(url: profileImageURL(for: handle)) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("@\(handle)")
                        .font(.headline)
                    
                    HStack {
                        InlineBadge(handle: handle, size: .sm)
                        Spacer()
                    }
                }
                
                Spacer()
                
                ShieldBadge(handle: handle, size: .md)
            }
            .padding(.vertical, 4)
        }
    }
}
```

### Trust Dashboard

```swift
struct TrustDashboardView: View {
    let handle: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Main trust card
                CardBadge(handle: handle, width: 300)
                
                // Quick badges row
                HStack(spacing: 12) {
                    PillBadge(handle: handle, size: .sm)
                    ShieldBadge.verification(handle: handle, size: .lg)
                    Spacer()
                }
                
                // Additional info...
            }
            .padding()
        }
        .navigationTitle("Trust Profile")
    }
}
```

## API Reference

The World Credit Badge API returns:

```json
{
    "ok": true,
    "handle": "janedoe",
    "displayName": "Jane Doe",
    "worldScore": 72,
    "tier": "Gold", 
    "tierColor": "#FFD700",
    "photoUrl": "https://...",
    "linkedNetworks": ["twitter", "linkedin"],
    "profileUrl": "https://worldcredit.app/janedoe",
    "categories": ["tech", "finance"]
}
```

## Support

- 📧 Email: support@worldcredit.app
- 🌐 Website: https://worldcredit.app
- 📖 API Docs: https://docs.worldcredit.app

## License

This SDK is available under the MIT license. See the LICENSE file for more info.