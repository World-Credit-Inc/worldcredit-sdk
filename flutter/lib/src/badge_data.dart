/// Data models for World Credit badge information
library;

import 'dart:ui';

/// Represents the response from the World Credit Badge API
class BadgeData {
  final bool ok;
  final bool verified;
  final String handle;
  final String displayName;
  final int worldScore;
  final String tier;
  final String tierColor;
  final String? photoUrl;
  final List<String> linkedNetworks;
  final String profileUrl;
  final List<String> categories;

  /// The timestamp when this data was cached
  final DateTime cachedAt;

  /// Whether the user is unverified (no World Credit account)
  bool get isUnverified => !verified;

  const BadgeData({
    required this.ok,
    this.verified = true,
    required this.handle,
    required this.displayName,
    required this.worldScore,
    required this.tier,
    required this.tierColor,
    this.photoUrl,
    required this.linkedNetworks,
    required this.profileUrl,
    required this.categories,
    required this.cachedAt,
  });

  /// Creates a BadgeData from JSON response
  factory BadgeData.fromJson(Map<String, dynamic> json) {
    return BadgeData(
      ok: json['ok'] ?? false,
      verified: json['verified'] ?? true,
      handle: json['handle'] ?? '',
      displayName: json['displayName'] ?? '',
      worldScore: json['worldScore'] ?? 0,
      tier: json['tier'] ?? 'Unrated',
      tierColor: json['tierColor'] ?? '#4A5568',
      photoUrl: json['photoUrl'],
      linkedNetworks: List<String>.from(json['linkedNetworks'] ?? []),
      profileUrl: json['profileUrl'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      cachedAt: DateTime.now(),
    );
  }

  /// Creates a copy of this BadgeData with updated cache time
  BadgeData copyWith({DateTime? cachedAt}) {
    return BadgeData(
      ok: ok,
      verified: verified,
      handle: handle,
      displayName: displayName,
      worldScore: worldScore,
      tier: tier,
      tierColor: tierColor,
      photoUrl: photoUrl,
      linkedNetworks: linkedNetworks,
      profileUrl: profileUrl,
      categories: categories,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Gets the tier color as a Color object
  Color get tierColorAsColor {
    try {
      String colorStr = tierColor.startsWith('#') ? tierColor.substring(1) : tierColor;
      return Color(int.parse('FF$colorStr', radix: 16));
    } catch (e) {
      // Fallback to unrated color if parsing fails
      return const Color(0xFF4A5568);
    }
  }

  /// Whether this cached data is still fresh (within 5 minutes)
  bool get isFresh {
    return DateTime.now().difference(cachedAt).inMinutes < 5;
  }

  /// Returns a display-friendly tier name
  String get displayTier {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return 'Bronze';
      case 'silver':
        return 'Silver';
      case 'gold':
        return 'Gold';
      case 'platinum':
        return 'Platinum';
      case 'unverified':
        return 'Not Verified';
      default:
        return 'Unrated';
    }
  }

  @override
  String toString() {
    return 'BadgeData(handle: $handle, score: $worldScore, tier: $tier)';
  }
}