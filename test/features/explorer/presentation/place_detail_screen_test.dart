import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uee_project/features/explorer/data/places_repository.dart';
import 'package:uee_project/features/explorer/domain/place.dart';
import 'package:uee_project/features/explorer/presentation/place_detail_screen.dart';
import 'package:uee_project/features/explorer/presentation/widgets/place_image.dart';

void main() {
  testWidgets('shows the selected place narrative and its own photo', (
    tester,
  ) async {
    const narrative =
        'Gal Vihara is a rock temple in Polonnaruwa.\n\n'
        'Its carved Buddha figures are a defining part of the site.';
    const photo = 'https://upload.wikimedia.org/photo.jpg';
    final summary = {
      'id': 'Q100',
      'name': 'Gal Vihara',
      'subtitle': 'Polonnaruwa, Sri Lanka',
      'category': 'Sacred Sites',
      'categoryId': 'sacred-sites',
      'location': {'latitude': 7.9668, 'longitude': 81.0041},
      'description': 'Rock temple',
    };
    final repository = PlacesRepository(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/explore/places/Q100');
        return http.Response(
          jsonEncode({
            ...summary,
            'description': narrative,
            'imageUrl': photo,
            'imageSourceUrl': 'https://en.wikipedia.org/wiki/File:photo.jpg',
            'sourceUrl': 'https://www.wikidata.org/wiki/Q100',
            'wikipediaUrl': 'https://en.wikipedia.org/wiki/Gal_Vihara',
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PlaceDetailScreen(
          place: Place.fromJson(summary),
          repository: repository,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Historical Narrative'), findsOneWidget);
    expect(find.text(narrative), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is PlaceImage && widget.url == photo,
      ),
      findsOneWidget,
    );
  });
}
