import 'package:flutter/foundation.dart';

@immutable
class ForumAuthor {
  const ForumAuthor({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.photoUrl,
    required this.verified,
  });

  final String id;
  final String name;
  final String initials;
  final String role;
  final String? photoUrl;
  final bool verified;

  factory ForumAuthor.fromJson(Map<String, dynamic>? json) => ForumAuthor(
    id: json?['id']?.toString() ?? '',
    name: json?['name']?.toString() ?? 'Unknown user',
    initials: json?['initials']?.toString() ?? '?',
    role: json?['role']?.toString() ?? '',
    photoUrl: json?['photoUrl']?.toString(),
    verified: json?['verified'] == true,
  );
}

@immutable
class Question {
  const Question({
    required this.id,
    required this.title,
    required this.body,
    required this.location,
    required this.placeId,
    required this.category,
    required this.categoryId,
    required this.authorDetails,
    required this.voteScore,
    required this.commentCount,
    required this.answers,
    required this.verified,
    required this.viewerVote,
    required this.bookmarked,
    required this.ownedByViewer,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedCommentId,
  });

  final String id;
  final String title;
  final String body;
  final String location;
  final String? placeId;
  final String category;
  final String categoryId;
  final ForumAuthor authorDetails;
  final int voteScore;
  final int commentCount;
  final List<QuestionAnswer> answers;
  final bool verified;
  final int viewerVote;
  final bool bookmarked;
  final bool ownedByViewer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? acceptedCommentId;

  String get author => authorDetails.name;
  String get authorInitials => authorDetails.initials;
  int get votes => voteScore;
  bool get isVerified => verified;
  String get timeAgo => formatRelativeTime(createdAt);

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    body: json['body']?.toString() ?? '',
    location: json['location']?.toString() ?? '',
    placeId: json['placeId']?.toString(),
    category: json['category']?.toString() ?? '',
    categoryId: json['categoryId']?.toString() ?? '',
    authorDetails: ForumAuthor.fromJson(_map(json['author'])),
    voteScore: _integer(json['voteScore']),
    commentCount: _integer(json['commentCount']),
    answers: _list(json['comments'])
        .map((entry) => QuestionAnswer.fromJson(_map(entry) ?? const {}))
        .toList(growable: false),
    verified: json['verified'] == true,
    viewerVote: _integer(json['viewerVote']),
    bookmarked: json['bookmarked'] == true,
    ownedByViewer: json['ownedByViewer'] == true,
    createdAt: _dateTime(json['createdAt']),
    updatedAt: _dateTime(json['updatedAt']),
    acceptedCommentId: json['acceptedCommentId']?.toString(),
  );

  Question copyWith({
    int? voteScore,
    int? viewerVote,
    bool? bookmarked,
    int? commentCount,
    List<QuestionAnswer>? answers,
  }) => Question(
    id: id,
    title: title,
    body: body,
    location: location,
    placeId: placeId,
    category: category,
    categoryId: categoryId,
    authorDetails: authorDetails,
    voteScore: voteScore ?? this.voteScore,
    commentCount: commentCount ?? this.commentCount,
    answers: answers ?? this.answers,
    verified: verified,
    viewerVote: viewerVote ?? this.viewerVote,
    bookmarked: bookmarked ?? this.bookmarked,
    ownedByViewer: ownedByViewer,
    createdAt: createdAt,
    updatedAt: updatedAt,
    acceptedCommentId: acceptedCommentId,
  );
}

@immutable
class QuestionAnswer {
  const QuestionAnswer({
    required this.id,
    required this.questionId,
    required this.parentCommentId,
    required this.authorDetails,
    required this.body,
    required this.voteScore,
    required this.viewerVote,
    required this.accepted,
    required this.verified,
    required this.deleted,
    required this.ownedByViewer,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
  });

  final String id;
  final String questionId;
  final String? parentCommentId;
  final ForumAuthor authorDetails;
  final String body;
  final int voteScore;
  final int viewerVote;
  final bool accepted;
  final bool verified;
  final bool deleted;
  final bool ownedByViewer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<QuestionAnswer> replies;

  String get author => authorDetails.name;
  String get authorInitials => authorDetails.initials;
  String get role => authorDetails.role;
  String get timeAgo => formatRelativeTime(createdAt);
  int get votes => voteScore;
  bool get isAccepted => accepted;
  bool get isVerified => verified;

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) => QuestionAnswer(
    id: json['id']?.toString() ?? '',
    questionId: json['questionId']?.toString() ?? '',
    parentCommentId: json['parentCommentId']?.toString(),
    authorDetails: ForumAuthor.fromJson(_map(json['author'])),
    body: json['body']?.toString() ?? '',
    voteScore: _integer(json['voteScore']),
    viewerVote: _integer(json['viewerVote']),
    accepted: json['accepted'] == true,
    verified: json['verified'] == true,
    deleted: json['deleted'] == true,
    ownedByViewer: json['ownedByViewer'] == true,
    createdAt: _dateTime(json['createdAt']),
    updatedAt: _dateTime(json['updatedAt']),
    replies: _list(json['replies'])
        .map((entry) => QuestionAnswer.fromJson(_map(entry) ?? const {}))
        .toList(growable: false),
  );

  QuestionAnswer copyWith({int? voteScore, int? viewerVote}) => QuestionAnswer(
    id: id,
    questionId: questionId,
    parentCommentId: parentCommentId,
    authorDetails: authorDetails,
    body: body,
    voteScore: voteScore ?? this.voteScore,
    viewerVote: viewerVote ?? this.viewerVote,
    accepted: accepted,
    verified: verified,
    deleted: deleted,
    ownedByViewer: ownedByViewer,
    createdAt: createdAt,
    updatedAt: updatedAt,
    replies: replies,
  );
}

@immutable
class QuestionPage {
  const QuestionPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.hasNext,
  });

  final List<Question> items;
  final int page;
  final int size;
  final int total;
  final bool hasNext;

  factory QuestionPage.fromJson(Map<String, dynamic> json) => QuestionPage(
    items: _list(json['items'])
        .map((entry) => Question.fromJson(_map(entry) ?? const {}))
        .toList(growable: false),
    page: _integer(json['page']),
    size: _integer(json['size']),
    total: _integer(json['total']),
    hasNext: json['hasNext'] == true,
  );
}

@immutable
class ForumVoteResult {
  const ForumVoteResult({
    required this.targetId,
    required this.voteScore,
    required this.viewerVote,
  });

  final String targetId;
  final int voteScore;
  final int viewerVote;

  factory ForumVoteResult.fromJson(Map<String, dynamic> json) =>
      ForumVoteResult(
        targetId: json['targetId']?.toString() ?? '',
        voteScore: _integer(json['voteScore']),
        viewerVote: _integer(json['viewerVote']),
      );
}

String formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  final difference = DateTime.now().difference(dateTime.toLocal());
  if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inDays < 1) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
  if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
  return '${difference.inDays ~/ 365}y ago';
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return null;
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

int _integer(dynamic value) => value is num ? value.toInt() : 0;

DateTime? _dateTime(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());
