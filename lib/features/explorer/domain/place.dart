import 'package:maplibre_gl/maplibre_gl.dart';

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.categoryId,
    required this.location,
    this.description,
    this.imageUrl,
    this.imageSourceUrl,
    this.sourceUrl,
    this.wikipediaUrl,
    this.photoReference,
    this.rating,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'];
    if (rawLocation is! Map<String, dynamic>) {
      throw const FormatException('Place location is missing or invalid.');
    }

    final latitude = rawLocation['latitude'];
    final longitude = rawLocation['longitude'];
    if (latitude is! num || longitude is! num) {
      throw const FormatException('Place coordinates are missing or invalid.');
    }

    return Place(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      subtitle: _requiredString(json, 'subtitle'),
      category: _requiredString(json, 'category'),
      categoryId: _requiredString(json, 'categoryId'),
      location: LatLng(latitude.toDouble(), longitude.toDouble()),
      description: _optionalString(json['description']),
      imageUrl: _optionalString(json['imageUrl']),
      imageSourceUrl: _optionalString(json['imageSourceUrl']),
      sourceUrl: _optionalString(json['sourceUrl']),
      wikipediaUrl: _optionalString(json['wikipediaUrl']),
    );
  }

  final String id;
  final String name;
  final String subtitle;
  final String category;
  final String categoryId;
  final LatLng location;
  final String? description;
  final String? imageUrl;
  final String? imageSourceUrl;
  final String? sourceUrl;
  final String? wikipediaUrl;
  final String? photoReference;
  final double? rating;

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = _optionalString(json[key]);
    if (value == null) {
      throw FormatException('Place field "$key" is missing or invalid.');
    }
    return value;
  }

  static String? _optionalString(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
