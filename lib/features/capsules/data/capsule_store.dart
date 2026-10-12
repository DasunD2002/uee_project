import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void notifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          super.notifyListeners();
        }
      });
    } else {
      super.notifyListeners();
    }
  }

  Future<String> _ensureLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw StateError('Please sign in.');
    }
    return token;
  }

  Future<void> load() async {
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _ensureLoggedIn();
      final response = await api.get('/capsules');
      final data = _data(response) as List;
      if (generation != _generation) return;
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
      await _ensureLoggedIn();
      final id = _id;
      final data =
          _data(
                await api.get(
                  '/capsules/$id/entries',
                ),
              )
              as List;
      if (generation != _generation || selection != _selection) {
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
    Future<http.Response> Function(String id) request,
  ) async {
    final generation = _generation, selection = _selection;
    await _ensureLoggedIn();
    final id = _id;
    final response = await request(id);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _data(response);
    }
    if (generation != _generation || selection != _selection) {
      throw StateError('Your account changed. Please reopen this screen.');
    }
    await load();
    await loadEntries();
  }

  Future<void> update(Map<String, dynamic> fields) => _mutate(
    (id) => api.put('/capsules/$id', body: fields),
  );

  Future<void> seal() => _mutate(
    (id) => api.post('/capsules/$id/seal'),
  );

  Future<void> saveEntry(Map<String, dynamic> fields, {String? entryId}) =>
      _mutate(
        (id) => entryId == null
            ? api.post(
                '/capsules/$id/entries',
                body: fields,
              )
            : api.put(
                '/capsules/$id/entries/$entryId',
                body: fields,
              ),
      );

  Future<void> deleteEntry(String entryId) => _mutate(
    (id) =>
        api.delete('/capsules/$id/entries/$entryId'),
  );

  Future<void> invite(String contributorId) => _mutate(
    (id) => api.post(
      '/capsules/$id/invite',
      body: {'contributorId': contributorId.trim()},
    ),
  );

  Future<void> createResponse() async {
    final parent = selected;
    if (parent == null) throw StateError('Select a capsule first.');
    final generation = _generation;
    await _ensureLoggedIn();
    final data = _data(
      await api.post(
        '/capsules',
        body: {
          'title': 'Response to ${parent['title'] ?? 'your capsule'}',
          'description': '',
          'type': parent['type'] ?? 'family',
          'privacy': 'private',
          'chainedFromCapsuleId': parent['id'],
        },
      ),
    );
    if (generation != _generation) {
      throw StateError('Your account changed.');
    }
    select(Map<String, dynamic>.from(data as Map));
    await load();
  }

  Future<void> delete() async {
    final generation = _generation;
    await _ensureLoggedIn();
    final id = _id;
    final response = await api.delete(
      '/capsules/$id',
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _data(response);
    }
    if (generation != _generation) return;
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
