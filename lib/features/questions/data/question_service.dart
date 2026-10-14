import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/api_service.dart';
import '../domain/question.dart';

abstract class QuestionService {
  Future<QuestionPage> getQuestions({
    String query = '',
    String? category,
    String sort = 'top',
    int page = 0,
    int size = 20,
  });

  Future<Question> getQuestion(String questionId, {String sort = 'top'});

  Future<Question> createQuestion({
    required String title,
    required String body,
    required String location,
    required String category,
    String? placeId,
  });

  Future<void> updateQuestion({
    required String questionId,
    required String title,
    required String body,
    required String location,
    required String category,
    String? placeId,
  });

  Future<void> deleteQuestion(String questionId);

  Future<QuestionAnswer> createComment({
    required String questionId,
    required String body,
    String? parentCommentId,
  });

  Future<QuestionAnswer> updateComment({
    required String commentId,
    required String body,
  });

  Future<void> deleteComment(String commentId);

  Future<ForumVoteResult> voteQuestion(String questionId, int value);

  Future<ForumVoteResult> voteComment(String commentId, int value);

  Future<bool> setBookmark(String questionId, {required bool bookmarked});
}

class ApiQuestionService implements QuestionService {
  ApiQuestionService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  @override
  Future<QuestionPage> getQuestions({
    String query = '',
    String? category,
    String sort = 'top',
    int page = 0,
    int size = 20,
  }) async {
    final parameters = <String, String>{
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (category != null && category.isNotEmpty) 'category': category,
      'sort': sort,
      'page': '$page',
      'size': '$size',
    };
    final endpoint = Uri(
      path: '/questions',
      queryParameters: parameters,
    ).toString();
    final data = _data(await _apiService.get(endpoint));
    return QuestionPage.fromJson(data);
  }

  @override
  Future<Question> getQuestion(String questionId, {String sort = 'top'}) async {
    final endpoint = Uri(
      path: '/questions/$questionId',
      queryParameters: {'commentSort': sort},
    ).toString();
    return Question.fromJson(_data(await _apiService.get(endpoint)));
  }

  @override
  Future<Question> createQuestion({
    required String title,
    required String body,
    required String location,
    required String category,
    String? placeId,
  }) async {
    final response = await _apiService.post(
      '/questions',
      body: _questionBody(
        title: title,
        body: body,
        location: location,
        category: category,
        placeId: placeId,
      ),
    );
    return Question.fromJson(_data(response));
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
    _data(
      await _apiService.put(
        '/questions/$questionId',
        body: _questionBody(
          title: title,
          body: body,
          location: location,
          category: category,
          placeId: placeId,
        ),
      ),
    );
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    _data(await _apiService.delete('/questions/$questionId'));
  }

  @override
  Future<QuestionAnswer> createComment({
    required String questionId,
    required String body,
    String? parentCommentId,
  }) async {
    final data = _data(
      await _apiService.post(
        '/questions/$questionId/comments',
        body: {'body': body, 'parentCommentId': ?parentCommentId},
      ),
    );
    return QuestionAnswer.fromJson(data);
  }

  @override
  Future<QuestionAnswer> updateComment({
    required String commentId,
    required String body,
  }) async {
    final data = _data(
      await _apiService.put('/comments/$commentId', body: {'body': body}),
    );
    return QuestionAnswer.fromJson(data);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    _data(await _apiService.delete('/comments/$commentId'));
  }

  @override
  Future<ForumVoteResult> voteQuestion(String questionId, int value) async {
    final data = _data(
      await _apiService.put(
        '/questions/$questionId/vote',
        body: {'value': value},
      ),
    );
    return ForumVoteResult.fromJson(data);
  }

  @override
  Future<ForumVoteResult> voteComment(String commentId, int value) async {
    final data = _data(
      await _apiService.put(
        '/comments/$commentId/vote',
        body: {'value': value},
      ),
    );
    return ForumVoteResult.fromJson(data);
  }

  @override
  Future<bool> setBookmark(
    String questionId, {
    required bool bookmarked,
  }) async {
    final response = bookmarked
        ? await _apiService.put('/questions/$questionId/bookmark')
        : await _apiService.delete('/questions/$questionId/bookmark');
    final data = _data(response);
    return data['bookmarked'] == true;
  }

  static Map<String, dynamic> _questionBody({
    required String title,
    required String body,
    required String location,
    required String category,
    String? placeId,
  }) => {
    'title': title,
    'body': body,
    'location': location,
    if (placeId != null && placeId.isNotEmpty) 'placeId': placeId,
    'category': category,
  };

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
          : 'The Q&A request could not be completed.';
      throw QuestionApiException(
        decoded?['errorDescription']?.toString() ?? fallback,
        statusCode: response.statusCode,
      );
    }

    final data = decoded?['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const QuestionApiException(
      'The server returned an invalid response.',
    );
  }
}

class QuestionApiException implements Exception {
  const QuestionApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
