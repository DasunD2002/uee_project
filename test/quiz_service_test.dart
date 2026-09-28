import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/core/services/api_service.dart';
import 'package:uee_project/features/quizzes/data/quiz_service.dart';
import 'package:uee_project/features/quizzes/domain/quiz.dart';

void main() {
  test(
    'uses the authenticated quiz routes and parses dynamic content',
    () async {
      final api = FakeApiService();
      final service = ApiQuizService(apiService: api);

      final dashboard = await service.getDashboard();
      final session = await service.startOrResume();
      final result = await service.submitAnswer(
        sessionId: session.id,
        questionId: session.question!.id,
        answer: 'STUPA',
      );

      expect(api.calls, [
        'GET /quizzes/dashboard',
        'POST /quizzes/sessions',
        'POST /quizzes/sessions/session-1/answers',
      ]);
      expect(dashboard.streakDays, 2);
      expect(session.question!.type, QuizType.wordBuilder);
      expect(session.question!.letters, hasLength(5));
      expect(result.correct, isTrue);
      expect(api.lastBody, {
        'questionId': 'builder-1',
        'answer': 'STUPA',
        'timedOut': false,
      });
    },
  );

  test('surfaces authenticated quiz API errors', () async {
    final service = ApiQuizService(
      apiService: FakeApiService(errorStatus: 401),
    );

    await expectLater(
      service.getDashboard(),
      throwsA(
        isA<QuizApiException>().having(
          (error) => error.message,
          'message',
          'Please log in again.',
        ),
      ),
    );
  });
}

class FakeApiService extends ApiService {
  FakeApiService({this.errorStatus});

  final int? errorStatus;
  final List<String> calls = [];
  Map<String, dynamic>? lastBody;

  @override
  Future<http.Response> get(String endpoint) async {
    calls.add('GET $endpoint');
    if (errorStatus != null) {
      return http.Response(
        '{"errorDescription":"Please log in again."}',
        errorStatus!,
      );
    }
    return http.Response(_dashboardJson, 200);
  }

  @override
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    calls.add('POST $endpoint');
    lastBody = body;
    return http.Response(
      endpoint.endsWith('/answers') ? _answerJson : _sessionJson,
      200,
    );
  }
}

const _dashboardJson = '''
{"data":{"completedSteps":0,"todayScore":0,"streakDays":2,
"weekActivity":[true,true,false,false,false,false,false],"weeklyLeaders":[]}}
''';

const _sessionJson = '''
{"data":{"sessionId":"session-1","status":"IN_PROGRESS","currentStage":0,
"completedSteps":0,"totalScore":0,"question":{"id":"builder-1",
"type":"WORD_BUILDER","prompt":"Build the word","displayWord":"",
"letters":["S","T","U","P","A"],"options":[],"blankPositions":[],
"targetLength":5,"maximumPoints":40,"timeLimitSeconds":30,
"deadlineAt":"2099-01-01T00:00:00Z"}}}
''';

const _answerJson = '''
{"data":{"correct":true,"timedOut":false,"completed":false,
"feedback":"Correct!","pointsAwarded":40,"session":{"sessionId":"session-1",
"status":"IN_PROGRESS","currentStage":1,"completedSteps":1,"totalScore":40,
"question":{"id":"meaning-1","type":"MEANING_MATCH","prompt":"Meaning",
"displayWord":"dagaba","letters":[],"options":["Correct","Wrong"],
"blankPositions":[],"targetLength":0,"maximumPoints":30,
"timeLimitSeconds":30,"deadlineAt":"2099-01-01T00:00:00Z"}}}}
''';
