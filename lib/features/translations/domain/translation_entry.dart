import 'package:flutter/foundation.dart';

@immutable
class TranslationMeaning {
  const TranslationMeaning({required this.partOfSpeech, required this.text});

  final String partOfSpeech;
  final String text;
}

@immutable
class TranslationEntry {
  const TranslationEntry({
    required this.english,
    required this.sinhala,
    required this.transliteration,
    required this.pronunciation,
    required this.meanings,
    required this.sentence,
    required this.relatedWords,
    required this.category,
  });

  final String english;
  final String sinhala;
  final String transliteration;
  final String pronunciation;
  final List<TranslationMeaning> meanings;
  final String sentence;
  final List<String> relatedWords;
  final String category;
}
