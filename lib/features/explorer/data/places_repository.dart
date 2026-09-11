import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/explore_category.dart';
import '../domain/place.dart';
import '../domain/places_page.dart';

class PlacesApiException implements Exception {
  const PlacesApiException(this.message, {this.statusCode, this.retryAfter});

  final String message;
  final int? statusCode;
  final Duration? retryAfter;

  @override
  String toString() => message;
}

class PlacesRepository {
  PlacesRepository({
    http.Client? client,
    String? baseUrl,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       baseUrl = _normalizeBaseUrl(baseUrl ?? _defaultBaseUrl());

  static const _historyKey = 'explorer_search_history';
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const fallbackPlaces = <Place>[
    Place(
      id: 'gal-vihara',
      name: 'Gal Vihara',
      subtitle: 'Polonnaruwa, Sri Lanka',
      category: 'Sacred Sites',
      categoryId: 'sacred-sites',
      location: LatLng(7.9668, 81.0041),
      rating: 4.7,
    ),
    Place(
      id: 'vatadage',
      name: 'Polonnaruwa Vatadage',
      subtitle: 'Polonnaruwa, Sri Lanka',
      category: 'Ancient Ruins',
      categoryId: 'ancient-ruins',
      location: LatLng(7.9478, 81.0014),
      rating: 4.7,
    ),
  ];

  final http.Client _client;
  final bool _ownsClient;
  final String baseUrl;
  final Duration requestTimeout;

  String? photoUrl(Place place, {int width = 900}) => place.imageUrl;

  Future<List<String>> history() async =>
      (await SharedPreferences.getInstance()).getStringList(_historyKey) ??
      const ['Ancient ruins', 'Rock temples'];

  Future<List<Place>> suggestions() async =>
      (await fetchPlaces(size: 10)).items;

  Future<List<Place>> search(
    String query, {
    bool remember = true,
    String category = 'all',
  }) async => (await fetchPlaces(
    query: query,
    category: category,
    remember: remember,
  )).items;

  Future<PlacesPage> fetchPlaces({
    String query = '',
    String category = 'all',
    int page = 0,
    int size = 20,
    bool remember = false,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length > 120) {
      throw const PlacesApiException(
        'Search text must be 120 characters or fewer.',
      );
    }
    if (page < 0 || size < 1 || size > 50) {
      throw const PlacesApiException('Invalid Explore Places page request.');
    }
    if (remember && normalizedQuery.isNotEmpty) {
      await _remember(normalizedQuery);
    }

    final response = await _post(
      '/api/v1/explore/places',
      body: {
        'q': normalizedQuery,
        'category': category,
        'page': page,
        'size': size,
      },
    );
    _ensureSuccess(response);

    final decoded = _decodeObject(response.body);
    return PlacesPage.fromJson(decoded);
  }

  Future<List<ExploreCategory>> fetchCategories() async {
    final response = await _get('/api/v1/explore/categories');
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body);
    if (decoded is! List<Object?>) {
      throw const PlacesApiException(
        'The server returned an invalid categories response.',
      );
    }
    return decoded
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const PlacesApiException(
              'The server returned an invalid category item.',
            );
          }
          return ExploreCategory.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<void> _remember(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final items = <String>[...?prefs.getStringList(_historyKey)]
      ..removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await prefs.setStringList(_historyKey, [query, ...items].take(8).toList());
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, Object> body,
  }) async {
    try {
      return await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw PlacesApiException(
        'The Explore Places service at $baseUrl took too long to respond.',
      );
    } on http.ClientException {
      throw PlacesApiException(
        'Could not connect to the Explore Places service at $baseUrl.',
      );
    }
  }

  Future<http.Response> _get(String path) async {
    try {
      return await _client
          .get(
            Uri.parse('$baseUrl$path'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw PlacesApiException(
        'The Explore Places service at $baseUrl took too long to respond.',
      );
    } on http.ClientException {
      throw PlacesApiException(
        'Could not connect to the Explore Places service at $baseUrl.',
      );
    }
  }

  static Map<String, dynamic> _decodeObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Converted to a domain-specific error below.
    }
    throw const PlacesApiException(
      'The server returned an invalid Explore Places response.',
    );
  }

  static void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = 'Explore Places request failed (${response.statusCode}).';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'] ?? decoded['errorDescription'];
        if (detail is String && detail.trim().isNotEmpty) {
          message = detail.trim();
        }
      }
    } on FormatException {
      // Keep the status-based fallback message.
    }

    final retryAfterSeconds = int.tryParse(
      response.headers['retry-after'] ?? '',
    );
    throw PlacesApiException(
      message,
      statusCode: response.statusCode,
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds),
    );
  }

  static String _defaultBaseUrl() {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static String _normalizeBaseUrl(String value) =>
      value.trim().replaceFirst(RegExp(r'/+$'), '');

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
