import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uee_project/features/explorer/data/places_repository.dart';

import '../fixtures/province_fixture.dart';

void main() {
  test(
    'posts province pagination and reads real source metadata and images',
    () async {
      late http.Request request;
      final repository = PlacesRepository(
        baseUrl: 'http://localhost:8080/',
        client: MockClient((value) async {
          request = value;
          return http.Response(
            jsonEncode(provinceFixture(page: 1, images: true)),
            200,
          );
        }),
      );
      final details = await repository.fetchProvince('uva', page: 1, size: 5);
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/explore/province');
      expect(jsonDecode(request.body), {
        'provinceId': 'uva',
        'q': '',
        'page': 1,
        'size': 5,
      });
      expect(details.province.capital, 'Badulla');
      expect(details.province.districts, hasLength(2));
      expect(details.province.imageUrl, contains('commons.wikimedia.org'));
      expect(details.province.imageSourceUrl, contains('wiki/File:'));
      expect(details.places.items.single.imageUrl, contains('Temple.jpg'));
      expect(details.traditions.single.sourceUrl, endsWith('/Q400'));
    },
  );

  test(
    'sends a trimmed province place search and validates its length',
    () async {
      late http.Request captured;
      final repository = PlacesRepository(
        client: MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode(provinceFixture(empty: true)), 200);
        }),
      );
      await repository.fetchProvince('uva', query: '  temple  ');
      expect(jsonDecode(captured.body)['q'], 'temple');
      await expectLater(
        repository.fetchProvince('uva', query: 'x' * 121),
        throwsA(isA<PlacesApiException>()),
      );
    },
  );

  test(
    'handles missing optional photos and an empty source without samples',
    () async {
      final repository = PlacesRepository(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(provinceFixture(empty: true)), 200),
        ),
      );
      final result = await repository.fetchProvince('uva');
      expect(result.province.imageUrl, isNull);
      expect(result.places.items, isEmpty);
      expect(result.traditions, isEmpty);
    },
  );

  test('all nine map province identifiers are supported', () async {
    final repository = PlacesRepository(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode(provinceFixture(id: body['provinceId'] as String)),
          200,
        );
      }),
    );
    for (final id in [
      'northern',
      'north-central',
      'north-western',
      'central',
      'eastern',
      'western',
      'southern',
      'sabaragamuwa',
      'uva',
    ]) {
      expect((await repository.fetchProvince(id)).province.id, id);
    }
  });

  test('rejects invalid parameters before network access', () async {
    final repository = PlacesRepository(
      client: MockClient(
        (_) async => throw StateError('Must not send invalid request'),
      ),
    );
    for (final request in [
      () => repository.fetchProvince('unknown'),
      () => repository.fetchProvince('uva', page: -1),
      () => repository.fetchProvince('uva', page: 1000001),
      () => repository.fetchProvince('uva', size: 51),
    ]) {
      await expectLater(request(), throwsA(isA<PlacesApiException>()));
    }
  });

  test('rejects mismatched provinces and malformed response bodies', () async {
    var body = jsonEncode(provinceFixture(id: 'central'));
    final repository = PlacesRepository(
      client: MockClient((_) async => http.Response(body, 200)),
    );
    await expectLater(
      repository.fetchProvince('uva'),
      throwsA(isA<PlacesApiException>()),
    );
    body = '{}';
    await expectLater(repository.fetchProvince('uva'), throwsFormatException);
    body = 'not-json';
    await expectLater(
      repository.fetchProvince('uva'),
      throwsA(isA<PlacesApiException>()),
    );
  });

  test('preserves service failure details and retry delay', () async {
    final repository = PlacesRepository(
      client: MockClient(
        (_) async => http.Response(
          '{"detail":"Province data temporarily unavailable"}',
          503,
          headers: {'retry-after': '180'},
        ),
      ),
    );
    await expectLater(
      repository.fetchProvince('uva'),
      throwsA(
        isA<PlacesApiException>()
            .having((error) => error.statusCode, 'status', 503)
            .having(
              (error) => error.retryAfter,
              'retry delay',
              const Duration(seconds: 180),
            ),
      ),
    );
  });
}
