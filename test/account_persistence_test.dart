import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uee_project/core/services/account_data_store.dart';
import 'package:uee_project/features/explorer/data/field_notes_store.dart';
import 'package:uee_project/features/explorer/data/journey_store.dart';
import 'package:uee_project/features/explorer/data/places_repository.dart';
import 'package:uee_project/features/explorer/domain/place.dart';
import 'package:uee_project/features/translations/data/translation_library_store.dart';
import 'package:uee_project/features/translations/domain/translation_entry.dart';

void main() {
  late Map<String, Map<String, dynamic>> database;
  late http.Client client;
  late List<http.Request> requests;
  Future<void> signIn(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    await prefs.setString('jwt_token', id);
  }

  AccountDataStore document(String key) =>
      AccountDataStore(key, client: client, baseUrl: 'https://api.test');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await signIn('alice');
    database = {};
    requests = [];
    client = MockClient((request) async {
      requests.add(request);
      if (request.url.path == '/api/v1/explore/places') {
        return http.Response(
          jsonEncode({'items': [], 'page': 0, 'size': 20, 'hasMore': false}),
          200,
        );
      }
      final id = '${request.headers['Authorization']}:${request.url.path}';
      final previous =
          database[id] ?? {'version': 0, 'data': <String, dynamic>{}};
      if (request.method == 'PUT') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['version'] != previous['version']) {
          return http.Response('{"errorDescription":"Concurrent change"}', 409);
        }
        database[id] = {
          'version': (previous['version'] as int) + 1,
          'data': body['data'],
        };
      }
      return http.Response(
        jsonEncode(database[id] ?? previous),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
  });
  tearDown(() => client.close());

  test(
    'Journey survives a new store with stop order, duration, date and drafts',
    () async {
      final store = JourneyStore(document: document('journey'));
      await store.load();
      for (final id in ['Q1', 'Q2']) {
        store.addPlace(
          Place(
            id: id,
            name: id,
            subtitle: 'Kandy, Sri Lanka',
            category: 'Museums',
            categoryId: 'museums',
            location: const LatLng(7.29, 80.64),
            imageUrl: 'https://image.test/$id',
            rating: 4.7,
          ),
        );
      }
      store.setVisitMinutes('Q1', 90);
      store.setDate(DateTime(2027, 1, 2));
      store.reorder(0, 1);
      await store.saveDraftToDatabase();
      final restored = JourneyStore(document: document('journey'));
      await restored.load();
      expect(restored.sites.map((site) => site.place.id), ['Q2', 'Q1']);
      expect(restored.visitMinutes, 90);
      expect(restored.date, DateTime(2027, 1, 2));
      expect(restored.drafts.single.sites.last.place.rating, 4.7);
      await restored.deleteDraftFromDatabase(restored.drafts.single);
      final afterDelete = JourneyStore(document: document('journey'));
      await afterDelete.load();
      expect(afterDelete.drafts, isEmpty);
      await signIn('bob');
      final other = JourneyStore(document: document('journey'));
      await other.load();
      expect(other.sites, isEmpty);
      expect(other.drafts, isEmpty);
    },
  );

  test(
    'Field notes create, edit, restore and delete without crossing accounts',
    () async {
      final notes = FieldNotesStore(document: document('field-notes'));
      FieldNote note(String text) => FieldNote(
        id: 'note-1',
        province: 'Central Province',
        site: 'Temple',
        category: 'Sacred Site',
        text: text,
        image: '',
        date: DateTime(2026, 10, 4),
        tags: ['Kandy'],
      );
      await notes.save(note('First observation'));
      await notes.save(note('Updated observation'));
      final restored = FieldNotesStore(document: document('field-notes'));
      await restored.load();
      expect(restored.notes.single.text, 'Updated observation');
      expect(restored.notes.single.tags, ['Kandy']);
      await signIn('bob');
      final other = FieldNotesStore(document: document('field-notes'));
      await other.load();
      expect(other.notes, isEmpty);
      await signIn('alice');
      await restored.delete('note-1');
      final afterDelete = FieldNotesStore(document: document('field-notes'));
      await afterDelete.load();
      expect(afterDelete.notes, isEmpty);
    },
  );

  test('overlapping searches preserve history and isolate accounts', () async {
    final repository = PlacesRepository(
      client: client,
      baseUrl: 'https://api.test',
    );
    await Future.wait([repository.search('Kandy'), repository.search('Galle')]);
    expect(await repository.history(), ['Galle', 'Kandy']);
    await repository.search('kandy');
    expect(await repository.history(), ['kandy', 'Galle']);
    await signIn('bob');
    expect(await repository.history(), isEmpty);
    await repository.search('Jaffna');
    await signIn('alice');
    expect(await repository.history(), ['kandy', 'Galle']);
    repository.dispose();
  });

  test(
    'translation saves, favourites and recents restore per account',
    () async {
      const entry = TranslationEntry(
        id: 'stupa',
        english: 'Stupa',
        sinhala: 'ස්තූපය',
        transliteration: 'Stupaya',
        pronunciation: 'stoo-pa-ya',
        meanings: [TranslationMeaning(partOfSpeech: 'noun', text: 'Monument')],
        sentence: 'An ancient stupa.',
        relatedWords: ['temple'],
        category: 'Temple',
      );
      final library = TranslationLibraryStore(
        document: document('translations'),
      );
      await Future.wait([
        library.remember(entry),
        library.toggleFavourite(entry),
        library.toggleSaved(entry),
      ]);
      final restored = TranslationLibraryStore(
        document: document('translations'),
      );
      await restored.load();
      expect(restored.recent.single.sinhala, entry.sinhala);
      expect(restored.saved.single.meanings.single.text, 'Monument');
      expect(restored.favourites, {'stupa'});
      await signIn('bob');
      final other = TranslationLibraryStore(document: document('translations'));
      await other.load();
      expect(other.saved, isEmpty);
      expect(other.recent, isEmpty);
      expect(other.favourites, isEmpty);
      await signIn('alice');
      await restored.toggleSaved(entry);
      await restored.toggleFavourite(entry);
      final afterRemoval = TranslationLibraryStore(
        document: document('translations'),
      );
      await afterRemoval.load();
      expect(afterRemoval.saved, isEmpty);
      expect(afterRemoval.favourites, isEmpty);
      expect(afterRemoval.recent, hasLength(1));
    },
  );

  test('concurrent field-note saves preserve both notes', () async {
    final notes = FieldNotesStore(document: document('field-notes'));
    FieldNote note(String id) => FieldNote(
      id: id,
      province: 'Central Province',
      site: 'Temple',
      category: 'Sacred Site',
      text: id,
      image: '',
      date: DateTime(2026, 10, 4),
    );
    await Future.wait([notes.save(note('first')), notes.save(note('second'))]);
    final restored = FieldNotesStore(document: document('field-notes'));
    await restored.load();
    expect(restored.notes.map((note) => note.id).toSet(), {'first', 'second'});
  });

  test('failed journey draft writes restore the visible draft list', () async {
    var rejectWrites = false;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        return http.Response('{"version":0,"data":{}}', 200);
      }
      if (rejectWrites) {
        return http.Response('{"errorDescription":"Server unavailable"}', 503);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'version': (body['version'] as int) + 1,
          'data': body['data'],
        }),
        200,
      );
    });
    final saved = AccountDataStore(
      'journey',
      client: client,
      baseUrl: 'https://api.test',
    );
    final store = JourneyStore(document: saved);
    await store.load();
    store.addPlace(
      const Place(
        id: 'temple',
        name: 'Temple',
        subtitle: 'Kandy',
        category: 'Sacred Sites',
        categoryId: 'sacred-sites',
        location: LatLng(7.3, 80.6),
      ),
    );
    await saved.flush();
    rejectWrites = true;
    await expectLater(
      store.saveDraftToDatabase(),
      throwsA(isA<AccountDataException>()),
    );
    expect(store.drafts, isEmpty);
    rejectWrites = false;
    await store.saveDraftToDatabase();
    final draft = store.drafts.single;
    rejectWrites = true;
    await expectLater(
      store.deleteDraftFromDatabase(draft),
      throwsA(isA<AccountDataException>()),
    );
    expect(store.drafts.single, same(draft));
    client.close();
  });

  test('stale writes fail instead of overwriting another session', () async {
    final first = document('preferences');
    final second = document('preferences');
    await first.load();
    await second.load();
    await first.save({'notifications': false});
    await expectLater(
      second.save({'notifications': true}),
      throwsA(isA<AccountDataException>()),
    );
    expect(second.error, 'Concurrent change');
    final restored = document('preferences');
    await restored.load();
    expect(restored.data['notifications'], false);
  });

  test('queued requests are rejected after account changes', () async {
    final first = document('journey');
    await first.load();
    final gate = Completer<void>();
    final delayed = MockClient((request) async {
      await gate.future;
      return http.Response('{"version":1,"data":{"sites":[]}}', 200);
    });
    final inFlight = AccountDataStore(
      'journey',
      client: delayed,
      baseUrl: 'https://api.test',
    );
    final loading = inFlight.load();
    await Future<void>.delayed(Duration.zero);
    await signIn('bob');
    gate.complete();
    await loading;
    expect(inFlight.loaded, false);
    final pending = first.save({
      'sites': ['must not reach bob'],
    });
    await expectLater(pending, throwsA(isA<AccountDataException>()));
    expect(requests.where((request) => request.method == 'PUT'), isEmpty);
    delayed.close();
  });
}
