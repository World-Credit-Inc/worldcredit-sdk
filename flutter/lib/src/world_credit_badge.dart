/// Main API for World Credit Badge SDK with caching
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'badge_api.dart';
import 'badge_data.dart';

/// Main class for fetching and caching World Credit badge data
class WorldCreditBadge {
  static final Map<String, BadgeData> _cache = {};
  static final Map<String, Future<BadgeData>> _pendingRequests = {};
  
  /// Configure the SDK with your API key. Call this before using any badge features.
  /// Typically called in main() before runApp().
  static void configure({required String apiKey}) {
    BadgeApi.instance.apiKey = apiKey;
  }
  
  /// Cache duration in minutes (default: 5 minutes)
  static Duration cacheDuration = const Duration(minutes: 5);
  
  /// Maximum cache size (default: 100 entries)
  static int maxCacheSize = 100;

  /// Fetches badge data for the given handle or email with caching.
  /// If [email] is provided, lookup is by email (handle can be empty).
  static Future<BadgeData> fetch(String handle, {String? email}) async {
    final normalizedHandle = handle.trim().isNotEmpty
        ? handle.trim().toLowerCase()
        : (email?.trim().toLowerCase() ?? '');
    
    if (normalizedHandle.isEmpty) {
      throw const BadgeApiException('Handle or email is required');
    }

    // Check cache first
    final cached = _cache[normalizedHandle];
    if (cached != null && cached.isFresh) {
      return cached;
    }

    // Check if there's already a pending request for this handle
    final pendingRequest = _pendingRequests[normalizedHandle];
    if (pendingRequest != null) {
      return pendingRequest;
    }

    // Create new request
    final futureData = _fetchAndCache(handle.trim(), email: email);
    _pendingRequests[normalizedHandle] = futureData;

    try {
      final data = await futureData;
      _pendingRequests.remove(normalizedHandle);
      return data;
    } catch (e) {
      _pendingRequests.remove(normalizedHandle);
      rethrow;
    }
  }

  /// Internal method to fetch data and update cache
  static Future<BadgeData> _fetchAndCache(String handle, {String? email}) async {
    try {
      final data = await BadgeApi.instance.fetchBadgeData(handle, email: email);
      
      // Update cache
      _updateCache(handle, data);
      
      return data;
    } catch (e) {
      // Don't cache errors, but log them in debug mode
      if (kDebugMode) {
        print('WorldCreditBadge: Failed to fetch data for handle "$handle": $e');
      }
      rethrow;
    }
  }

  /// Updates the cache with new data, managing cache size
  static void _updateCache(String handle, BadgeData data) {
    // Clean up expired entries first
    _cleanupExpiredEntries();
    
    // If cache is still too large, remove oldest entries
    if (_cache.length >= maxCacheSize) {
      _evictOldestEntries();
    }
    
    _cache[handle] = data;
  }

  /// Removes expired entries from cache
  static void _cleanupExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => now.difference(entry.value.cachedAt) > cacheDuration)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Evicts oldest entries when cache is full
  static void _evictOldestEntries() {
    final entries = _cache.entries.toList()
      ..sort((a, b) => a.value.cachedAt.compareTo(b.value.cachedAt));
    
    final entriesToRemove = entries.take(_cache.length - maxCacheSize + 1);
    for (final entry in entriesToRemove) {
      _cache.remove(entry.key);
    }
  }

  /// Preloads badge data for multiple handles
  static Future<Map<String, BadgeData?>> preload(List<String> handles) async {
    final results = <String, BadgeData?>{};
    
    final futures = handles.map((handle) async {
      try {
        final data = await fetch(handle);
        results[handle] = data;
      } catch (e) {
        if (kDebugMode) {
          print('WorldCreditBadge: Failed to preload handle "$handle": $e');
        }
        results[handle] = null;
      }
    });

    await Future.wait(futures);
    return results;
  }

  /// Gets cached data without making a network request
  static BadgeData? getCached(String handle) {
    final normalizedHandle = handle.trim().toLowerCase();
    final cached = _cache[normalizedHandle];
    
    if (cached != null && cached.isFresh) {
      return cached;
    }
    
    return null;
  }

  /// Checks if data is cached and fresh for the given handle
  static bool isCached(String handle) {
    return getCached(handle) != null;
  }

  /// Invalidates cache for a specific handle
  static void invalidate(String handle) {
    final normalizedHandle = handle.trim().toLowerCase();
    _cache.remove(normalizedHandle);
    _pendingRequests.remove(normalizedHandle);
  }

  /// Clears all cached data
  static void clearCache() {
    _cache.clear();
    _pendingRequests.clear();
  }

  /// Gets current cache statistics
  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final freshEntries = _cache.values
        .where((data) => now.difference(data.cachedAt) <= cacheDuration)
        .length;
    
    return {
      'totalEntries': _cache.length,
      'freshEntries': freshEntries,
      'expiredEntries': _cache.length - freshEntries,
      'pendingRequests': _pendingRequests.length,
      'maxCacheSize': maxCacheSize,
      'cacheDurationMinutes': cacheDuration.inMinutes,
    };
  }

  /// Sets custom cache configuration
  static void configureCaching({
    Duration? duration,
    int? maxSize,
  }) {
    if (duration != null) {
      cacheDuration = duration;
    }
    
    if (maxSize != null && maxSize > 0) {
      maxCacheSize = maxSize;
      
      // Clean up if current cache exceeds new limit
      if (_cache.length > maxSize) {
        _evictOldestEntries();
      }
    }
  }

  /// Validates a handle format
  static bool isValidHandle(String handle) {
    return BadgeApiClient.isValidHandle(handle);
  }
}