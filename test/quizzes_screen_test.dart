import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/quizzes/domain/quiz_progress_store.dart';
import 'package:uee_project/features/quizzes/presentation/daily_quiz_screen.dart';
import 'package:uee_project/features/quizzes/presentation/quiz_home_screen.dart';
import 'package:uee_project/features/Profile/presentation/profile_screen.dart';
import 'package:uee_project/features/home/presentation/widgets/home_drawer.dart';

void main() {
  setUp(() => QuizProgressStore.instance.reset());

  Widget quizApp() => MaterialApp(
    initialRoute: '/quizzes',
    routes: {
      '/quizzes': (_) => const QuizHomeScreen(),
      '/daily-quiz': (_) => const DailyQuizScreen(),
      '/home': (_) => const Scaffold(body: Text('Home')),
      '/explorer': (_) => const Scaffold(body: Text('Explore')),
      '/questions': (_) => const Scaffold(body: Text('Questions')),
      '/capsule': (_) => const Scaffold(body: Text('Capsule')),
    },
  );

  testWidgets('daily quiz completes all three games and reports the score', (
    tester,
  ) async {
    await tester.pumpWidget(quizApp());

    expect(find.text('Daily challenge'), findsOneWidget);
    expect(find.text('0 of 3 · 0/100 XP'), findsOneWidget);

    await tester.tap(find.byKey(const Key('play-daily-quiz')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('word-builder-stage')), findsOneWidget);
    expect(find.byType(LongPressDraggable<int>), findsNWidgets(5));

    final drag = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('builder-letter-S'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await drag.moveTo(
      tester.getCenter(find.byKey(const Key('word-builder-drop-zone'))),
    );
    await tester.pump();
    await drag.up();
    await tester.pump();

    for (final letter in ['T', 'U', 'P', 'A']) {
      await tester.tap(find.byKey(Key('builder-letter-$letter')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('meaning-match-stage')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meaning-option-0')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fill-letters-stage')), findsOneWidget);
    for (final key in ['fill-letter-G-0', 'fill-letter-R-2', 'fill-letter-Y-4']) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-completed-card')), findsOneWidget);
    expect(find.text('3 of 3 · 100/100 XP'), findsOneWidget);
    expect(find.text('100 XP earned today'), findsOneWidget);
  });

  testWidgets('word builder only advances for the exact word', (tester) async {
    await tester.pumpWidget(quizApp());
    await tester.tap(find.byKey(const Key('play-daily-quiz')));
    await tester.pumpAndSettle();

    for (final letter in ['P', 'S', 'A', 'T', 'U']) {
      await tester.tap(find.byKey(Key('builder-letter-$letter')));
      await tester.pump();
    }

    expect(find.byKey(const ValueKey('word-builder-stage')), findsOneWidget);
    expect(
      find.text('Not quite — undo a letter and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('drawer Quizzes item opens the quiz main page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                key: const Key('open-drawer'),
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
          ),
          drawer: const HomeDrawer(),
        ),
        routes: {'/quizzes': (_) => const QuizHomeScreen()},
      ),
    );

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Quizzes'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Quizzes'));
    await tester.pumpAndSettle();

    expect(find.text('Daily challenge'), findsOneWidget);
  });

  testWidgets('Profile Quizzes button opens the quiz main page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
        routes: {'/quizzes': (_) => const QuizHomeScreen()},
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quizzes'));
    await tester.pumpAndSettle();

    expect(find.text('Daily challenge'), findsOneWidget);
  });
}
