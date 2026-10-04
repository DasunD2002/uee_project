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

  Future<Map<String, String>> _getHeaders(String? sessionToken) async {
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

  Future<http.Response> get(String endpoint, {String? sessionToken}) async {
    if (isTestEnvironment) {
      if (testResponder != null) return testResponder!('GET', endpoint, null);
      return http.Response('{"content": []}', 200);
    }
    final headers = await _getHeaders(sessionToken);
    return await http
        .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(const Duration(seconds: 30));
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
    final headers = await _getHeaders(sessionToken);
    return await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));
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
    final headers = await _getHeaders(sessionToken);
    return await http
        .put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> delete(String endpoint, {String? sessionToken}) async {
    if (isTestEnvironment) {
      if (testResponder != null) {
        return testResponder!('DELETE', endpoint, null);
      }
      return http.Response('{"content": []}', 200);
    }
    final headers = await _getHeaders(sessionToken);
    return await http
        .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(const Duration(seconds: 30));
  }
}
