import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/place.dart';

class PlacesRepository {
  static const _historyKey = 'explorer_search_history';

  static const fallbackPlaces = <Place>[
    Place(
      id: 'acropolis',
      name: 'The Acropolis',
      subtitle: 'Athens, Attica',
      category: 'Classical Era',
      location: LatLng(37.9715, 23.7257),
      rating: 4.8,
    ),
    Place(
      id: 'angkor',
      name: 'Angkor Wat',
      subtitle: 'Siem Reap',
      category: 'Khmer Empire',
      location: LatLng(13.4125, 103.8670),
      rating: 4.8,
    ),
    Place(
      id: 'gal-vihara',
      name: 'Gal Vihara',
      subtitle: 'Polonnaruwa, Sri Lanka',
      category: 'Rock Temple',
      location: LatLng(7.9668, 81.0041),
      rating: 4.7,
    ),
    Place(
      id: 'vatadage',
      name: 'Polonnaruwa Vatadage',
      subtitle: 'Polonnaruwa, Sri Lanka',
      category: 'Ancient Ruins',
      location: LatLng(7.9478, 81.0014),
      rating: 4.7,
    ),
  ];

  String? photoUrl(Place place, {int width = 900}) => null;

  Future<List<String>> history() async =>
      (await SharedPreferences.getInstance()).getStringList(_historyKey) ??
      const ['Ancient ruins', 'Rock temples'];
  Future<List<Place>> suggestions() async {
    final searches = await history();
    return search(searches.take(3).join(' cultural sites '), remember: false);
  }

  Future<void> _remember(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_historyKey) ?? <String>[];
    items.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await prefs.setStringList(_historyKey, [query, ...items].take(8).toList());
  }

  Future<List<Place>> search(String query, {bool remember = true}) async {
    if (remember) await _remember(query);
    final words = query.toLowerCase().split(RegExp(r'\s+'));
    final matches = fallbackPlaces.where((place) {
      final value = '${place.name} ${place.subtitle} ${place.category}'.toLowerCase();
      return words.any((word) => word.length > 2 && value.contains(word));
    }).toList();
    return matches.isEmpty ? fallbackPlaces : matches;
  }
}
