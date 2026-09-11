import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/home/presentation/home_screen.dart';
import 'package:uee_project/features/questions/domain/question.dart';
import 'package:uee_project/features/questions/domain/question_store.dart';
import 'package:uee_project/features/questions/presentation/ask_question_screen.dart';
import 'package:uee_project/features/questions/presentation/question_detail_screen.dart';
import 'package:uee_project/features/questions/presentation/questions_screen.dart';

void main() {
  setUp(QuestionStore.instance.resetForTesting);

  Widget questionsApp({Widget? home}) => MaterialApp(
    home: home ?? const QuestionsScreen(),
    routes: {
      '/home': (_) => const HomeScreen(),
      '/explorer': (_) => const Scaffold(body: Text('Explore')),
      '/capsule': (_) => const Scaffold(body: Text('Capsule')),
      '/questions': (_) => const QuestionsScreen(),
      '/ask-question': (_) => const AskQuestionScreen(),
      '/question-detail': (context) => QuestionDetailScreen(
        question:
            ModalRoute.of(context)?.settings.arguments as Question? ??
            sampleQuestions.first,
      ),
    },
  );

  testWidgets('questions support search, filtering, and voting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    expect(find.text('Ask the people who know these places'), findsOneWidget);
    expect(find.text('6 threads'), findsOneWidget);

    await tester.tap(find.byTooltip('Upvote').first);
    await tester.pump();
    expect(find.text('215'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('question-search')),
      'moonstone',
    );
    await tester.pump();
    expect(
      find.text(
        'What do the animals carved into an Anuradhapura moonstone represent?',
      ),
      findsOneWidget,
    );
    expect(find.text('1 thread'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.tap(find.text('Unanswered'));
    await tester.pump();
    expect(find.text('2 threads'), findsOneWidget);
  });

  testWidgets('a question opens the nested answer thread and accepts a reply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.tap(
      find.text(
        'What is the correct way to walk around a stupa at Polonnaruwa?',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Thread'), findsOneWidget);
    expect(find.text('Ven. Sumedha'), findsOneWidget);
    expect(find.text('Verified by heritage keeper'), findsOneWidget);
    expect(find.text('Dinuka R.'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reply-stupa-reply-dinuka')));
    await tester.pump();
    expect(find.text('Replying to Dinuka R.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('answer-composer')),
      'Please also follow the guidance posted at the temple entrance.',
    );
    await tester.tap(find.byKey(const ValueKey('post-answer-button')));
    await tester.pump();
    expect(
      find.text(
        'Please also follow the guidance posted at the temple entrance.',
      ),
      findsOneWidget,
    );
    final stored = QuestionStore.instance.questionById('stupa-walking')!;
    expect(stored.answers, hasLength(3));
    expect(
      stored.answers.first.replies.first.replies.last.body,
      'Please also follow the guidance posted at the temple entrance.',
    );
  });

  testWidgets('Ask form posts a new question into the main feed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.tap(find.byKey(const ValueKey('ask-question-button')));
    await tester.pumpAndSettle();
    expect(find.text('Ask the community'), findsOneWidget);
    expect(find.text('Write a little more to post'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('new-question-title')),
      'Why are lotus flowers offered at sacred places?',
    );
    await tester.enterText(
      find.byKey(const ValueKey('new-question-context')),
      'I saw families carrying white lotus flowers and would like to understand the meaning before my next visit.',
    );
    await tester.ensureVisible(find.text('Architecture'));
    await tester.tap(find.text('Architecture'));
    await tester.pump();
    expect(find.text('Ready to share with the community'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('post-question-button')));
    await tester.pumpAndSettle();
    expect(
      find.text('Why are lotus flowers offered at sacred places?'),
      findsOneWidget,
    );
    expect(find.text('7 threads'), findsOneWidget);
  });

  testWidgets('Home footer opens Questions', (tester) async {
    await tester.pumpWidget(questionsApp(home: const HomeScreen()));
    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();
    expect(find.text('Ask the people who know these places'), findsOneWidget);
  });
}
