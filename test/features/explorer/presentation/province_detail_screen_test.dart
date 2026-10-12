import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uee_project/features/explorer/data/places_repository.dart';
import 'package:uee_project/features/explorer/presentation/field_note_editor_screen.dart';
import 'package:uee_project/features/explorer/presentation/province_detail_screen.dart';
import 'package:uee_project/features/explorer/presentation/widgets/region_image.dart';

import '../fixtures/province_fixture.dart';

Widget screen(PlacesRepository repository, {String name = 'Uva Province'}) =>
    MaterialApp(
      home: ProvinceDetailScreen(
        name: name,
        tagline: 'Existing map tagline',
        sites: const ['Old sample'],
        accentColor: Colors.orange,
        repository: repository,
      ),
    );

void mobileSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> reveal(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    350,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 30,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'requests a compact real Commons photo without changing its source link',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionImage(
              source:
                  'https://commons.wikimedia.org/wiki/Special:FilePath/Test%20Photo.jpg',
              width: 200,
              height: 120,
            ),
          ),
        ),
      );
      final network =
          tester.widget<Image>(find.byType(Image)).image as NetworkImage;
      expect(Uri.parse(network.url).queryParameters['width'], '960');
      expect(
        Uri.decodeComponent(Uri.parse(network.url).path),
        contains('Test Photo.jpg'),
      );
    },
  );
  testWidgets('loads selected province and retains field notes navigation', (
    tester,
  ) async {
    mobileSize(tester);
    final pending = Completer<http.Response>();
    final repository = PlacesRepository(
      client: MockClient((request) {
        expect(jsonDecode(request.body)['provinceId'], 'uva');
        return pending.future;
      }),
    );
    await tester.pumpWidget(screen(repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(http.Response(jsonEncode(provinceFixture()), 200));
    await tester.pumpAndSettle();
    expect(find.text('Uva Province'), findsOneWidget);
    expect(find.text('Old sample'), findsNothing);
    await reveal(tester, 'Create Field Notes');
    tester.view.physicalSize = const Size(800, 800);
    await tester.pump();
    await tester.tap(find.text('Create Field Notes'));
    await tester.pumpAndSettle();
    final editor = tester.widget<FieldNoteEditorScreen>(
      find.byType(FieldNoteEditorScreen),
    );
    expect(editor.initialSite, 'Heritage Site 1');
    expect(editor.province, 'Uva Province');
  });

  testWidgets('offers retry on failure and shows honest empty states', (
    tester,
  ) async {
    mobileSize(tester);
    var attempts = 0;
    final repository = PlacesRepository(
      client: MockClient((_) async {
        attempts++;
        return attempts == 1
            ? http.Response('{"detail":"Provider unavailable"}', 503)
            : http.Response(jsonEncode(provinceFixture(empty: true)), 200);
      }),
    );
    await tester.pumpWidget(screen(repository));
    await tester.pumpAndSettle();
    expect(find.text('Provider unavailable'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await reveal(tester, 'No heritage sites found');
    expect(find.text('No heritage sites found'), findsOneWidget);
    expect(attempts, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('searches this province and keeps the query when loading more', (
    tester,
  ) async {
    mobileSize(tester);
    final requests = <Map<String, dynamic>>[];
    final repository = PlacesRepository(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requests.add(body);
        final query = body['q'] as String;
        final page = body['page'] as int;
        if (query == 'missing') {
          return http.Response(jsonEncode(provinceFixture(empty: true)), 200);
        }
        final response = provinceFixture(
          page: page,
          hasNext: query == 'temple' && page == 0,
        );
        if (query == 'temple') {
          final places = response['places'] as Map<String, dynamic>;
          final items = places['items'] as List<dynamic>;
          (items.single as Map<String, dynamic>)['name'] = 'Temple ${page + 1}';
        }
        return http.Response(jsonEncode(response), 200);
      }),
    );
    await tester.pumpWidget(screen(repository));
    await tester.pumpAndSettle();
    await reveal(tester, 'Top Heritage Sites');
    await tester.enterText(
      find.byKey(const Key('province-place-search')),
      'temple',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(requests.last['provinceId'], 'uva');
    expect(requests.last['q'], 'temple');
    expect(requests.last['page'], 0);
    await reveal(tester, 'Load more heritage sites');
    await tester.tap(find.text('Load more heritage sites'));
    await tester.pumpAndSettle();
    expect(requests.last['q'], 'temple');
    expect(requests.last['page'], 1);
    await reveal(tester, 'Temple 2');
    expect(find.text('Temple 2'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2500));
    await tester.pumpAndSettle();
    await reveal(tester, 'Top Heritage Sites');
    await tester.enterText(
      find.byKey(const Key('province-place-search')),
      'missing',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await reveal(tester, 'No matching places');
    expect(find.text('No matching places'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2500));
    await tester.pumpAndSettle();
    await reveal(tester, 'Top Heritage Sites');
    await tester.tap(find.byTooltip('Clear place search'));
    await tester.pumpAndSettle();
    expect(requests.last['q'], '');
    expect(requests.last['page'], 0);
  });

  testWidgets('failed pagination retries the same page and appends results', (
    tester,
  ) async {
    mobileSize(tester);
    final requested = <int>[];
    var failed = false;
    final repository = PlacesRepository(
      client: MockClient((request) async {
        final page = jsonDecode(request.body)['page'] as int;
        requested.add(page);
        if (page == 1 && !failed) {
          failed = true;
          return http.Response('{"detail":"Please retry"}', 503);
        }
        return http.Response(
          jsonEncode(provinceFixture(page: page, hasNext: page == 0)),
          200,
        );
      }),
    );
    await tester.pumpWidget(screen(repository));
    await tester.pumpAndSettle();
    await reveal(tester, 'Load more heritage sites');
    await tester.tap(find.text('Load more heritage sites'));
    await tester.pumpAndSettle();
    await reveal(tester, 'Try again');
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await reveal(tester, 'Heritage Site 2');
    expect(find.text('Heritage Site 2'), findsOneWidget);
    expect(requested, [0, 1, 1]);
    await reveal(tester, 'Cultural Traditions');
    await tester.tap(find.text('View all →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regional Festival').last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed refresh retries page zero even when more sites exist', (
    tester,
  ) async {
    mobileSize(tester);
    final requested = <int>[];
    final repository = PlacesRepository(
      client: MockClient((request) async {
        final page = jsonDecode(request.body)['page'] as int;
        requested.add(page);
        return requested.length == 2
            ? http.Response('{"detail":"Refresh failed"}', 503)
            : http.Response(jsonEncode(provinceFixture(hasNext: true)), 200);
      }),
    );
    await tester.pumpWidget(screen(repository));
    await tester.pumpAndSettle();
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    await reveal(tester, 'Try again');
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(requested, [0, 0, 0]);
  });

  testWidgets('discards a late response after switching provinces', (
    tester,
  ) async {
    final uva = Completer<http.Response>();
    final repository = PlacesRepository(
      client: MockClient((request) async {
        final id = jsonDecode(request.body)['provinceId'];
        if (id == 'uva') return uva.future;
        return http.Response(
          jsonEncode(provinceFixture(id: 'central', name: 'Central Province')),
          200,
        );
      }),
    );
    await tester.pumpWidget(screen(repository));
    await tester.pumpWidget(screen(repository, name: 'Central Province'));
    await tester.pumpAndSettle();
    uva.complete(http.Response(jsonEncode(provinceFixture()), 200));
    await tester.pumpAndSettle();
    expect(find.text('Central Province'), findsOneWidget);
    expect(find.text('Uva Province'), findsNothing);
  });

  test('normalizes all nine province names from the map', () {
    for (final name in [
      'Northern',
      'North Central',
      'North Western',
      'Central',
      'Eastern',
      'Western',
      'Southern',
      'Sabaragamuwa',
      'Uva',
    ]) {
      final widget = ProvinceDetailScreen(
        name: '$name Province',
        tagline: '',
        sites: const [],
        accentColor: Colors.orange,
      );
      expect(widget.provinceId, name.toLowerCase().replaceAll(' ', '-'));
    }
  });
}
