import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

bool isTestEnvironment =
    !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

class ApiService {
  @visibleForTesting
  static Future<http.Response> Function(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
  )?
  testResponder;

  static String get baseUrl => '${ApiConstants.baseUrl}/api/v1';

  static String _getFallbackUrl(String url) {
    if (url.contains('127.0.0.1')) {
      return url.replaceAll('127.0.0.1', '10.0.2.2');
    } else if (url.contains('10.0.2.2')) {
      return url.replaceAll('10.0.2.2', '127.0.0.1');
    }
    return url;
  }

  Future<Map<String, String>> _getHeaders([String? sessionToken]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = sessionToken ?? prefs.getString('jwt_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': 'en',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _sendWithFallback(
    String endpoint,
    String? sessionToken,
    Future<http.Response> Function(Uri uri, Map<String, String> headers) requester,
  ) async {
    final headers = await _getHeaders(sessionToken);
    final primaryUri = Uri.parse('$baseUrl$endpoint');
    try {
      return await requester(primaryUri, headers);
    } catch (_) {
      final fallbackString = _getFallbackUrl(primaryUri.toString());
      if (fallbackString != primaryUri.toString()) {
        try {
          return await requester(Uri.parse(fallbackString), headers);
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint, {String? sessionToken}) async {
    if (isTestEnvironment) {
      if (testResponder != null) return testResponder!('GET', endpoint, null);
      return http.Response('{"content": []}', 200);
    }
    return await _sendWithFallback(
      endpoint,
      sessionToken,
      (uri, headers) => http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30)),
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) async {
    if (isTestEnvironment) {
      if (testResponder != null) return testResponder!('POST', endpoint, body);
      return http.Response('{"content": []}', 201);
    }
    final encoded = body != null ? jsonEncode(body) : null;
    return await _sendWithFallback(
      endpoint,
      sessionToken,
      (uri, headers) => http
          .post(uri, headers: headers, body: encoded)
          .timeout(const Duration(seconds: 30)),
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) async {
    if (isTestEnvironment) {
      if (testResponder != null) return testResponder!('PUT', endpoint, body);
      return http.Response('{"content": []}', 200);
    }
    final encoded = body != null ? jsonEncode(body) : null;
    return await _sendWithFallback(
      endpoint,
      sessionToken,
      (uri, headers) => http
          .put(uri, headers: headers, body: encoded)
          .timeout(const Duration(seconds: 30)),
    );
  }

  Future<http.Response> delete(String endpoint, {String? sessionToken}) async {
    if (isTestEnvironment) {
      if (testResponder != null) {
        return testResponder!('DELETE', endpoint, null);
      }
      return http.Response('{"content": []}', 200);
    }
    return await _sendWithFallback(
      endpoint,
      sessionToken,
      (uri, headers) => http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30)),
    );
  }
}
