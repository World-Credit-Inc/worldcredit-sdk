/// Theme configurations for World Credit badges
library;

import 'package:flutter/material.dart';

/// Available badge sizes
enum WCBadgeSize {
  xs(12.0, 8.0, 16.0),
  sm(14.0, 10.0, 20.0),
  md(16.0, 12.0, 24.0),
  lg(18.0, 14.0, 28.0),
  xl(20.0, 16.0, 32.0);

  const WCBadgeSize(this.fontSize, this.padding, this.iconSize);

  final double fontSize;
  final double padding;
  final double iconSize;
}

/// Badge theme configurations
class WCBadgeTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  final BorderRadius borderRadius;
  final double borderWidth;
  final bool isDark;

  const WCBadgeTheme._({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.isDark,
  });

  /// Light theme configuration
  static const WCBadgeTheme light = WCBadgeTheme._(
    backgroundColor: Colors.white,
    textColor: Color(0xFF1A202C),
    borderColor: Color(0xFFE2E8F0),
    shimmerBaseColor: Color(0xFFE2E8F0),
    shimmerHighlightColor: Color(0xFFF7FAFC),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderWidth: 1.0,
    isDark: false,
  );

  /// Dark theme configuration
  static const WCBadgeTheme dark = WCBadgeTheme._(
    backgroundColor: Color(0xFF0A1128),
    textColor: Color(0xFFF7FAFC),
    borderColor: Color(0xFF2D3748),
    shimmerBaseColor: Color(0xFF2D3748),
    shimmerHighlightColor: Color(0xFF4A5568),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderWidth: 1.0,
    isDark: true,
  );

  /// Auto theme that follows system brightness
  static WCBadgeTheme auto(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  /// Creates a custom theme
  static WCBadgeTheme custom({
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    BorderRadius? borderRadius,
    double? borderWidth,
    bool? isDark,
  }) {
    return WCBadgeTheme._(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor ?? const Color(0xFFE2E8F0),
      shimmerBaseColor: shimmerBaseColor ?? const Color(0xFFE2E8F0),
      shimmerHighlightColor: shimmerHighlightColor ?? const Color(0xFFF7FAFC),
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8.0)),
      borderWidth: borderWidth ?? 1.0,
      isDark: isDark ?? false,
    );
  }

  /// Gets the tier accent color with optional opacity
  Color getTierColor(Color tierColor, [double opacity = 1.0]) {
    return tierColor.withValues(alpha: opacity);
  }

  /// Gets a subtle tier background color
  Color getTierBackground(Color tierColor) {
    if (!isDark && tierColor.computeLuminance() > 0.5) {
      // Brighter tint for light-colored tiers so the pill is visible
      return tierColor.withValues(alpha: 0.2);
    }
    return tierColor.withValues(alpha: isDark ? 0.2 : 0.1);
  }

  /// Gets tier text color that contrasts well with the tier background
  /// Darkens light colors (like Gold #FFD700) in light mode for readability
  Color getTierTextColor(Color tierColor) {
    if (isDark) return tierColor.withValues(alpha: 0.9);
    // If the color is too bright for white background, darken it
    final luminance = tierColor.computeLuminance();
    if (luminance > 0.5) {
      // Darken bright colors (Gold, Silver, etc.) for light mode
      final hsl = HSLColor.fromColor(tierColor);
      return hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
    }
    return tierColor;
  }

  /// Common decoration for badge containers
  BoxDecoration get containerDecoration => BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Decoration for tier badges/pills
  BoxDecoration getTierDecoration(Color tierColor) => BoxDecoration(
        color: getTierBackground(tierColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getTierColor(tierColor, 0.3),
          width: 1,
        ),
      );

  /// Text style for main score display
  TextStyle getScoreTextStyle(WCBadgeSize size) => TextStyle(
        fontSize: size.fontSize * 1.2,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      );

  /// Text style for tier labels
  TextStyle getTierTextStyle(Color tierColor, WCBadgeSize size) => TextStyle(
        fontSize: size.fontSize * 0.8,
        fontWeight: FontWeight.w600,
        color: getTierTextColor(tierColor),
        height: 1.2,
      );

  /// Text style for secondary text (like display name)
  TextStyle getSecondaryTextStyle(WCBadgeSize size) => TextStyle(
        fontSize: size.fontSize * 0.9,
        fontWeight: FontWeight.w500,
        color: textColor.withValues(alpha: 0.7),
        height: 1.2,
      );
}

/// Predefined tier color constants for fallback
class WCTierColors {
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFF00FFC8);
  static const Color unrated = Color(0xFF4A5568);

  /// Gets the appropriate color for a tier name
  static Color fromTierName(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return bronze;
      case 'silver':
        return silver;
      case 'gold':
        return gold;
      case 'platinum':
        return platinum;
      default:
        return unrated;
    }
  }
}