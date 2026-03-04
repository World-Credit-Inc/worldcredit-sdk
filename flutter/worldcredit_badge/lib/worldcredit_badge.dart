/// World Credit Trust Badge SDK for Flutter
/// 
/// Embed verified trust scores in any app with beautiful, customizable badge widgets.
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:worldcredit_badge/worldcredit_badge.dart';
/// 
/// // Simple inline badge
/// WCInlineBadge(handle: 'demo')
/// 
/// // Compact pill badge
/// WCPillBadge(handle: 'demo', theme: WCBadgeTheme.light, size: WCBadgeSize.md)
/// 
/// // Rich card badge
/// WCCardBadge(handle: 'demo')
/// 
/// // Minimal shield badge
/// WCShieldBadge(handle: 'demo')
/// 
/// // Programmatic data fetching
/// final data = await WorldCreditBadge.fetch('demo');
/// ```
/// 
/// ## Badge Types
/// 
/// - **WCInlineBadge**: Tiny pill that sits inline next to text
/// - **WCPillBadge**: Compact capsule with logo, score, and tier tag
/// - **WCCardBadge**: Rich card with detailed badge information
/// - **WCShieldBadge**: Minimal logo with colored verification dot
/// 
/// ## Theming
/// 
/// All badges support light/dark themes and custom styling:
/// 
/// ```dart
/// WCPillBadge(
///   handle: 'demo',
///   theme: WCBadgeTheme.dark,
///   size: WCBadgeSize.lg,
/// )
/// ```
/// 
/// ## Caching
/// 
/// The SDK automatically caches API responses for 5 minutes to improve performance.
/// Configure caching behavior:
/// 
/// ```dart
/// WorldCreditBadge.configureCaching(
///   duration: Duration(minutes: 10),
///   maxSize: 200,
/// );
/// ```
library worldcredit_badge;

// Core API and data models
export 'src/world_credit_badge.dart';
export 'src/badge_data.dart';
export 'src/badge_api.dart' show BadgeApiException;

// Theming
export 'src/badge_theme.dart';

// Widget exports
export 'src/widgets/inline_badge.dart';
export 'src/widgets/pill_badge.dart';
export 'src/widgets/card_badge.dart';
export 'src/widgets/shield_badge.dart' show WCShieldBadge, ShieldDotPosition;