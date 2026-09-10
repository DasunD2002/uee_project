import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uee_project/features/Profile/presentation/widgets/profile_header.dart';
import 'package:uee_project/features/Post Creation/domain/user_post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/Profile/presentation/profile_screen.dart';
import 'package:uee_project/features/Post Creation/presentation/create_post_screen.dart';
import 'package:uee_project/features/home/presentation/home_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('create and edit back buttons return to the previous screen', (
    tester,
  ) async {
    for (final post in <UserPost?>[
      null,
      UserPost(id: 'back-test', title: 'Story', story: 'Test'),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CreatePostScreen(post: post),
                  ),
                ),
                child: const Text('Open editor'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open editor'), findsOneWidget);
      expect(find.byType(CreatePostScreen), findsNothing);
    }
  });

  testWidgets('profile uses one cover and restores both saved photos', (
    tester,
  ) async {
    final data = await rootBundle.load('assets/images/profile_avatar.png');
    final encoded = base64Encode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    SharedPreferences.setMockInitialValues({
      'profile.avatar': encoded,
      'profile.cover': encoded,
    });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileHeader(postCount: 48))),
    );
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(
      find.byKey(const ValueKey('profile-cover')),
    );
    expect(image.image, isA<MemoryImage>());
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage,
      isA<MemoryImage>(),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Change profile photo',
            ),
          )
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Change cover photo',
            ),
          )
          .onPressed,
      isNotNull,
    );
  });
  Future<void> openProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(428, 926);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/profile': (_) => const ProfileScreen(),
          '/saved-posts': (_) => const ProfileScreen(showSavedPosts: true),
        },
      ),
    );
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
  }

  testWidgets('drawer opens profile and saved collections can be created', (
    tester,
  ) async {
    await openProfile(tester);
    expect(find.text('Amaya Wickrama'), findsOneWidget);
    await tester.tap(find.text('Saved posts'));
    await tester.pumpAndSettle();
    expect(find.text('6 collections · 102 saved stories'), findsOneWidget);
    await tester.tap(find.text('Create Collection'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My heritage trail');
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('7 collections · 102 saved stories'), findsOneWidget);
  });

  testWidgets('draft returns to profile and can be edited and deleted', (
    tester,
  ) async {
    await openProfile(tester);
    await tester.tap(find.text('Create Post'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'A new draft');
    await tester.scrollUntilVisible(
      find.text('Save as Draft'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save as Draft'));
    await tester.pumpAndSettle();
    expect(find.text('A new draft'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.scrollUntilVisible(
      find.text('Edit post').first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Edit post').first),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit post').first);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'A new draft',
    );
    await tester.scrollUntilVisible(
      find.text('Delete Post'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Delete Post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('A new draft'), findsNothing);
  });

  testWidgets('publishing validates required fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreatePostScreen()));
    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'Create Post'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Post'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Enter a title'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Enter a title'), findsOneWidget);
    expect(find.byType(CreatePostScreen), findsOneWidget);
  });
}
