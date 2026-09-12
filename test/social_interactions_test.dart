import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uee_project/core/widgets/auth_widgets.dart';
import 'package:uee_project/features/Profile/domain/social_store.dart';
import 'package:uee_project/features/Profile/presentation/public_profile_screen.dart';
import 'package:uee_project/features/Profile/presentation/widgets/profile_header.dart';
import 'package:uee_project/features/home/presentation/widgets/story_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final store = SocialStore.instance;
    store.collections.removeRange(6, store.collections.length);
    for (final c in store.collections) {
      c.stories.clear();
    }
    store.likedPosts.clear();
    store.comments.clear();
    store.reports.clear();
  });
  Future<void> feed(WidgetTester tester) async {
    tester.view.physicalSize = const Size(428, 926);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StoryCard(
              category: 'Craft',
              imagePath: 'assets/images/mask_carver.png',
              title: 'Mask carvers',
              location: 'Ambalangoda',
              description: 'Our traditional craft.',
              likes: '100',
              comments: '2',
              author: 'Dinesh',
              handle: '@dineshcarves',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('author opens public profile without owner controls', (
    tester,
  ) async {
    await feed(tester);
    await tester.tap(find.textContaining('@dineshcarves', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.byType(PublicProfileScreen), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Edit post'), findsNothing);
    expect(find.text('Saved posts'), findsNothing);
    expect(find.text('Edit Profile Data'), findsNothing);
  });
  testWidgets('double tap likes once and comments opens other users comments', (
    tester,
  ) async {
    await feed(tester);
    final media = find.byWidgetPredicate(
      (w) => w is GestureDetector && w.onDoubleTap != null,
    );
    await tester.tap(media);
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(media);
    await tester.pumpAndSettle();
    expect(find.text('101 Likes · 2 Comments'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(media);
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(media);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('101 Likes · 2 Comments'), findsOneWidget);
    expect(find.byIcon(Icons.send_outlined), findsNothing);
    await tester.tap(find.byTooltip('Comment'));
    await tester.pumpAndSettle();
    expect(find.text('Nimal'), findsOneWidget);
    expect(find.text('Sanduni'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Wonderful story');
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();
    expect(find.text('Wonderful story'), findsOneWidget);
  });
  testWidgets('post menu offers only report and records chosen reason', (
    tester,
  ) async {
    await feed(tester);
    await tester.tap(find.byTooltip('Post options'));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<String>), findsOneWidget);
    await tester.tap(find.text('Report the post'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spam').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(SocialStore.instance.reports.values, contains('Spam'));
  });
  testWidgets('bookmark creates a collection and saves the actual story', (
    tester,
  ) async {
    await feed(tester);
    await tester.tap(find.byTooltip('Save post'));
    await tester.pumpAndSettle();
    expect(find.text('Hill Country Trails'), findsOneWidget);
    await tester.tap(find.text('Create New collection'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'My craft stories');
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final collection = SocialStore.instance.collections.last;
    expect(collection.name, 'My craft stories');
    expect(collection.stories.values.single.title, 'Mask carvers');
    expect(find.byTooltip('Unsave post'), findsOneWidget);
  });
  testWidgets('profile data editor updates header and local storage', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProfileHeader(postCount: 48)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Profile Data'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Amaya Perera');
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Amaya Perera'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(
      (jsonDecode(prefs.getString('profile.details')!) as Map)['name'],
      'Amaya Perera',
    );
  });
  testWidgets('auth boxes have subtle outline and a colored focused border', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AuthField(label: 'Email')),
      ),
    );
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.decoration!.enabledBorder, isA<OutlineInputBorder>());
    expect(
      input.decoration!.focusedBorder!.borderSide.color,
      isNot(input.decoration!.enabledBorder!.borderSide.color),
    );
    await tester.enterText(find.byType(TextFormField), 'amaya@example.com');
    expect(find.text('amaya@example.com'), findsOneWidget);
  });
}
