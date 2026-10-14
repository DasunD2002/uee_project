import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:uee_project/features/explorer/data/journey_store.dart';
import 'package:uee_project/features/explorer/domain/place.dart';

Place place(
  String id, {
  String name = 'Heritage Museum',
  String subtitle = 'Kandy, Sri Lanka',
  String? imageUrl,
}) => Place(
  id: id,
  name: name,
  subtitle: subtitle,
  category: 'Museums',
  categoryId: 'museums',
  location: const LatLng(7.29, 80.64),
  description: 'A museum in Kandy.',
  imageUrl: imageUrl,
);

void main() {
  late JourneyStore store;
  setUp(() => store = JourneyStore());
  tearDown(() => store.dispose());

  test('starts empty and never saves an empty draft', () {
    expect(store.sites, isEmpty);
    expect(store.saveDraft(), isFalse);
    expect(store.drafts, isEmpty);
    expect(store.date, isNull);
    expect(store.visitMinutes, 0);
  });

  test(
    'uses API identity and refreshes metadata without duplicating a stop',
    () {
      store.addPlace(place('Q1'));
      store.setVisitMinutes('Q1', 45);
      store.addPlace(
        place('Q2'),
      ); // The same name can identify a different place.
      final updated = place(
        'Q1',
        name: 'Updated museum',
        imageUrl: 'https://example.com/museum.jpg',
      );
      store.addPlace(updated);

      expect(store.sites.map((site) => site.place.id), ['Q1', 'Q2']);
      expect(store.sites.first.place, same(updated));
      expect(store.sites.first.visitMinutes, 45);
      expect(store.timedStops, 1);
      expect(store.name, 'Journey to Kandy');
    },
  );

  test('reorders both ways and removes by ID without affecting namesakes', () {
    for (final id in ['Q1', 'Q2', 'Q3']) {
      store.addPlace(place(id));
    }
    store.reorder(0, 2);
    expect(store.sites.map((site) => site.place.id), ['Q2', 'Q3', 'Q1']);
    store.reorder(2, 0);
    expect(store.sites.map((site) => site.place.id), ['Q1', 'Q2', 'Q3']);
    store.removePlace('Q2');
    expect(store.sites.map((site) => site.place.id), ['Q1', 'Q3']);
  });

  test('draft snapshots retain API data, order, visit times and date', () {
    final first = place('Q1', imageUrl: 'https://example.com/museum.jpg');
    store.addPlace(first);
    store.addPlace(place('Q2', subtitle: 'Galle, Sri Lanka'));
    store.setVisitMinutes('Q1', 90);
    final date = DateTime(2026, 12, 10);
    store.setDate(date);
    expect(store.saveDraft(), isTrue);
    final draft = store.drafts.single;
    expect(draft.name, 'My Heritage Journey');

    store.reorder(0, 1);
    store.setVisitMinutes('Q1', 30);
    store.removePlace('Q2');
    store.setDate(null);
    expect(draft.sites.map((site) => site.place.id), ['Q1', 'Q2']);
    expect(draft.sites.first.visitMinutes, 90);
    expect(draft.date, date);

    store.openDraft(draft);
    expect(store.sites.map((site) => site.place.id), ['Q1', 'Q2']);
    expect(store.sites.first.place, same(first));
    expect(store.visitMinutes, 90);
    expect(store.date, date);

    store.removePlace('Q1');
    expect(draft.sites, hasLength(2));
    store.deleteDraft(draft);
    expect(store.drafts, isEmpty);
    expect(store.sites.single.place.id, 'Q2');
  });

  test('visit totals include only configured stops and can be cleared', () {
    store.addPlace(place('Q1'));
    store.addPlace(place('Q2'));
    store.setVisitMinutes('Q1', 90);
    store.setVisitMinutes('Q2', 45);
    expect(store.visitMinutes, 135);
    expect(store.timedStops, 2);
    store.setVisitMinutes('Q1', null);
    expect(store.visitMinutes, 45);
    expect(store.timedStops, 1);
    expect(() => store.setVisitMinutes('Q1', -1), throwsArgumentError);
  });
}
