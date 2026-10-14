import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/api_service.dart';
import '../domain/translation_entry.dart';

abstract class TranslationService {
  Future<TranslationEntry> lookup({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  Future<TranslationPage> getGlossary({
    String? category,
    int page = 0,
    int size = 10,
  });
}

class ApiTranslationService implements TranslationService {
  ApiTranslationService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  @override
  Future<TranslationEntry> lookup({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final response = await _apiService.post(
      '/translations/lookup',
      body: {
        'text': text.trim(),
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
      },
    );
    return TranslationEntry.fromJson(_data(response));
  }

  @override
  Future<TranslationPage> getGlossary({
    String? category,
    int page = 0,
    int size = 10,
  }) async {
    final endpoint = Uri(
      path: '/translations/glossary',
      queryParameters: {
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        'page': '$page',
        'size': '$size',
      },
    ).toString();
    return TranslationPage.fromJson(_data(await _apiService.get(endpoint)));
  }

  static Map<String, dynamic> _data(http.Response response) {
    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        final value = jsonDecode(response.body);
        if (value is Map) decoded = value.cast<String, dynamic>();
      } on FormatException {
        decoded = null;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final fallback = response.statusCode == 401
          ? 'Your session has expired. Please log in again.'
          : response.statusCode == 404
          ? 'Translation was not found in the word bank.'
          : 'The translation request could not be completed.';
      throw TranslationApiException(
        decoded?['errorDescription']?.toString() ?? fallback,
        statusCode: response.statusCode,
      );
    }

    final data = decoded?['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const TranslationApiException(
      'The server returned an invalid response.',
    );
  }
}

class TranslationApiException implements Exception {
  const TranslationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
