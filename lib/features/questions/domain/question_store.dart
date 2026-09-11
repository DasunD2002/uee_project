import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'question.dart';

class QuestionStore extends ChangeNotifier {
  QuestionStore._() {
    _resetQuestions();
  }

  static final QuestionStore instance = QuestionStore._();

  final List<Question> _questions = [];

  UnmodifiableListView<Question> get questions =>
      UnmodifiableListView(_questions);

  Question? questionById(String id) {
    for (final question in _questions) {
      if (question.id == id) return question;
    }
    return null;
  }

  void addQuestion(Question question) {
    _questions.insert(0, _normalizeQuestion(question));
    notifyListeners();
  }

  void addAnswer(
    String questionId,
    QuestionAnswer answer, {
    String? parentAnswerId,
  }) {
    final questionIndex = _questions.indexWhere(
      (question) => question.id == questionId,
    );
    if (questionIndex < 0) return;

    final question = _questions[questionIndex];
    final normalizedAnswer = answer.copyWith(
      id: answer.id.isEmpty
          ? 'answer-${DateTime.now().microsecondsSinceEpoch}'
          : answer.id,
    );
    final answers = parentAnswerId == null
        ? [...question.answers, normalizedAnswer]
        : _appendReply(question.answers, parentAnswerId, normalizedAnswer);
    _questions[questionIndex] = question.copyWith(answers: answers);
    notifyListeners();
  }

  void resetForTesting() {
    _resetQuestions();
    notifyListeners();
  }

  void _resetQuestions() {
    _questions
      ..clear()
      ..addAll(sampleQuestions.map(_normalizeQuestion));
  }

  Question _normalizeQuestion(Question question) => question.copyWith(
    answers: _normalizeAnswers(question.answers, question.id),
  );

  List<QuestionAnswer> _normalizeAnswers(
    List<QuestionAnswer> answers,
    String prefix,
  ) => [
    for (var index = 0; index < answers.length; index++)
      answers[index].copyWith(
        id: answers[index].id.isEmpty
            ? '$prefix-answer-$index'
            : answers[index].id,
        replies: _normalizeAnswers(
          answers[index].replies,
          answers[index].id.isEmpty
              ? '$prefix-answer-$index'
              : answers[index].id,
        ),
      ),
  ];

  List<QuestionAnswer> _appendReply(
    List<QuestionAnswer> answers,
    String parentAnswerId,
    QuestionAnswer reply,
  ) => [
    for (final answer in answers)
      if (answer.id == parentAnswerId)
        answer.copyWith(replies: [...answer.replies, reply])
      else
        answer.copyWith(
          replies: _appendReply(answer.replies, parentAnswerId, reply),
        ),
  ];
}
