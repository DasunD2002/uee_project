import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/account_data_store.dart';
import '../../../core/services/api_service.dart';

import '../domain/journey.dart';
import '../domain/place.dart';

class JourneyStore extends ChangeNotifier {
  JourneyStore({this.document});
  final AccountDataStore? document;
  static final instance = JourneyStore(
    document: isTestEnvironment ? null : AccountDataStore('journey'),
  );
  bool loading = false, _hydrated = false;
  int _generation = 0;
  String? get error => document?.error;
  bool get saving => document?.saving ?? false;

  Future<void> load({bool force = false}) async {
    if (document == null || (_hydrated && !force)) return;
    final generation = _generation;
    loading = true;
    notifyListeners();
    try {
      await document!.load(force: force);
      if (generation != _generation || !document!.loaded) return;
      final data = document!.data;
      _sites
        ..clear()
        ..addAll(
          (data['sites'] as List? ?? []).map(
            (item) =>
                JourneySite.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
      _drafts
        ..clear()
        ..addAll(
          (data['drafts'] as List? ?? []).map(
            (item) =>
                JourneyDraft.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
      _date = data['date'] == null
          ? null
          : DateTime.parse(data['date'] as String);
      _hydrated = true;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Map<String, dynamic> _snapshot() => {
    'sites': _sites.map((site) => site.toJson()).toList(),
    'drafts': _drafts.map((draft) => draft.toJson()).toList(),
    'date': _date?.toIso8601String(),
  };

  void _changed() {
    notifyListeners();
    if (document != null && _hydrated) {
      unawaited(
        document!.save(_snapshot()).then((_) => notifyListeners()).catchError((
          Object _,
        ) {
          notifyListeners();
        }),
      );
    }
  }

  Future<bool> saveDraftToDatabase() async {
    final generation = _generation;
    if (!saveDraft()) return false;
    final draft = _drafts.first;
    try {
      await document?.flush();
      return true;
    } catch (_) {
      if (generation == _generation) {
        _drafts.remove(draft);
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> deleteDraftFromDatabase(JourneyDraft draft) async {
    final generation = _generation;
    final index = _drafts.indexOf(draft);
    deleteDraft(draft);
    try {
      await document?.flush();
    } catch (_) {
      if (generation == _generation && index >= 0 && !_drafts.contains(draft)) {
        _drafts.insert(index.clamp(0, _drafts.length), draft);
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> retrySave() async {
    await document?.save(_snapshot());
    notifyListeners();
  }

  void reset() {
    _generation++;
    _sites.clear();
    _drafts.clear();
    _date = null;
    _hydrated = false;
    loading = false;
    document?.reset();
    notifyListeners();
  }

  final List<JourneySite> _sites = [];
  final List<JourneyDraft> _drafts = [];
  DateTime? _date;

  List<JourneySite> get sites => List.unmodifiable(_sites);
  List<JourneyDraft> get drafts => List.unmodifiable(_drafts);
  DateTime? get date => _date;
  String get name => journeyName(_sites);
  int get visitMinutes =>
      _sites.fold(0, (total, site) => total + (site.visitMinutes ?? 0));
  int get timedStops =>
      _sites.where((site) => site.visitMinutes != null).length;

  void addPlace(Place place) {
    final index = _sites.indexWhere((site) => site.place.id == place.id);
    if (index < 0) {
      _sites.add(JourneySite(place: place));
    } else {
      // Refresh API metadata without losing the planned visit time or order.
      _sites[index] = JourneySite(
        place: place,
        visitMinutes: _sites[index].visitMinutes,
      );
    }
    _changed();
  }

  void removePlace(String id) {
    _sites.removeWhere((site) => site.place.id == id);
    _changed();
  }

  void reorder(int oldIndex, int newIndex) {
    _sites.insert(newIndex, _sites.removeAt(oldIndex));
    _changed();
  }

  void setVisitMinutes(String id, int? minutes) {
    if (minutes != null && minutes <= 0) {
      throw ArgumentError.value(minutes, 'minutes', 'Must be positive.');
    }
    final index = _sites.indexWhere((site) => site.place.id == id);
    if (index < 0) return;
    _sites[index] = _sites[index].withVisitMinutes(minutes);
    _changed();
  }

  void setDate(DateTime? date) {
    _date = date;
    _changed();
  }

  bool saveDraft() {
    if (_sites.isEmpty) return false;
    _drafts.insert(0, JourneyDraft(name: name, sites: _sites, date: _date));
    _changed();
    return true;
  }

  void openDraft(JourneyDraft draft) {
    _sites
      ..clear()
      ..addAll(draft.sites);
    _date = draft.date;
    _changed();
  }

  void deleteDraft(JourneyDraft draft) {
    _drafts.remove(draft);
    _changed();
  }
}
