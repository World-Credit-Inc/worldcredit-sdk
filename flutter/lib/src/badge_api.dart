/// HTTP client for the World Credit Badge API
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'badge_data.dart';

/// Exception thrown when badge API requests fail
class BadgeApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const BadgeApiException(this.message, [this.statusCode, this.originalError]);

  @override
  String toString() => 'BadgeApiException: $message';
}

/// HTTP client for interacting with the World Credit Badge API
class BadgeApiClient {
  static const String _baseUrl = 'https://badgeapi-czne44luta-uc.a.run.app';
  static const Duration _defaultTimeout = Duration(seconds: 10);

  final http.Client _httpClient;
  final Duration timeout;
  
  /// API key for authenticated access
  String? apiKey;

  BadgeApiClient({
    http.Client? httpClient,
    this.timeout = _defaultTimeout,
    this.apiKey,
  }) : _httpClient = httpClient ?? http.Client();

  /// Fetches badge data for the given handle or email.
  /// If [email] is provided, lookup is by email. Otherwise by [handle].
  Future<BadgeData> fetchBadgeData(String handle, {String? email}) async {
    final queryParams = <String, String>{};

    if (email != null && email.trim().isNotEmpty) {
      queryParams['email'] = email.trim().toLowerCase();
    } else if (handle.trim().isNotEmpty) {
      queryParams['handle'] = handle.trim();
    } else {
      throw const BadgeApiException('Handle or email is required');
    }

    if (apiKey != null && apiKey!.isNotEmpty) {
      queryParams['key'] = apiKey!;
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _httpClient.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        // Check if the response indicates success
        if (jsonData['ok'] != true) {
          throw BadgeApiException(
            'API returned error for handle "$handle"',
            response.statusCode,
          );
        }
        
        return BadgeData.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw BadgeApiException(
          'Badge not found for handle "$handle"',
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        throw BadgeApiException(
          'Server error occurred',
          response.statusCode,
        );
      } else {
        throw BadgeApiException(
          'Failed to fetch badge data: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw const BadgeApiException('Request timed out');
    } on SocketException catch (e) {
      throw BadgeApiException('Network error: ${e.message}', null, e);
    } on FormatException catch (e) {
      throw BadgeApiException('Invalid response format', null, e);
    } catch (e) {
      if (e is BadgeApiException) rethrow;
      throw BadgeApiException('Unexpected error occurred', null, e);
    }
  }

  /// Validates that a handle is properly formatted
  static bool isValidHandle(String handle) {
    if (handle.trim().isEmpty) return false;
    
    // Basic validation - handles should be alphanumeric with possible underscores/hyphens
    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return regex.hasMatch(handle.trim());
  }

  /// Closes the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Singleton instance of the API client for global use
class BadgeApi {
  static BadgeApiClient? _instance;
  
  /// Gets the singleton instance
  static BadgeApiClient get instance {
    return _instance ??= BadgeApiClient();
  }
  
  /// Sets a custom API client instance (useful for testing)
  static void setInstance(BadgeApiClient client) {
    _instance?.dispose();
    _instance = client;
  }
  
  /// Disposes the singleton instance
  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}