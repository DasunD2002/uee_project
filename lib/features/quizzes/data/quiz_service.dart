import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/api_service.dart';
import '../domain/quiz.dart';

abstract class QuizService {
  Future<QuizDashboard> getDashboard();

  Future<QuizSession> startOrResume();

  Future<QuizAnswerResult> submitAnswer({
    required String sessionId,
    required String questionId,
    String? answer,
    bool timedOut = false,
  });
}

class ApiQuizService implements QuizService {
  ApiQuizService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  @override
  Future<QuizDashboard> getDashboard() async => QuizDashboard.fromJson(
    _data(await _apiService.get('/quizzes/dashboard')),
  );

  @override
  Future<QuizSession> startOrResume() async =>
      QuizSession.fromJson(_data(await _apiService.post('/quizzes/sessions')));

  @override
  Future<QuizAnswerResult> submitAnswer({
    required String sessionId,
    required String questionId,
    String? answer,
    bool timedOut = false,
  }) async => QuizAnswerResult.fromJson(
    _data(
      await _apiService.post(
        '/quizzes/sessions/$sessionId/answers',
        body: {
          'questionId': questionId,
          'answer': ?answer,
          'timedOut': timedOut,
        },
      ),
    ),
  );

  static Map<String, dynamic> _data(http.Response response) {
    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        final value = jsonDecode(response.body);
        if (value is Map) decoded = value.cast<String, dynamic>();
      } on FormatException {
        decoded = null;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final fallback = response.statusCode == 401
          ? 'Your session has expired. Please log in again.'
          : 'The quiz request could not be completed.';
      throw QuizApiException(
        decoded?['errorDescription']?.toString() ?? fallback,
        statusCode: response.statusCode,
      );
    }
    final data = decoded?['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const QuizApiException(
      'The server returned an invalid quiz response.',
    );
  }
}

class QuizApiException implements Exception {
  const QuizApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
