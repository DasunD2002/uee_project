import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uee_project/features/explorer/data/places_repository.dart';

void main() {
  group('PlacesRepository', () {
    test('posts search filters and maps the places page', () async {
      late http.Request captured;
      final repository = PlacesRepository(
        baseUrl: 'http://localhost:8080/',
        client: _StubClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': 'Q100',
                  'name': 'Gal Vihara',
                  'subtitle': 'Polonnaruwa, Sri Lanka',
                  'category': 'Sacred Sites',
                  'categoryId': 'sacred-sites',
                  'location': {'latitude': 7.9668, 'longitude': 81.0041},
                  'description': 'Ancient rock temple',
                  'imageUrl': 'https://example.com/gal-vihara.jpg',
                  'sourceUrl': 'https://www.wikidata.org/wiki/Q100',
                },
              ],
              'page': 0,
              'size': 20,
              'total': 1,
              'hasNext': false,
              'source': 'Wikidata',
              'fetchedAt': '2026-09-08T10:00:00Z',
              'stale': false,
              'truncated': false,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final result = await repository.fetchPlaces(
        query: 'temple',
        category: 'sacred-sites',
      );

      expect(captured.method, 'POST');
      expect(
        captured.url.toString(),
        'http://localhost:8080/api/v1/explore/places',
      );
      expect(jsonDecode(captured.body), {
        'q': 'temple',
        'category': 'sacred-sites',
        'page': 0,
        'size': 20,
      });
      expect(result.total, 1);
      expect(result.items.single.name, 'Gal Vihara');
      expect(result.items.single.categoryId, 'sacred-sites');
      expect(result.items.single.location.latitude, closeTo(7.9668, 0.0001));
    });

    test('loads categories from the public endpoint', () async {
      final repository = PlacesRepository(
        baseUrl: 'http://localhost:8080',
        client: _StubClient(
          (request) async => http.Response(
            jsonEncode([
              {'id': 'ancient-ruins', 'label': 'Ancient Ruins'},
              {'id': 'museums', 'label': 'Museums'},
            ]),
            200,
          ),
        ),
      );

      final categories = await repository.fetchCategories();

      expect(categories.map((item) => item.id), ['ancient-ruins', 'museums']);
    });

    test('surfaces backend problem details and retry timing', () async {
      final repository = PlacesRepository(
        baseUrl: 'http://localhost:8080',
        client: _StubClient(
          (request) async => http.Response(
            jsonEncode({'detail': 'Temporarily unavailable'}),
            503,
            headers: {'retry-after': '60'},
          ),
        ),
      );

      try {
        await repository.fetchPlaces();
        fail('Expected PlacesApiException');
      } on PlacesApiException catch (error) {
        expect(error.statusCode, 503);
        expect(error.message, 'Temporarily unavailable');
        expect(error.retryAfter, const Duration(seconds: 60));
      }
    });
  });
}

class _StubClient extends http.BaseClient {
  _StubClient(this.handler);

  final Future<http.Response> Function(http.Request request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().bytesToString();
    final copied = http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..body = body;
    final response = await handler(copied);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
