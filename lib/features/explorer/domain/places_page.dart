import 'place.dart';

class PlacesPage {
  const PlacesPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.hasNext,
    required this.source,
    required this.fetchedAt,
    required this.stale,
    required this.truncated,
  });

  factory PlacesPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List<Object?>) {
      throw const FormatException('Explore places payload has no items list.');
    }

    final items = rawItems
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Explore place item is invalid.');
          }
          return Place.fromJson(item);
        })
        .toList(growable: false);

    return PlacesPage(
      items: items,
      page: _integer(json['page'], fallback: 0),
      size: _integer(json['size'], fallback: items.length),
      total: _integer(json['total'], fallback: items.length),
      hasNext: json['hasNext'] == true,
      source: json['source'] is String ? json['source'] as String : 'Unknown',
      fetchedAt: DateTime.tryParse(json['fetchedAt']?.toString() ?? ''),
      stale: json['stale'] == true,
      truncated: json['truncated'] == true,
    );
  }

  final List<Place> items;
  final int page;
  final int size;
  final int total;
  final bool hasNext;
  final String source;
  final DateTime? fetchedAt;
  final bool stale;
  final bool truncated;

  static int _integer(Object? value, {required int fallback}) =>
      value is num ? value.toInt() : fallback;
}
