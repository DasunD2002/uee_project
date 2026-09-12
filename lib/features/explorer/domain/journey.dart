import 'place.dart';

class JourneySite {
  const JourneySite({required this.place, this.visitMinutes});

  final Place place;
  final int? visitMinutes;

  JourneySite withVisitMinutes(int? minutes) =>
      JourneySite(place: place, visitMinutes: minutes);
}

class JourneyDraft {
  JourneyDraft({
    required this.name,
    required List<JourneySite> sites,
    this.date,
  }) : sites = List.unmodifiable(sites);

  final String name;
  final List<JourneySite> sites;
  final DateTime? date;
}

String journeyName(List<JourneySite> sites) {
  final locations = sites.map((site) => site.place.subtitle).toSet();
  if (locations.length == 1) {
    return 'Journey to ${locations.single.split(',').first.trim()}';
  }
  return 'My Heritage Journey';
}

String formatVisitMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '$remainder min';
  if (remainder == 0) return '$hours hr';
  return '$hours hr $remainder min';
}
