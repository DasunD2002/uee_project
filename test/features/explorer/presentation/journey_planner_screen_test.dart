import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:uee_project/features/explorer/data/journey_store.dart';
import 'package:uee_project/features/explorer/data/places_repository.dart';
import 'package:uee_project/features/explorer/domain/place.dart';
import 'package:uee_project/features/explorer/presentation/journey_planner_screen.dart';
import 'package:uee_project/features/explorer/presentation/place_detail_screen.dart';
import 'package:uee_project/features/explorer/presentation/redesigned_explorer_screen.dart';
import 'package:uee_project/features/explorer/presentation/widgets/place_image.dart';

const museum = Place(
  id: 'Q123',
  name: 'Kandy National Museum',
  subtitle: 'Kandy, Sri Lanka',
  category: 'Museums',
  categoryId: 'museums',
  description: 'Discover the history of the Kandyan kingdom.',
  location: LatLng(7.293, 80.641),
);

Future<void> scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  late JourneyStore store;

  setUp(() => store = JourneyStore());
  tearDown(() => store.dispose());

  testWidgets(
    'empty builder has no sample places and offers safe Explore navigation',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JourneyPlannerScreen(store: store),
          routes: {
            '/explorer': (_) =>
                const Scaffold(body: Text('Explore destination')),
          },
        ),
      );
      expect(find.text('Your journey starts here'), findsOneWidget);
      expect(find.text('One Day in Polonnaruwa'), findsNothing);
      expect(find.text('Visit times not set'), findsOneWidget);
      await scrollTo(tester, find.text('Save Draft'));
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Save Draft'),
            )
            .onPressed,
        isNull,
      );
      await scrollTo(tester, find.text('View Route'));
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'View Route'),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('Explore Places'));
      await tester.tap(find.text('Explore Places'));
      await tester.pumpAndSettle();
      expect(find.text('Explore destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selected API place supplies itinerary metadata and missing image fallback',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JourneyPlannerScreen(store: store, selectedPlace: museum),
        ),
      );
      expect(store.sites.single.place, same(museum));
      expect(find.text('Journey to Kandy'), findsOneWidget);
      expect(find.text('1 stop'), findsOneWidget);
      await scrollTo(tester, find.text(museum.description!));
      expect(find.text(museum.category), findsOneWidget);
      expect(find.text(museum.subtitle), findsOneWidget);
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      await tester.tap(find.byTooltip('Remove ${museum.name}'));
      await tester.pumpAndSettle();
      expect(store.sites, isEmpty);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 800));
      await tester.pumpAndSettle();
      expect(find.text('Your journey starts here'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'visit time, draft restore and route preview use the selected stop',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JourneyPlannerScreen(store: store, selectedPlace: museum),
        ),
      );
      await scrollTo(tester, find.text('Set visit time'));
      await tester.tap(find.text('Set visit time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 hr 30 min'));
      await tester.pumpAndSettle();
      expect(store.visitMinutes, 90);

      await scrollTo(tester, find.text('Save Draft'));
      await tester.tap(find.text('Save Draft'));
      await tester.pumpAndSettle();
      expect(store.drafts.single.name, 'Journey to Kandy');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('View Drafts (1)'));
      await tester.tap(find.text('View Drafts (1)'));
      await tester.pumpAndSettle();
      store.removePlace(museum.id);
      await tester.pump();
      await tester.tap(find.text('Journey to Kandy'));
      await tester.pumpAndSettle();
      expect(store.sites.single.place, same(museum));
      expect(store.visitMinutes, 90);

      await scrollTo(tester, find.text('View Route'));
      await tester.tap(find.text('View Route'));
      await tester.pumpAndSettle();
      expect(find.text('Route preview'), findsOneWidget);
      expect(find.text('Kandy, Sri Lanka\n7.2930, 80.6410'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('builder remains scrollable on a small screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.addPlace(museum);
    store.addPlace(
      const Place(
        id: 'Q124',
        name: 'A heritage place with a long name in another region',
        subtitle: 'Anuradhapura, North Central Province, Sri Lanka',
        category: 'Heritage Sites',
        categoryId: 'heritage-sites',
        location: LatLng(8.3, 80.4),
      ),
    );
    store.setVisitMinutes(museum.id, 90);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: JourneyPlannerScreen(store: store),
      ),
    );
    await scrollTo(tester, find.text('View Route'));
    expect(find.text('View Route').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Explore result passes full place to detail and journey, then returns to Explore',
    (tester) async {
      final shared = JourneyStore.instance;
      for (final site in shared.sites) {
        shared.removePlace(site.place.id);
      }
      addTearDown(() {
        for (final site in shared.sites) {
          shared.removePlace(site.place.id);
        }
      });
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/categories')) {
          return http.Response('[{"id":"museums","label":"Museums"}]', 200);
        }
        return http.Response(
          jsonEncode({
            'items': [
              {
                'id': museum.id,
                'name': museum.name,
                'subtitle': museum.subtitle,
                'category': museum.category,
                'categoryId': museum.categoryId,
                'description': museum.description,
                'imageUrl': 'https://example.com/kandy.jpg',
                'location': {'latitude': 7.293, 'longitude': 80.641},
                'sourceUrl': 'https://www.wikidata.org/wiki/Q123',
              },
            ],
            'page': 0,
            'size': 10,
            'total': 1,
            'hasNext': false,
            'source': 'Wikidata',
            'fetchedAt': '2026-09-12T00:00:00Z',
            'stale': false,
            'truncated': false,
          }),
          200,
        );
      });
      addTearDown(client.close);
      final repository = PlacesRepository(client: client);
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/explorer',
          routes: {
            '/explorer': (_) => Scaffold(
              body: RedesignedExplorerScreen(
                onOpenDrawer: () {},
                repository: repository,
              ),
            ),
            '/journey': (_) => const JourneyPlannerScreen(),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Journey Builder'), findsOneWidget);
      await scrollTo(tester, find.text(museum.name));
      await tester.tap(find.text(museum.name));
      await tester.pumpAndSettle();
      expect(find.byType(PlaceDetailScreen), findsOneWidget);
      await scrollTo(tester, find.text('Add to Journey'));
      await tester.tap(find.text('Add to Journey'));
      await tester.pumpAndSettle();
      final saved = shared.sites.single.place;
      expect(saved.id, museum.id);
      expect(saved.description, museum.description);
      expect(saved.imageUrl, 'https://example.com/kandy.jpg');
      expect(saved.location.latitude, 7.293);
      expect(saved.sourceUrl, 'https://www.wikidata.org/wiki/Q123');

      await scrollTo(tester, find.byType(PlaceImage));
      expect(
        tester.widget<PlaceImage>(find.byType(PlaceImage)).url,
        saved.imageUrl,
      );
      await scrollTo(tester, find.text('Add More Sites'));
      await tester.tap(find.text('Add More Sites'));
      await tester.pumpAndSettle();
      expect(find.byType(RedesignedExplorerScreen), findsOneWidget);
      expect(find.byType(JourneyPlannerScreen), findsNothing);
      await tester.tap(find.byTooltip('Journey Builder'));
      await tester.pumpAndSettle();
      expect(shared.sites, hasLength(1));
      expect(find.text('Journey to Kandy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
