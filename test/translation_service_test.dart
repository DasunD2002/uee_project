import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uee_project/core/services/api_service.dart';
import 'package:uee_project/features/translations/data/translation_service.dart';

void main() {
  test('uses the authenticated API routes for lookup and glossary', () async {
    final api = RecordingApiService();
    final service = ApiTranslationService(apiService: api);
    api.nextData = _entryJson;

    final entry = await service.lookup(
      text: ' stupa ',
      sourceLanguage: 'en',
      targetLanguage: 'si',
    );

    expect(api.lastMethod, 'POST');
    expect(api.lastEndpoint, '/translations/lookup');
    expect(api.lastBody, {
      'text': 'stupa',
      'sourceLanguage': 'en',
      'targetLanguage': 'si',
    });
    expect(entry.sinhala, 'ස්තූපය');
    expect(entry.sentence, 'We walked around the ancient stupa.');
    expect(entry.meanings.single.partOfSpeech, 'noun');

    api.nextData = {
      'items': [_entryJson],
      'page': 0,
      'size': 4,
      'total': 15,
      'hasNext': true,
    };
    final page = await service.getGlossary(category: 'Temple', size: 4);

    expect(api.lastMethod, 'GET');
    expect(
      api.lastEndpoint,
      '/translations/glossary?category=Temple&page=0&size=4',
    );
    expect(page.items.single.english, 'Stupa');
    expect(page.total, 15);
    expect(page.hasNext, isTrue);
  });

  test('surfaces backend translation errors', () async {
    final api = RecordingApiService()
      ..statusCode = 404
      ..errorDescription = 'Translation was not found in the offline word bank';
    final service = ApiTranslationService(apiService: api);

    expect(
      () => service.lookup(
        text: 'unknown',
        sourceLanguage: 'en',
        targetLanguage: 'si',
      ),
      throwsA(
        isA<TranslationApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having((error) => error.message, 'message', contains('not found')),
      ),
    );
  });
}

const _entryJson = <String, dynamic>{
  'id': 'translation-1',
  'english': 'Stupa',
  'sinhala': 'ස්තූපය',
  'transliteration': 'Stūpaya',
  'pronunciation': 'stoo-pa-ya',
  'meanings': [
    {'partOfSpeech': 'noun', 'text': 'A dome-shaped Buddhist monument.'},
  ],
  'exampleSentence': 'We walked around the ancient stupa.',
  'relatedWords': ['relic', 'temple'],
  'category': 'Temple',
};

class RecordingApiService extends ApiService {
  String? lastMethod;
  String? lastEndpoint;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic> nextData = {};
  int statusCode = 200;
  String errorDescription = 'Request failed';

  @override
  Future<http.Response> get(String endpoint) => _response('GET', endpoint);

  @override
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) =>
      _response('POST', endpoint, body);

  Future<http.Response> _response(
    String method,
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    lastMethod = method;
    lastEndpoint = endpoint;
    lastBody = body;
    final payload = statusCode >= 200 && statusCode < 300
        ? {'data': nextData}
        : {'errorDescription': errorDescription};
    return http.Response(
      jsonEncode(payload),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
