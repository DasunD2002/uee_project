import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/explorer/presentation/widgets/place_image.dart';

void main() {
  test(
    'old Commons references request the supported size and preserve filenames',
    () {
      final url = Uri.parse(
        PlaceImage.displayUrl(
          'https://commons.wikimedia.org/wiki/Special:FilePath/Temple%20A%2BB.jpg?width=900',
        ),
      );
      expect(url.queryParameters['width'], '960');
      expect(
        Uri.decodeComponent(url.path),
        '/wiki/Special:FilePath/Temple A+B.jpg',
      );
    },
  );

  test('old thumbnail hosts and unsupported sizes use the current CDN', () {
    expect(
      PlaceImage.displayUrl(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Temple.jpg/1200px-Temple.jpg',
      ),
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/ab/Temple.jpg/960px-Temple.jpg',
    );
    expect(
      PlaceImage.displayUrl(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Temple%20A%2BB.jpg/1200px-Temple%20A%2BB.jpg',
      ),
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/ab/Temple%20A%2BB.jpg/960px-Temple%20A%2BB.jpg',
    );
    expect(
      PlaceImage.displayUrl('https://example.com/my-photo.jpg'),
      'https://example.com/my-photo.jpg',
    );
  });

  testWidgets('missing photos never show a decorative placeholder image', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PlaceImage(url: null)));
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.account_balance), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('failed photos have an explicit retry instead of fake scenery', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 140,
            child: PlaceImage(url: 'https://example.com/missing.jpg'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry photo'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsNothing);
    await tester.tap(find.text('Retry photo'));
    await tester.pumpAndSettle();
    expect(find.text('Retry photo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
