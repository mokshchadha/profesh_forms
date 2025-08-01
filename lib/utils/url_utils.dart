// Create this file: lib/utils/url_utils.dart

import 'package:flutter/foundation.dart';

class UrlUtils {
  static bool isValidHash(String? hash) {
    if (hash == null || hash.isEmpty) return false;

    // Example validation - adjust based on your hash format
    // This assumes hashes are alphanumeric and between 16-64 characters
    final hashRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return hashRegex.hasMatch(hash);
  }

  static String? extractHashFromUrl([Uri? customUri]) {
    try {
      final uri = customUri ?? Uri.base;

      debugPrint('Extracting hash from URL: ${uri.toString()}');

      // Method 1: Check if hash is in path segments (e.g., /abc123)
      if (uri.pathSegments.isNotEmpty) {
        final pathHash = uri.pathSegments.first;
        if (pathHash.isNotEmpty && pathHash != '/' && isValidHash(pathHash)) {
          debugPrint('Valid hash found in path: $pathHash');
          return pathHash;
        }
      }

      // Method 2: Check query parameters (e.g., ?hash=abc123 or ?id=abc123)
      final queryParams = ['hash', 'id', 'jobId', 'projectId'];
      for (final param in queryParams) {
        if (uri.queryParameters.containsKey(param)) {
          final queryHash = uri.queryParameters[param];
          if (queryHash != null &&
              queryHash.isNotEmpty &&
              isValidHash(queryHash)) {
            debugPrint(
              'Valid hash found in query parameter "$param": $queryHash',
            );
            return queryHash;
          }
        }
      }

      // Method 3: Check URL fragment (e.g., #abc123)
      if (uri.fragment.isNotEmpty && isValidHash(uri.fragment)) {
        debugPrint('Valid hash found in fragment: ${uri.fragment}');
        return uri.fragment;
      }

      // Method 4: Check for nested paths (e.g., /job/abc123)
      if (uri.pathSegments.length > 1) {
        for (int i = 0; i < uri.pathSegments.length; i++) {
          final segment = uri.pathSegments[i];
          if (isValidHash(segment)) {
            debugPrint('Valid hash found in path segment $i: $segment');
            return segment;
          }
        }
      }

      debugPrint('No valid hash found in URL');
      return null;
    } catch (e) {
      debugPrint('Error extracting hash from URL: $e');
      return null;
    }
  }

  static String getCurrentUrl() {
    return Uri.base.toString();
  }

  static String buildJobUrl(String hash, {String? baseUrl}) {
    final base = baseUrl ?? Uri.base.origin;
    return '$base/$hash';
  }

  static void redirectToUrl(String url) {
    if (kIsWeb) {
      // For web, you might want to use url_launcher or dart:html
      // This is a placeholder - implement based on your needs
      debugPrint('Would redirect to: $url');
    }
  }

  /// Checks if running on web platform
  static bool get isWeb => kIsWeb;

  /// Gets domain from current URL
  static String? getCurrentDomain() {
    try {
      return Uri.base.host;
    } catch (e) {
      debugPrint('Error getting current domain: $e');
      return null;
    }
  }

  /// Debug function to print all URL components
  static void debugUrl([Uri? customUri]) {
    final uri = customUri ?? Uri.base;
    debugPrint('=== URL DEBUG INFO ===');
    debugPrint('Full URL: ${uri.toString()}');
    debugPrint('Scheme: ${uri.scheme}');
    debugPrint('Host: ${uri.host}');
    debugPrint('Port: ${uri.port}');
    debugPrint('Path: ${uri.path}');
    debugPrint('Path segments: ${uri.pathSegments}');
    debugPrint('Query: ${uri.query}');
    debugPrint('Query parameters: ${uri.queryParameters}');
    debugPrint('Fragment: ${uri.fragment}');
    debugPrint('=== END URL DEBUG ===');
  }
}
