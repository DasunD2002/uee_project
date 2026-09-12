import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/core/widgets/feed_post_card.dart';
import 'package:uee_project/features/home/presentation/widgets/home_drawer.dart';
import 'package:uee_project/features/explorer/presentation/widgets/explorer_footer.dart';

void main() {
  testWidgets('feed actions and comments work at narrow phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var edits = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FeedPostCard(
              media: const ColoredBox(color: Colors.orange),
              category: 'Cultural Craft',
              title: 'Mask carvers',
              location: 'Ambalangoda, Sri Lanka',
              description:
                  'Step into the workshop where tradition meets artistry.',
              likes: '1,200',
              comments: '96',
              onEdit: () => edits++,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Like post'));
    await tester.pump();
    expect(find.text('1,201 Likes · 96 Comments'), findsOneWidget);
    await tester.tap(find.byTooltip('Save post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hill Country Trails'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unsave post'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Beautiful craft');
    await tester.tap(find.byTooltip('Post comment'));
    await tester.pump();
    expect(find.text('1,201 Likes · 97 Comments'), findsOneWidget);
    expect(
      find.textContaining('Beautiful craft', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Edit post'));
    expect(edits, 1);
  });

  testWidgets('drawer selects the current named route', (tester) async {
    const sections = {
      '/home': 'Home',
      '/explorer': 'Explore Places',
      '/profile': 'Profile',
      '/saved-posts': 'Saved posts',
      '/capsules': 'Time capsule',
      '/province-map': 'Explore Things With 3D Map',
    };
    for (final section in sections.entries) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(section.key),
          initialRoute: section.key,
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const Scaffold(body: HomeDrawer()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(section.value),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      final selected = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .where((tile) => tile.selected)
          .toList();
      expect(selected, hasLength(1));
      expect((selected.single.title! as Text).data, section.value);
    }
  });

  testWidgets(
    'profile footer has no selected destination and still navigates',
    (tester) async {
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: ExplorerFooter(
              selectedIndex: null,
              onSelected: (i) => tapped = i,
            ),
          ),
        ),
      );
      expect(find.byType(NavigationBar), findsNothing);
      await tester.tap(find.text('Home'));
      expect(tapped, 0);
      await tester.tap(find.text('Explore'));
      expect(tapped, 1);
    },
  );
}
