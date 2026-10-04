import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uee_project/core/services/api_service.dart';
import 'package:uee_project/features/questions/data/question_service.dart';

void main() {
  test('loads the paginated question response with viewer state', () async {
    final api = RecordingApiService();
    api.nextData = {
      'items': [
        {
          'id': 'question-1',
          'title': 'A sufficiently long question?',
          'body': 'A sufficiently descriptive question body.',
          'location': 'Kandy',
          'category': 'History',
          'categoryId': 'history',
          'author': {'id': 'user-1', 'name': 'Amaya', 'initials': 'A'},
          'voteScore': 4,
          'commentCount': 2,
          'viewerVote': 1,
          'bookmarked': true,
          'ownedByViewer': true,
          'createdAt': '2026-09-25T09:00:00Z',
        },
      ],
      'page': 0,
      'size': 20,
      'total': 1,
      'hasNext': false,
    };
    final service = ApiQuestionService(apiService: api);

    final page = await service.getQuestions(
      query: 'temple',
      category: 'history',
      sort: 'new',
    );

    expect(
      api.lastEndpoint,
      '/questions?q=temple&category=history&sort=new&page=0&size=20',
    );
    expect(page.items.single.viewerVote, 1);
    expect(page.items.single.bookmarked, isTrue);
    expect(page.items.single.ownedByViewer, isTrue);
  });

  test('uses the backend mutation routes and request bodies', () async {
    final api = RecordingApiService();
    final service = ApiQuestionService(apiService: api);

    await service.updateQuestion(
      questionId: 'question-1',
      title: 'How should a visitor enter this temple?',
      body: 'I would like to understand the respectful local custom.',
      location: 'Kandy',
      category: 'rituals-etiquette',
    );
    expect(api.lastMethod, 'PUT');
    expect(api.lastEndpoint, '/questions/question-1');
    expect(api.lastBody?['category'], 'rituals-etiquette');

    await service.updateComment(commentId: 'comment-1', body: 'Updated');
    expect(api.lastEndpoint, '/comments/comment-1');
    expect(api.lastBody, {'body': 'Updated'});

    await service.deleteComment('comment-1');
    expect(api.lastMethod, 'DELETE');
    expect(api.lastEndpoint, '/comments/comment-1');

    await service.deleteQuestion('question-1');
    expect(api.lastEndpoint, '/questions/question-1');

    await service.voteQuestion('question-1', -1);
    expect(api.lastEndpoint, '/questions/question-1/vote');
    expect(api.lastBody, {'value': -1});

    await service.voteComment('comment-1', 0);
    expect(api.lastEndpoint, '/comments/comment-1/vote');
    expect(api.lastBody, {'value': 0});

    api.nextData = {'bookmarked': true};
    expect(await service.setBookmark('question-1', bookmarked: true), isTrue);
    expect(api.lastEndpoint, '/questions/question-1/bookmark');
  });

  test('surfaces backend error descriptions', () async {
    final api = RecordingApiService()
      ..statusCode = 403
      ..errorDescription = 'You can only edit your own comment';
    final service = ApiQuestionService(apiService: api);

    expect(
      () => service.deleteComment('comment-1'),
      throwsA(
        isA<QuestionApiException>().having(
          (error) => error.message,
          'message',
          'You can only edit your own comment',
        ),
      ),
    );
  });
}

class RecordingApiService extends ApiService {
  String? lastMethod;
  String? lastEndpoint;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic> nextData = {};
  int statusCode = 200;
  String errorDescription = 'Request failed';

  @override
  Future<http.Response> get(String endpoint, {String? sessionToken}) =>
      _response('GET', endpoint);

  @override
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) => _response('POST', endpoint, body);

  @override
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? sessionToken,
  }) => _response('PUT', endpoint, body);

  @override
  Future<http.Response> delete(String endpoint, {String? sessionToken}) =>
      _response('DELETE', endpoint);

  Future<http.Response> _response(
    String method,
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    lastMethod = method;
    lastEndpoint = endpoint;
    lastBody = body;
    final payload = statusCode >= 200 && statusCode < 300
        ? {'data': nextData}
        : {'errorDescription': errorDescription};
    return http.Response(jsonEncode(payload), statusCode);
  }
}
