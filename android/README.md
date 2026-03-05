# World Credit Badge SDK for Android

A Jetpack Compose library for displaying World Credit trust score badges in Android applications.

[![Min SDK](https://img.shields.io/badge/Min%20SDK-24-brightgreen.svg)]()
[![Target SDK](https://img.shields.io/badge/Target%20SDK-34-blue.svg)]()
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9+-purple.svg)]()
[![Compose](https://img.shields.io/badge/Compose-2024.02.00-orange.svg)]()

## Overview

World Credit is a trust scoring platform that provides user trust data through a Badge API. This SDK makes it easy to integrate World Credit badges into your Android app with multiple display styles and automatic theming.

## Features

- **4 Badge Styles**: Inline, Pill, Card, and Shield badges
- **Automatic Theming**: Light/Dark theme support with tier-based colors
- **Loading States**: Built-in loading and error handling
- **Caching**: Automatic API response caching
- **Chrome Custom Tabs**: Opens profiles with custom tabs for better UX
- **Minimal Dependencies**: Uses only essential libraries (Compose + Coil)

## Installation

Add this library to your Android project:

### 1. Add to your module's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.worldcredit:badge-sdk:1.0.0")
    
    // Required dependencies (if not already in your project)
    implementation(platform("androidx.compose:compose-bom:2024.02.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("io.coil-kt:coil-compose:2.5.0")
    implementation("androidx.browser:browser:1.8.0")
}
```

### 2. Add internet permission to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Badge Styles

### 1. InlineBadge
Tiny pill that sits inline next to text: `[WC logo] 52 · Gold`

```kotlin
@Composable
fun UserProfile() {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text("Sarah K.")
        Spacer(modifier = Modifier.width(8.dp))
        InlineBadge(handle = "sarahk")
    }
}
```

### 2. PillBadge  
Compact capsule with logo, score, and tier tag

```kotlin
@Composable
fun UserCard() {
    PillBadge(
        handle = "janedoe",
        theme = BadgeTheme.Light,
        size = BadgeSize.Small
    )
}
```

### 3. CardBadge
Rich sidebar card with logo, "World Credit" label, large score, and tier

```kotlin
@Composable
fun ProfileSidebar() {
    CardBadge(handle = "alexb")
}
```

### 4. ShieldBadge
Minimal: just logo + colored checkmark dot

```kotlin
@Composable 
fun UserList() {
    LazyColumn {
        items(users) { user ->
            Row {
                Text(user.name)
                Spacer(modifier = Modifier.weight(1f))
                ShieldBadge(handle = user.handle)
            }
        }
    }
}
```

## Unverified Badges

When a user doesn't have a World Credit account, all badges automatically render an **unverified state**:

| Style | Unverified Behavior |
|-------|-------------------|
| `InlineBadge` | Shows "Not Verified" in muted gray |
| `PillBadge` | Shows "—" score with "NOT VERIFIED" tag |
| `CardBadge` | Shows "Not Verified" with "GET VERIFIED →" CTA |
| `ShieldBadge` | Shows "?" instead of checkmark |

Tapping an unverified badge takes the user to `world-credit.com/signup`. No special handling needed — just pass any handle.

```kotlin
// Works for both verified and unverified users
InlineBadge(handle = "any-handle")

// Check programmatically
WorldCreditBadge.fetch("handle") { result ->
    when (result) {
        is BadgeResult.Success -> {
            if (!result.data.verified) {
                // User hasn't signed up yet
            }
        }
    }
}
```

## API Reference

### Basic Usage

```kotlin
// Initialize with your API key (call once, typically in Application.onCreate)
WorldCreditBadge.configure(apiKey = "your-api-key")

// Simple Compose usage
InlineBadge(handle = "janedoe")
PillBadge(handle = "janedoe", theme = BadgeTheme.Dark, size = BadgeSize.Large)
CardBadge(handle = "janedoe")
ShieldBadge(handle = "janedoe")

// Programmatic fetch
WorldCreditBadge.fetch("janedoe") { result ->
    when (result) {
        is BadgeResult.Success -> {
            val badgeData = result.data
            println("Score: ${badgeData.worldScore}, Tier: ${badgeData.tier}")
        }
        is BadgeResult.Error -> {
            println("Error: ${result.message}")
        }
    }
}

// Suspend function
val result = WorldCreditBadge.fetchSuspend("janedoe")
```

### Themes and Sizing

```kotlin
// Theme options
BadgeTheme.LIGHT   // Light theme
BadgeTheme.DARK    // Dark theme  
BadgeTheme.AUTO    // Follow system theme

// Size options
BadgeSize.SMALL    // 0.8x scale
BadgeSize.MEDIUM   // 1.0x scale (default)
BadgeSize.LARGE    // 1.2x scale

// Example with custom theme and size
PillBadge(
    handle = "sarahk",
    theme = BadgeTheme.DARK,
    size = BadgeSize.LARGE
)
```

### Advanced Usage

```kotlin
// Custom state management
@Composable
fun CustomBadge(handle: String) {
    val badgeState = rememberBadgeState(handle)
    
    when (badgeState) {
        is BadgeState.Loading -> {
            CircularProgressIndicator()
        }
        is BadgeState.Success -> {
            val data = badgeState.data
            Text("${data.displayName} has score ${data.worldScore}")
            PillBadge(state = badgeState)
        }
        is BadgeState.Error -> {
            Text("Failed to load badge: ${badgeState.message}")
        }
    }
}

// Opening profiles programmatically  
val context = LocalContext.current
WorldCreditBadge.openProfile(context, badgeData)
// or
WorldCreditBadge.openProfile(context, "https://worldcredit.com/profile/janedoe")

// Cache management
WorldCreditBadge.clearCache()
val cacheSize = WorldCreditBadge.getCacheSize()

// Handle validation
val isValid = WorldCreditBadge.isValidHandle("janedoe") // true
val isInvalid = WorldCreditBadge.isValidHandle("a") // false (too short)
```

## Data Models

### BadgeData
```kotlin
data class BadgeData(
    val ok: Boolean,
    val handle: String,
    val displayName: String,
    val worldScore: Int,
    val tier: String,
    val tierColor: String,
    val photoUrl: String?,
    val linkedNetworks: List<String>,
    val profileUrl: String,
    val categories: List<String>
)
```

### Tier System
- **Platinum** (#00FFC8): 80+ points
- **Gold** (#FFD700): 50-79 points  
- **Silver** (#C0C0C0): 20-49 points
- **Bronze** (#CD7F32): 1-19 points
- **Unrated** (#4A5568): 0 points

### Badge States
```kotlin
sealed class BadgeState {
    object Loading : BadgeState()
    data class Success(val data: BadgeData) : BadgeState()
    data class Error(val message: String) : BadgeState()
}
```

## Examples

### User Profile Integration
```kotlin
@Composable
fun ProfileHeader(user: User) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            AsyncImage(
                model = user.photoUrl,
                contentDescription = null,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
            )
            
            Spacer(modifier = Modifier.width(12.dp))
            
            Column {
                Text(
                    text = user.displayName,
                    style = MaterialTheme.typography.headlineSmall
                )
                
                InlineBadge(handle = user.handle)
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Profile sidebar with detailed badge
        CardBadge(handle = user.handle)
    }
}
```

### Social Feed Integration
```kotlin
@Composable
fun FeedItem(post: Post) {
    Card {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = post.authorName,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold
                )
                
                Spacer(modifier = Modifier.width(8.dp))
                
                // Small inline badge next to username
                InlineBadge(
                    handle = post.authorHandle,
                    size = BadgeSize.SMALL
                )
                
                Spacer(modifier = Modifier.weight(1f))
                
                Text(
                    text = post.timestamp,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(text = post.content)
        }
    }
}
```

### User List with Shields
```kotlin
@Composable
fun TeamMembers(members: List<TeamMember>) {
    LazyColumn {
        items(members) { member ->
            ListItem(
                headlineContent = { Text(member.name) },
                supportingContent = { Text(member.role) },
                leadingContent = {
                    AsyncImage(
                        model = member.photoUrl,
                        contentDescription = null,
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                    )
                },
                trailingContent = {
                    ShieldBadge(handle = member.handle)
                }
            )
        }
    }
}
```

## Error Handling

The SDK includes comprehensive error handling:

```kotlin
@Composable
fun RobustBadgeDisplay(handle: String) {
    val badgeState = rememberBadgeState(handle)
    
    when (badgeState) {
        is BadgeState.Loading -> {
            // Show loading state
            InlineBadge(state = badgeState)
        }
        is BadgeState.Success -> {
            // Show badge normally
            InlineBadge(state = badgeState)
        }
        is BadgeState.Error -> {
            // Handle different error types
            when {
                badgeState.message.contains("Network") -> {
                    Text("Check your connection")
                }
                badgeState.message.contains("Invalid handle") -> {
                    Text("User not found")
                }
                else -> {
                    // Show error badge or fallback
                    InlineBadge(state = badgeState)
                }
            }
        }
    }
}
```

## Performance Tips

1. **Use caching**: The SDK automatically caches API responses
2. **Lazy loading**: Use with `LazyColumn`/`LazyRow` for large lists  
3. **Size appropriately**: Use `BadgeSize.SMALL` in dense layouts
4. **Clear cache**: Call `WorldCreditBadge.clearCache()` during logout

## Privacy & Security

- Network requests are made over HTTPS
- No user data is stored permanently
- Cache can be cleared programmatically  
- Follows Android security best practices

## Troubleshooting

### Badge not loading
1. Check internet connectivity
2. Verify handle exists at `https://badgeapi-czne44luta-uc.a.run.app?handle=YOURHANDLE`
3. Clear cache: `WorldCreditBadge.clearCache()`

### Profile not opening
1. Ensure Chrome or default browser is available
2. Check if `profileUrl` in badge data is valid
3. Verify `androidx.browser:browser` dependency

### Theme not applying  
1. Ensure you're using `BadgeTheme.AUTO` for system theme
2. Check if parent composable has proper theme setup
3. Use `BadgeTheme.LIGHT` or `BadgeTheme.DARK` for explicit themes

## Dependencies

- **Jetpack Compose**: UI framework
- **Coil**: Image loading and caching  
- **Chrome Custom Tabs**: Better profile opening experience
- **Kotlin Coroutines**: Async operations

## License

This SDK is provided by World Credit. See LICENSE file for details.

## Support

For issues or questions:
- File issues on GitHub
- Email support: support@worldcredit.com
- Documentation: https://docs.worldcredit.com

---

**World Credit Badge SDK v1.0.0**  
Build trust, show credibility. 🛡️