import 'package:flutter/foundation.dart';

@immutable
class TranslationMeaning {
  const TranslationMeaning({required this.partOfSpeech, required this.text});

  final String partOfSpeech;
  final String text;

  factory TranslationMeaning.fromJson(Map<String, dynamic> json) =>
      TranslationMeaning(
        partOfSpeech: json['partOfSpeech']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
      );
}

@immutable
class TranslationEntry {
  const TranslationEntry({
    required this.id,
    required this.english,
    required this.sinhala,
    required this.transliteration,
    required this.pronunciation,
    required this.meanings,
    required this.sentence,
    required this.relatedWords,
    required this.category,
  });

  final String id;
  final String english;
  final String sinhala;
  final String transliteration;
  final String pronunciation;
  final List<TranslationMeaning> meanings;
  final String sentence;
  final List<String> relatedWords;
  final String category;

  factory TranslationEntry.fromJson(Map<String, dynamic> json) =>
      TranslationEntry(
        id: json['id']?.toString() ?? '',
        english: json['english']?.toString() ?? '',
        sinhala: json['sinhala']?.toString() ?? '',
        transliteration: json['transliteration']?.toString() ?? '',
        pronunciation: json['pronunciation']?.toString() ?? '',
        meanings: _list(json['meanings'])
            .map((value) => TranslationMeaning.fromJson(_map(value)))
            .toList(growable: false),
        sentence: json['exampleSentence']?.toString() ?? '',
        relatedWords: _list(
          json['relatedWords'],
        ).map((value) => value.toString()).toList(growable: false),
        category: json['category']?.toString() ?? '',
      );
}

@immutable
class TranslationPage {
  const TranslationPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.hasNext,
  });

  final List<TranslationEntry> items;
  final int page;
  final int size;
  final int total;
  final bool hasNext;

  factory TranslationPage.fromJson(Map<String, dynamic> json) =>
      TranslationPage(
        items: _list(json['items'])
            .map((value) => TranslationEntry.fromJson(_map(value)))
            .toList(growable: false),
        page: _integer(json['page']),
        size: _integer(json['size']),
        total: _integer(json['total']),
        hasNext: json['hasNext'] == true,
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? value.cast<String, dynamic>() : const {};

List<dynamic> _list(dynamic value) => value is List ? value : const [];

int _integer(dynamic value) => value is num ? value.toInt() : 0;
