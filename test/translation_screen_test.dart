import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/home/presentation/widgets/home_drawer.dart';
import 'package:uee_project/features/translations/presentation/translation_screen.dart';

void main() {
  Widget translationApp({Widget? home}) => MaterialApp(
    home: home ?? const TranslationScreen(),
    routes: {
      '/translations': (_) => const TranslationScreen(),
      '/notifications': (_) => const Scaffold(body: Text('Notifications')),
      '/home': (_) => const Scaffold(body: Text('Home destination')),
      '/explorer': (_) => const Scaffold(body: Text('Explore destination')),
      '/questions': (_) => const Scaffold(body: Text('Questions destination')),
      '/capsule': (_) => const Scaffold(body: Text('Capsule destination')),
    },
  );

  testWidgets('translation lookup, language swap, and glossary work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(translationApp());
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Isthūpa'), findsOneWidget);
    expect(find.text('Word details'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('translation-input')),
      'temple',
    );
    await tester.pump();
    expect(find.text('Pansala'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('swap-translation-languages')));
    await tester.pump();
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('translation-input')),
    );
    expect(field.controller!.text, 'පන්සල');

    await tester.scrollUntilVisible(
      find.text('Recent lookups'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent lookups'), findsOneWidget);
  });

  testWidgets('drawer Translation item opens the translation page', (
    tester,
  ) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      translationApp(
        home: Scaffold(
          key: scaffoldKey,
          drawer: const HomeDrawer(selectedSection: 'Home'),
          body: const SizedBox(),
        ),
      ),
    );

    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Translation'));
    await tester.pumpAndSettle();
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Isthūpa'), findsOneWidget);
  });

  testWidgets('translation footer navigates to primary destinations', (
    tester,
  ) async {
    await tester.pumpWidget(translationApp());
    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();
    expect(find.text('Questions destination'), findsOneWidget);
  });
}
