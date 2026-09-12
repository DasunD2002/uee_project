import 'package:flutter/foundation.dart';

import '../domain/journey.dart';
import '../domain/place.dart';

class JourneyStore extends ChangeNotifier {
  JourneyStore();

  static final instance = JourneyStore();

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
    notifyListeners();
  }

  void removePlace(String id) {
    _sites.removeWhere((site) => site.place.id == id);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    _sites.insert(newIndex, _sites.removeAt(oldIndex));
    notifyListeners();
  }

  void setVisitMinutes(String id, int? minutes) {
    if (minutes != null && minutes <= 0) {
      throw ArgumentError.value(minutes, 'minutes', 'Must be positive.');
    }
    final index = _sites.indexWhere((site) => site.place.id == id);
    if (index < 0) return;
    _sites[index] = _sites[index].withVisitMinutes(minutes);
    notifyListeners();
  }

  void setDate(DateTime? date) {
    _date = date;
    notifyListeners();
  }

  bool saveDraft() {
    if (_sites.isEmpty) return false;
    _drafts.insert(0, JourneyDraft(name: name, sites: _sites, date: _date));
    notifyListeners();
    return true;
  }

  void openDraft(JourneyDraft draft) {
    _sites
      ..clear()
      ..addAll(draft.sites);
    _date = draft.date;
    notifyListeners();
  }

  void deleteDraft(JourneyDraft draft) {
    _drafts.remove(draft);
    notifyListeners();
  }
}
