import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/core/theme/app_colors.dart';
import 'package:uee_project/features/home/presentation/home_screen.dart';
import 'package:uee_project/features/questions/data/question_service.dart';
import 'package:uee_project/features/questions/domain/question.dart';
import 'package:uee_project/features/questions/presentation/ask_question_screen.dart';
import 'package:uee_project/features/questions/presentation/question_detail_screen.dart';
import 'package:uee_project/features/questions/presentation/questions_screen.dart';

void main() {
  late FakeQuestionService service;

  setUp(() => service = FakeQuestionService());

  Widget questionsApp({Widget? home}) => MaterialApp(
    home: home ?? QuestionsScreen(questionService: service),
    routes: {
      '/home': (_) => const HomeScreen(),
      '/explorer': (_) => const Scaffold(body: Text('Explore')),
      '/capsule': (_) => const Scaffold(body: Text('Capsule')),
      '/questions': (_) => QuestionsScreen(questionService: service),
      '/ask-question': (_) => AskQuestionScreen(questionService: service),
      '/question-detail': (context) => QuestionDetailScreen(
        questionId: ModalRoute.of(context)!.settings.arguments! as String,
        questionService: service,
      ),
    },
  );

  testWidgets('questions load, search, and persist votes through the service', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.pumpAndSettle();
    expect(find.text('2 threads'), findsOneWidget);

    await tester.tap(find.byTooltip('Upvote').first);
    await tester.pumpAndSettle();
    expect(service.questions.first.voteScore, 11);

    await tester.enterText(
      find.byKey(const ValueKey('question-search')),
      'moonstone',
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(find.text('1 thread'), findsOneWidget);
    expect(find.textContaining('moonstone'), findsWidgets);
  });

  testWidgets('thread loads from the API service and accepts a nested reply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('walk around a stupa'));
    await tester.pumpAndSettle();
    expect(find.text('Ven. Sumedha'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reply-answer-1')));
    await tester.enterText(
      find.byKey(const ValueKey('answer-composer')),
      'Please follow the guidance at the temple entrance.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('post-answer-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Please follow the guidance at the temple entrance.'),
      findsOneWidget,
    );
    expect(service.questions.first.answers.first.replies, hasLength(1));
  });

  testWidgets(
    'answer button enables and turns brown only when text is entered',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(questionsApp());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('walk around a stupa'));
      await tester.pumpAndSettle();

      var button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('post-answer-button')),
      );
      expect(button.onPressed, isNull);
      expect(
        button.style!.backgroundColor!.resolve({WidgetState.disabled}),
        const Color(0xFFE8D9C6),
      );

      await tester.enterText(
        find.byKey(const ValueKey('answer-composer')),
        'A helpful answer',
      );
      await tester.pump();

      button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('post-answer-button')),
      );
      expect(button.onPressed, isNotNull);
      expect(button.style!.backgroundColor!.resolve({}), AppColors.brown);

      await tester.enterText(
        find.byKey(const ValueKey('answer-composer')),
        '   ',
      );
      await tester.pump();
      button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('post-answer-button')),
      );
      expect(button.onPressed, isNull);
    },
  );

  testWidgets('Ask form creates a backend question and refreshes the feed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ask-question-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('new-question-title')),
      'Why are lotus flowers offered at sacred places?',
    );
    await tester.enterText(
      find.byKey(const ValueKey('new-question-context')),
      'I saw families carrying white lotus flowers and would like to understand their meaning.',
    );
    tester.testTextInput.hide();
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('post-question-button')),
    );
    await tester.tap(find.byKey(const ValueKey('post-question-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Why are lotus flowers offered at sacred places?'),
      findsOneWidget,
    );
    expect(service.questions, hasLength(3));
  });

  testWidgets('owners can edit and delete their question', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('walk around a stupa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Question actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit question'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('new-question-title')),
      'What is the respectful way to walk around a stupa?',
    );
    tester.testTextInput.hide();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('post-question-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('respectful way'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Question actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete question'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(service.questions, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('owners can edit and delete a comment without lifecycle errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(questionsApp());
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('walk around a stupa'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Comment actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit comment'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('edit-comment-body')),
      'Walk clockwise and follow the signs at the entrance.',
    );
    tester.testTextInput.hide();
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Walk clockwise and follow the signs at the entrance.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Comment actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete comment'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      find.text('Walk clockwise and follow the signs at the entrance.'),
      findsNothing,
    );
    expect(service.questions.first.answers, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home footer opens Questions', (tester) async {
    await tester.pumpWidget(questionsApp(home: const HomeScreen()));
    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();
    expect(find.text('Ask the people who know these places'), findsOneWidget);
  });
}

class FakeQuestionService implements QuestionService {
  FakeQuestionService() : questions = [_stupaQuestion(), _moonstoneQuestion()];

  final List<Question> questions;

  @override
  Future<QuestionPage> getQuestions({
    String query = '',
    String? category,
    String sort = 'top',
    int page = 0,
    int size = 20,
  }) async {
    var items = questions.where((question) {
      final text = '${question.title} ${question.body}'.toLowerCase();
      final matchesQuery = text.contains(query.toLowerCase());
      final matchesCategory =
          category == null || question.categoryId == category;
      final matchesUnanswered =
          sort != 'unanswered' || question.commentCount == 0;
      return matchesQuery && matchesCategory && matchesUnanswered;
    }).toList();
    if (sort == 'top') {
      items.sort((a, b) => b.voteScore.compareTo(a.voteScore));
    }
    return QuestionPage(
      items: items,
      page: 0,
      size: size,
      total: items.length,
      hasNext: false,
    );
  }

  @override
  Future<Question> getQuestion(
    String questionId, {
    String sort = 'top',
  }) async => questions.firstWhere((question) => question.id == questionId);

  @override
  Future<Question> createQuestion({
    required String title,
    required String body,
    required String location,
    required String category,
    String? placeId,
  }) async {
    final question = _question(
      id: 'question-${questions.length + 1}',
      title: title,
      body: body,
      location: location,
      category: _categoryName(category),
      categoryId: category,
    );
    questions.insert(0, question);
    return question;
  }

  @override
  Future<void> updateQuestion({
    required String questionId,
    required String title,
    required String body,
    required String location,
    required String category,
    String? placeId,
  }) async {
    final index = questions.indexWhere((question) => question.id == questionId);
    final current = questions[index];
    questions[index] = _question(
      id: current.id,
      title: title,
      body: body,
      location: location,
      category: _categoryName(category),
      categoryId: category,
      answers: current.answers,
      voteScore: current.voteScore,
    );
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    questions.removeWhere((question) => question.id == questionId);
  }

  @override
  Future<QuestionAnswer> createComment({
    required String questionId,
    required String body,
    String? parentCommentId,
  }) async {
    final answer = _answer(
      id: 'answer-new',
      questionId: questionId,
      body: body,
      author: 'Current User',
      ownedByViewer: true,
      parentCommentId: parentCommentId,
    );
    final index = questions.indexWhere((question) => question.id == questionId);
    final current = questions[index];
    final answers = parentCommentId == null
        ? [...current.answers, answer]
        : _appendReply(current.answers, parentCommentId, answer);
    questions[index] = current.copyWith(
      answers: answers,
      commentCount: parentCommentId == null
          ? current.commentCount + 1
          : current.commentCount,
    );
    return answer;
  }

  @override
  Future<QuestionAnswer> updateComment({
    required String commentId,
    required String body,
  }) async {
    QuestionAnswer? updated;
    for (var index = 0; index < questions.length; index++) {
      final current = questions[index];
      final answers = _updateAnswer(current.answers, commentId, body, (value) {
        updated = value;
      });
      questions[index] = current.copyWith(answers: answers);
    }
    return updated!;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    for (var index = 0; index < questions.length; index++) {
      final current = questions[index];
      final answers = _removeAnswer(current.answers, commentId);
      questions[index] = current.copyWith(
        answers: answers,
        commentCount: answers.length,
      );
    }
  }

  @override
  Future<ForumVoteResult> voteQuestion(String questionId, int value) async {
    final index = questions.indexWhere((question) => question.id == questionId);
    final current = questions[index];
    final score = current.voteScore + value - current.viewerVote;
    questions[index] = current.copyWith(voteScore: score, viewerVote: value);
    return ForumVoteResult(
      targetId: questionId,
      voteScore: score,
      viewerVote: value,
    );
  }

  @override
  Future<ForumVoteResult> voteComment(String commentId, int value) async =>
      ForumVoteResult(targetId: commentId, voteScore: value, viewerVote: value);

  @override
  Future<bool> setBookmark(
    String questionId, {
    required bool bookmarked,
  }) async => bookmarked;
}

Question _stupaQuestion() => _question(
  id: 'stupa-walking',
  title: 'What is the correct way to walk around a stupa at Polonnaruwa?',
  body: 'I would like to understand the respectful custom before visiting.',
  location: 'Polonnaruwa',
  category: 'Rituals & Etiquette',
  categoryId: 'rituals-etiquette',
  voteScore: 10,
  answers: [
    _answer(
      id: 'answer-1',
      questionId: 'stupa-walking',
      body: 'Walk clockwise while keeping the stupa to your right.',
      author: 'Ven. Sumedha',
      ownedByViewer: true,
    ),
  ],
);

Question _moonstoneQuestion() => _question(
  id: 'moonstone',
  title: 'What do the animals carved into a moonstone represent?',
  body:
      'I noticed that moonstones from different periods use different animals.',
  location: 'Anuradhapura',
  category: 'History',
  categoryId: 'history',
  voteScore: 4,
  answers: const [],
);

Question _question({
  required String id,
  required String title,
  required String body,
  required String location,
  required String category,
  required String categoryId,
  int voteScore = 0,
  List<QuestionAnswer> answers = const [],
}) => Question(
  id: id,
  title: title,
  body: body,
  location: location,
  placeId: null,
  category: category,
  categoryId: categoryId,
  authorDetails: const ForumAuthor(
    id: 'user-1',
    name: 'Amaya Perera',
    initials: 'AP',
    role: 'Community member',
    photoUrl: null,
    verified: false,
  ),
  voteScore: voteScore,
  commentCount: answers.length,
  answers: answers,
  verified: false,
  viewerVote: 0,
  bookmarked: false,
  ownedByViewer: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

QuestionAnswer _answer({
  required String id,
  required String questionId,
  required String body,
  String author = 'Contributor',
  String? parentCommentId,
  bool ownedByViewer = false,
  List<QuestionAnswer> replies = const [],
}) => QuestionAnswer(
  id: id,
  questionId: questionId,
  parentCommentId: parentCommentId,
  authorDetails: ForumAuthor(
    id: 'author-$id',
    name: author,
    initials: author.split(' ').map((part) => part[0]).take(2).join(),
    role: 'Community member',
    photoUrl: null,
    verified: false,
  ),
  body: body,
  voteScore: 0,
  viewerVote: 0,
  accepted: false,
  verified: false,
  deleted: false,
  ownedByViewer: ownedByViewer,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  replies: replies,
);

List<QuestionAnswer> _appendReply(
  List<QuestionAnswer> answers,
  String parentId,
  QuestionAnswer reply,
) => [
  for (final answer in answers)
    if (answer.id == parentId)
      _answer(
        id: answer.id,
        questionId: answer.questionId,
        body: answer.body,
        author: answer.author,
        parentCommentId: answer.parentCommentId,
        ownedByViewer: answer.ownedByViewer,
        replies: [...answer.replies, reply],
      )
    else
      _answer(
        id: answer.id,
        questionId: answer.questionId,
        body: answer.body,
        author: answer.author,
        parentCommentId: answer.parentCommentId,
        ownedByViewer: answer.ownedByViewer,
        replies: _appendReply(answer.replies, parentId, reply),
      ),
];

List<QuestionAnswer> _updateAnswer(
  List<QuestionAnswer> answers,
  String commentId,
  String body,
  ValueChanged<QuestionAnswer> onUpdated,
) => [
  for (final answer in answers)
    if (answer.id == commentId)
      _copyAnswer(answer, body: body).also(onUpdated)
    else
      _copyAnswer(
        answer,
        replies: _updateAnswer(answer.replies, commentId, body, onUpdated),
      ),
];

List<QuestionAnswer> _removeAnswer(
  List<QuestionAnswer> answers,
  String commentId,
) => [
  for (final answer in answers)
    if (answer.id != commentId)
      _copyAnswer(answer, replies: _removeAnswer(answer.replies, commentId)),
];

QuestionAnswer _copyAnswer(
  QuestionAnswer answer, {
  String? body,
  List<QuestionAnswer>? replies,
}) => QuestionAnswer(
  id: answer.id,
  questionId: answer.questionId,
  parentCommentId: answer.parentCommentId,
  authorDetails: answer.authorDetails,
  body: body ?? answer.body,
  voteScore: answer.voteScore,
  viewerVote: answer.viewerVote,
  accepted: answer.accepted,
  verified: answer.verified,
  deleted: answer.deleted,
  ownedByViewer: answer.ownedByViewer,
  createdAt: answer.createdAt,
  updatedAt: DateTime.now(),
  replies: replies ?? answer.replies,
);

extension _Tap<T> on T {
  T also(void Function(T value) callback) {
    callback(this);
    return this;
  }
}

String _categoryName(String slug) => switch (slug) {
  'rituals-etiquette' => 'Rituals & Etiquette',
  'getting-there' => 'Getting There',
  _ => '${slug[0].toUpperCase()}${slug.substring(1)}',
};
