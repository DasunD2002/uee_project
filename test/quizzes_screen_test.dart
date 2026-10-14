import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/Profile/presentation/profile_screen.dart';
import 'package:uee_project/features/home/presentation/widgets/home_drawer.dart';
import 'package:uee_project/features/quizzes/data/quiz_service.dart';
import 'package:uee_project/features/quizzes/domain/quiz.dart';
import 'package:uee_project/features/quizzes/presentation/quiz_home_screen.dart';

void main() {
  late FakeQuizService service;

  setUp(() => service = FakeQuizService());

  Widget quizApp() => MaterialApp(
    home: QuizHomeScreen(quizService: service),
    routes: {
      '/home': (_) => const Scaffold(body: Text('Home')),
      '/explorer': (_) => const Scaffold(body: Text('Explore')),
      '/questions': (_) => const Scaffold(body: Text('Questions')),
      '/capsule': (_) => const Scaffold(body: Text('Capsule')),
    },
  );

  testWidgets('daily quiz completes dynamic games and reports backend score', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(quizApp());
    await tester.pumpAndSettle();
    expect(find.text('0 of 3 · 0/100 XP'), findsOneWidget);

    await tester.tap(find.byKey(const Key('play-daily-quiz')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('word-builder-stage')), findsOneWidget);

    await _dragLetter(
      tester,
      const Key('builder-letter-S-0'),
      const Key('builder-slot-0'),
    );
    for (final key in [
      'builder-letter-T-1',
      'builder-letter-U-2',
      'builder-letter-P-3',
      'builder-letter-A-4',
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const ValueKey('meaning-match-stage')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meaning-option-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const ValueKey('fill-letters-stage')), findsOneWidget);
    await _dragLetter(
      tester,
      const Key('fill-letter-G-0'),
      const Key('fill-slot-2'),
    );
    await _dragLetter(
      tester,
      const Key('fill-letter-R-1'),
      const Key('fill-slot-4'),
    );
    await _dragLetter(
      tester,
      const Key('fill-letter-Y-2'),
      const Key('fill-slot-6'),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.byKey(const Key('quiz-completed-card')), findsOneWidget);
    expect(find.text('3 of 3 · 100/100 XP'), findsOneWidget);
    expect(find.text('100 XP earned today'), findsOneWidget);
  });

  testWidgets('a letter can be dragged directly to a chosen word slot', (
    tester,
  ) async {
    await tester.pumpWidget(quizApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-daily-quiz')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await _dragLetter(
      tester,
      const Key('builder-letter-P-3'),
      const Key('builder-slot-3'),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('builder-slot-3')),
        matching: find.text('P'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('builder-slot-0')),
        matching: find.text('P'),
      ),
      findsNothing,
    );
  });

  testWidgets('wrong answers can be retried and correct answers advance now', (
    tester,
  ) async {
    await tester.pumpWidget(quizApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-daily-quiz')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    for (final key in [
      'builder-letter-S-0',
      'builder-letter-T-1',
      'builder-letter-U-2',
      'builder-letter-P-3',
      'builder-letter-A-4',
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('meaning-match-stage')), findsOneWidget);

    await tester.tap(find.byKey(const Key('meaning-option-1')));
    await tester.pump();
    expect(find.byKey(const Key('quiz-feedback-warning')), findsOneWidget);
    expect(
      find.text('Not quite. Try again while time remains.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('meaning-match-stage')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meaning-option-0')));
    await tester.pump();
    expect(find.byKey(const Key('quiz-feedback-success')), findsOneWidget);
    expect(find.text('Correct!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('fill-letters-stage')), findsOneWidget);
  });

  testWidgets('drawer Quizzes item opens the authenticated quiz dashboard', (
    tester,
  ) async {
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
        routes: {'/quizzes': (_) => QuizHomeScreen(quizService: service)},
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

  testWidgets('Profile Quizzes button opens the quiz dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
        routes: {'/quizzes': (_) => QuizHomeScreen(quizService: service)},
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

Future<void> _dragLetter(WidgetTester tester, Key source, Key target) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(source)),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await gesture.moveTo(tester.getCenter(find.byKey(target)));
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

class FakeQuizService implements QuizService {
  QuizSession? _session;
  QuizDashboard _dashboard = const QuizDashboard(
    completedSteps: 0,
    todayScore: 0,
    streakDays: 0,
    weekActivity: [false, false, false, false, false, false, false],
    weeklyLeaders: [],
  );

  @override
  Future<QuizDashboard> getDashboard() async => _dashboard;

  @override
  Future<QuizSession> startOrResume() async {
    if (_session == null || _session!.isComplete) {
      _session = _sessionForStage(0, 0);
    }
    return _session!;
  }

  @override
  Future<QuizAnswerResult> submitAnswer({
    required String sessionId,
    required String questionId,
    String? answer,
    bool timedOut = false,
  }) async {
    final current = _session!;
    final stage = current.currentStage;
    final expected = const [
      'STUPA',
      'A dome-shaped relic monument',
      'GRY',
    ][stage];
    final correct = !timedOut && answer == expected;
    if (!correct && !timedOut) {
      return QuizAnswerResult(
        correct: false,
        timedOut: false,
        completed: false,
        feedback: 'Not quite. Try again while time remains.',
        pointsAwarded: 0,
        session: current,
      );
    }

    final nextStage = stage + 1;
    final score = const [40, 70, 100][stage];
    final completed = nextStage == 3;
    _session = completed
        ? QuizSession(
            id: current.id,
            status: 'COMPLETED',
            currentStage: 3,
            completedSteps: 3,
            totalScore: score,
          )
        : _sessionForStage(nextStage, score);
    if (completed) {
      _dashboard = const QuizDashboard(
        completedSteps: 3,
        todayScore: 100,
        streakDays: 1,
        weekActivity: [true, false, false, false, false, false, false],
        weeklyLeaders: [
          QuizLeader(
            rank: 1,
            name: 'Current User',
            initials: 'CU',
            score: 100,
            viewer: true,
          ),
        ],
      );
    }
    return QuizAnswerResult(
      correct: correct,
      timedOut: timedOut,
      completed: completed,
      feedback: completed ? 'Daily challenge complete!' : 'Correct!',
      pointsAwarded: correct ? const [40, 30, 30][stage] : 0,
      session: _session!,
    );
  }

  QuizSession _sessionForStage(int stage, int score) => QuizSession(
    id: 'session-1',
    status: 'IN_PROGRESS',
    currentStage: stage,
    completedSteps: stage,
    totalScore: score,
    question: switch (stage) {
      0 => _question(
        id: 'builder-1',
        type: QuizType.wordBuilder,
        prompt: 'Dome-shaped monument enshrining a relic',
        letters: const ['S', 'T', 'U', 'P', 'A'],
        targetLength: 5,
        points: 40,
      ),
      1 => _question(
        id: 'meaning-1',
        type: QuizType.meaningMatch,
        prompt: 'What does this mean?',
        displayWord: 'dāgaba',
        options: const [
          'A dome-shaped relic monument',
          'A monastery kitchen',
          'A royal bathing pool',
          'A carved gateway stone',
        ],
        points: 30,
      ),
      _ => _question(
        id: 'fill-1',
        type: QuizType.fillLetters,
        prompt: 'The rock fortress with the lion’s paws',
        displayWord: 'SI_I_I_A',
        letters: const ['G', 'R', 'Y', 'N', 'A'],
        blankPositions: const [2, 4, 6],
        points: 30,
      ),
    },
  );

  QuizQuestion _question({
    required String id,
    required QuizType type,
    required String prompt,
    required int points,
    String displayWord = '',
    List<String> letters = const [],
    List<String> options = const [],
    List<int> blankPositions = const [],
    int targetLength = 0,
  }) => QuizQuestion(
    id: id,
    type: type,
    prompt: prompt,
    displayWord: displayWord,
    letters: letters,
    options: options,
    blankPositions: blankPositions,
    targetLength: targetLength,
    maximumPoints: points,
    deadlineAt: DateTime.now().toUtc().add(const Duration(seconds: 30)),
  );
}
