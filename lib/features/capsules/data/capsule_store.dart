import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/account_data_store.dart';
import '../../../core/services/api_service.dart';

class CapsuleStore extends ChangeNotifier {
  CapsuleStore({ApiService? api}) : api = api ?? ApiService();
  static final instance = CapsuleStore();
  final ApiService api;
  List<Map<String, dynamic>> capsules = [], entries = [];
  Map<String, dynamic>? selected;
  bool loading = false, entriesLoading = false;
  String? error, entriesError;
  int _generation = 0, _selection = 0;

  Future<AccountSession> _session() async {
    final session = await AccountSession.current();
    if (session == null) throw StateError('Please sign in.');
    return session;
  }

  Future<void> load() async {
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final session = await _session();
      final response = await api.get('/capsules', sessionToken: session.token);
      final data = _data(response) as List;
      if (generation != _generation || !await session.isCurrent) return;
      capsules = data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (selected != null) {
        final match = capsules.where((item) => item['id'] == selected!['id']);
        selected = match.isEmpty ? null : match.first;
      }
    } catch (e) {
      if (generation == _generation) error = e.toString();
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void select(Map<String, dynamic> capsule) {
    _selection++;
    selected = capsule;
    entries = [];
    entriesError = null;
    notifyListeners();
  }

  String get _id {
    if (selected == null) throw StateError('Select a capsule first.');
    return selected!['id'] as String;
  }

  Future<void> loadEntries() async {
    final selection = _selection, generation = _generation;
    entriesLoading = true;
    entriesError = null;
    notifyListeners();
    try {
      final session = await _session(), id = _id;
      final data =
          _data(
                await api.get(
                  '/capsules/$id/entries',
                  sessionToken: session.token,
                ),
              )
              as List;
      if (generation != _generation ||
          selection != _selection ||
          !await session.isCurrent) {
        return;
      }
      entries = data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      if (generation == _generation && selection == _selection) {
        entriesError = e.toString();
      }
    } finally {
      if (generation == _generation && selection == _selection) {
        entriesLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _mutate(
    Future<http.Response> Function(String id, String token) request,
  ) async {
    final generation = _generation, selection = _selection;
    final session = await _session(), id = _id;
    final response = await request(id, session.token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _data(response);
    }
    if (generation != _generation ||
        selection != _selection ||
        !await session.isCurrent) {
      throw StateError('Your account changed. Please reopen this screen.');
    }
    await load();
    await loadEntries();
  }

  Future<void> update(Map<String, dynamic> fields) => _mutate(
    (id, token) => api.put('/capsules/$id', body: fields, sessionToken: token),
  );

  Future<void> seal() => _mutate(
    (id, token) => api.post('/capsules/$id/seal', sessionToken: token),
  );

  Future<void> saveEntry(Map<String, dynamic> fields, {String? entryId}) =>
      _mutate(
        (id, token) => entryId == null
            ? api.post(
                '/capsules/$id/entries',
                body: fields,
                sessionToken: token,
              )
            : api.put(
                '/capsules/$id/entries/$entryId',
                body: fields,
                sessionToken: token,
              ),
      );

  Future<void> deleteEntry(String entryId) => _mutate(
    (id, token) =>
        api.delete('/capsules/$id/entries/$entryId', sessionToken: token),
  );

  Future<void> invite(String contributorId) => _mutate(
    (id, token) => api.post(
      '/capsules/$id/invite',
      body: {'contributorId': contributorId.trim()},
      sessionToken: token,
    ),
  );

  Future<void> createResponse() async {
    final parent = selected;
    if (parent == null) throw StateError('Select a capsule first.');
    final generation = _generation;
    final session = await _session();
    final data = _data(
      await api.post(
        '/capsules',
        sessionToken: session.token,
        body: {
          'title': 'Response to ${parent['title'] ?? 'your capsule'}',
          'description': '',
          'type': parent['type'] ?? 'family',
          'privacy': 'private',
          'chainedFromCapsuleId': parent['id'],
        },
      ),
    );
    if (generation != _generation || !await session.isCurrent) {
      throw StateError('Your account changed.');
    }
    select(Map<String, dynamic>.from(data as Map));
    await load();
  }

  Future<void> delete() async {
    final generation = _generation;
    final session = await _session(), id = _id;
    final response = await api.delete(
      '/capsules/$id',
      sessionToken: session.token,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _data(response);
    }
    if (generation != _generation || !await session.isCurrent) return;
    _selection++;
    selected = null;
    entries = [];
    await load();
  }

  static Object _data(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw StateError('The server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        body['errorDescription'] ?? 'Could not save the capsule. Please retry.',
      );
    }
    return body['data'] as Object;
  }

  void reset() {
    _generation++;
    _selection++;
    capsules = [];
    entries = [];
    selected = null;
    error = entriesError = null;
    loading = entriesLoading = false;
    notifyListeners();
  }
}
