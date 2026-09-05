import 'package:maplibre_gl/maplibre_gl.dart';

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.location,
    this.photoReference,
    this.rating,
  });
  final String id, name, subtitle, category;
  final LatLng location;
  final String? photoReference;
  final double? rating;
}
