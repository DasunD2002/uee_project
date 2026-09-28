enum QuizType {
  wordBuilder,
  meaningMatch,
  fillLetters;

  static QuizType fromJson(String value) => switch (value) {
    'WORD_BUILDER' => QuizType.wordBuilder,
    'MEANING_MATCH' => QuizType.meaningMatch,
    'FILL_LETTERS' => QuizType.fillLetters,
    _ => throw FormatException('Unknown quiz type: $value'),
  };
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.displayWord,
    required this.letters,
    required this.options,
    required this.blankPositions,
    required this.targetLength,
    required this.maximumPoints,
    required this.deadlineAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id']?.toString() ?? '',
    type: QuizType.fromJson(json['type']?.toString() ?? ''),
    prompt: json['prompt']?.toString() ?? '',
    displayWord: json['displayWord']?.toString() ?? '',
    letters: _strings(json['letters']),
    options: _strings(json['options']),
    blankPositions: _ints(json['blankPositions']),
    targetLength: _integer(json['targetLength']),
    maximumPoints: _integer(json['maximumPoints']),
    deadlineAt:
        DateTime.tryParse(json['deadlineAt']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc(),
  );

  final String id;
  final QuizType type;
  final String prompt;
  final String displayWord;
  final List<String> letters;
  final List<String> options;
  final List<int> blankPositions;
  final int targetLength;
  final int maximumPoints;
  final DateTime deadlineAt;
}

class QuizSession {
  const QuizSession({
    required this.id,
    required this.status,
    required this.currentStage,
    required this.completedSteps,
    required this.totalScore,
    this.question,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    final question = json['question'];
    return QuizSession(
      id: json['sessionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      currentStage: _integer(json['currentStage']),
      completedSteps: _integer(json['completedSteps']),
      totalScore: _integer(json['totalScore']),
      question: question is Map
          ? QuizQuestion.fromJson(question.cast<String, dynamic>())
          : null,
    );
  }

  final String id;
  final String status;
  final int currentStage;
  final int completedSteps;
  final int totalScore;
  final QuizQuestion? question;

  bool get isComplete => status == 'COMPLETED';
}

class QuizAnswerResult {
  const QuizAnswerResult({
    required this.correct,
    required this.timedOut,
    required this.completed,
    required this.feedback,
    required this.pointsAwarded,
    required this.session,
  });

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) =>
      QuizAnswerResult(
        correct: json['correct'] == true,
        timedOut: json['timedOut'] == true,
        completed: json['completed'] == true,
        feedback: json['feedback']?.toString() ?? '',
        pointsAwarded: _integer(json['pointsAwarded']),
        session: QuizSession.fromJson(
          (json['session'] as Map).cast<String, dynamic>(),
        ),
      );

  final bool correct;
  final bool timedOut;
  final bool completed;
  final String feedback;
  final int pointsAwarded;
  final QuizSession session;
}

class QuizLeader {
  const QuizLeader({
    required this.rank,
    required this.name,
    required this.initials,
    required this.score,
    required this.viewer,
  });

  factory QuizLeader.fromJson(Map<String, dynamic> json) => QuizLeader(
    rank: _integer(json['rank']),
    name: json['name']?.toString() ?? 'Rootly learner',
    initials: json['initials']?.toString() ?? 'RL',
    score: _integer(json['score']),
    viewer: json['viewer'] == true,
  );

  final int rank;
  final String name;
  final String initials;
  final int score;
  final bool viewer;
}

class QuizDashboard {
  const QuizDashboard({
    required this.completedSteps,
    required this.todayScore,
    required this.streakDays,
    required this.weekActivity,
    required this.weeklyLeaders,
    this.activeSessionId,
  });

  factory QuizDashboard.fromJson(Map<String, dynamic> json) => QuizDashboard(
    completedSteps: _integer(json['completedSteps']),
    todayScore: _integer(json['todayScore']),
    streakDays: _integer(json['streakDays']),
    activeSessionId: json['activeSessionId']?.toString(),
    weekActivity: (json['weekActivity'] as List? ?? const [])
        .map((value) => value == true)
        .toList(),
    weeklyLeaders: (json['weeklyLeaders'] as List? ?? const [])
        .whereType<Map>()
        .map((value) => QuizLeader.fromJson(value.cast<String, dynamic>()))
        .toList(),
  );

  final int completedSteps;
  final int todayScore;
  final int streakDays;
  final String? activeSessionId;
  final List<bool> weekActivity;
  final List<QuizLeader> weeklyLeaders;
}

int _integer(Object? value) => value is num ? value.toInt() : 0;

List<String> _strings(Object? value) =>
    (value as List? ?? const []).map((entry) => entry.toString()).toList();

List<int> _ints(Object? value) => (value as List? ?? const [])
    .whereType<num>()
    .map((entry) => entry.toInt())
    .toList();
