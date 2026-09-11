import 'package:flutter/foundation.dart';

/// Keeps today's quiz progress available while the app is running.
class QuizProgressStore extends ChangeNotifier {
  QuizProgressStore._();

  static final QuizProgressStore instance = QuizProgressStore._();

  int _completedSteps = 0;
  int _score = 0;

  int get completedSteps => _completedSteps;
  int get score => _score;
  bool get isComplete => _completedSteps == 3;

  void startChallenge() {
    if (!isComplete) return;
    _completedSteps = 0;
    _score = 0;
    notifyListeners();
  }

  void completeStep({required int step, required int score}) {
    if (step <= _completedSteps) return;
    _completedSteps = step.clamp(0, 3);
    _score = score.clamp(0, 100);
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _completedSteps = 0;
    _score = 0;
    notifyListeners();
  }
}
