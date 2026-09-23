import 'places_page.dart';

class ProvinceProfile {
  const ProvinceProfile({
    required this.id,
    required this.name,
    required this.districts,
    this.description,
    this.capital,
    this.imageUrl,
    this.imageSourceUrl,
    this.sourceUrl,
    this.wikipediaUrl,
  });

  factory ProvinceProfile.fromJson(Map<String, dynamic> json) =>
      ProvinceProfile(
        id: _requiredString(json, 'id'),
        name: _requiredString(json, 'name'),
        districts: _strings(json['districts']),
        description: _optionalString(json['description']),
        capital: _optionalString(json['capital']),
        imageUrl: _optionalString(json['imageUrl']),
        imageSourceUrl: _optionalString(json['imageSourceUrl']),
        sourceUrl: _optionalString(json['sourceUrl']),
        wikipediaUrl: _optionalString(json['wikipediaUrl']),
      );

  final String id, name;
  final List<String> districts;
  final String? description,
      capital,
      imageUrl,
      imageSourceUrl,
      sourceUrl,
      wikipediaUrl;

  String get overview => [
    ?description,
    if (capital != null) 'Provincial capital: $capital.',
    if (districts.isNotEmpty) 'Districts: ${districts.join(', ')}.',
  ].join('\n\n');
}

class ProvinceTradition {
  const ProvinceTradition({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.imageSourceUrl,
    this.sourceUrl,
    this.wikipediaUrl,
  });

  factory ProvinceTradition.fromJson(Map<String, dynamic> json) =>
      ProvinceTradition(
        id: _requiredString(json, 'id'),
        name: _requiredString(json, 'name'),
        description: _optionalString(json['description']),
        imageUrl: _optionalString(json['imageUrl']),
        imageSourceUrl: _optionalString(json['imageSourceUrl']),
        sourceUrl: _optionalString(json['sourceUrl']),
        wikipediaUrl: _optionalString(json['wikipediaUrl']),
      );

  final String id, name;
  final String? description, imageUrl, imageSourceUrl, sourceUrl, wikipediaUrl;
}

class ProvinceDetails {
  const ProvinceDetails({
    required this.province,
    required this.places,
    required this.traditions,
  });

  factory ProvinceDetails.fromJson(Map<String, dynamic> json) {
    final province = json['province'];
    final places = json['places'];
    final traditions = json['traditions'];
    if (province is! Map<String, dynamic> ||
        places is! Map<String, dynamic> ||
        traditions is! List<Object?>) {
      throw const FormatException('Province response is incomplete.');
    }
    return ProvinceDetails(
      province: ProvinceProfile.fromJson(province),
      places: PlacesPage.fromJson(places),
      traditions: traditions
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Province tradition is invalid.');
            }
            return ProvinceTradition.fromJson(item);
          })
          .toList(growable: false),
    );
  }

  final ProvinceProfile province;
  final PlacesPage places;
  final List<ProvinceTradition> traditions;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _optionalString(json[key]);
  if (value == null) throw FormatException('Province field "$key" is invalid.');
  return value;
}

String? _optionalString(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;

List<String> _strings(Object? value) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw const FormatException('Province districts are invalid.');
  }
  return value.cast<String>().toList(growable: false);
}
