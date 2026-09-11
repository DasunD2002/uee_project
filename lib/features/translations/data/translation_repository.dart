import '../domain/translation_entry.dart';

class TranslationRepository {
  const TranslationRepository();

  static const entries = <TranslationEntry>[
    TranslationEntry(
      english: 'Stupa',
      sinhala: 'ස්තූපය',
      transliteration: 'Isthūpa',
      pronunciation: 'dāgaba',
      category: 'Temple',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text:
              'A dome-shaped monument enshrining relics of the Buddha or a revered monk.',
        ),
        TranslationMeaning(
          partOfSpeech: 'noun',
          text:
              'In Sri Lankan usage, the bell-shaped brick structure at the heart of a monastery.',
        ),
      ],
      sentence:
          'We walked quietly around the ancient stupa, keeping it on our right.',
      relatedWords: ['relic', 'monastery', 'shrine'],
    ),
    TranslationEntry(
      english: 'Temple',
      sinhala: 'පන්සල',
      transliteration: 'Pansala',
      pronunciation: 'pan-sa-la',
      category: 'Temple',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'A place of worship, especially a Buddhist place of worship.',
        ),
      ],
      sentence: 'Is the temple open to visitors this morning?',
      relatedWords: ['shrine', 'monastery', 'offering'],
    ),
    TranslationEntry(
      english: 'Shrine',
      sinhala: 'දේවාලය',
      transliteration: 'Dēvālaya',
      pronunciation: 'day-vā-la-ya',
      category: 'Temple',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'A sacred place associated with a deity, relic, or devotion.',
        ),
      ],
      sentence: 'Please leave your shoes near the entrance to the shrine.',
      relatedWords: ['temple', 'relic', 'offering'],
    ),
    TranslationEntry(
      english: 'Monastery',
      sinhala: 'ආරාමය',
      transliteration: 'Ārāmaya',
      pronunciation: 'ā-rā-ma-ya',
      category: 'Temple',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'A residence and religious community for Buddhist monks.',
        ),
      ],
      sentence: 'The forest monastery welcomes quiet visitors.',
      relatedWords: ['temple', 'monk', 'meditation'],
    ),
    TranslationEntry(
      english: 'Please',
      sinhala: 'කරුණාකර',
      transliteration: 'Karunākara',
      pronunciation: 'ka-ru-nā-ka-ra',
      category: 'Greetings',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'adverb',
          text: 'A polite word used when making a request.',
        ),
      ],
      sentence: 'Please show me the way to the museum.',
      relatedWords: ['thank you', 'welcome', 'excuse me'],
    ),
    TranslationEntry(
      english: 'Welcome',
      sinhala: 'ආයුබෝවන්',
      transliteration: 'Āyubōvan',
      pronunciation: 'ā-yu-bō-van',
      category: 'Greetings',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'greeting',
          text: 'A respectful Sri Lankan greeting wishing someone long life.',
        ),
      ],
      sentence: 'Ayubowan, and welcome to our village.',
      relatedWords: ['hello', 'thank you', 'goodbye'],
    ),
    TranslationEntry(
      english: 'Rice',
      sinhala: 'බත්',
      transliteration: 'Bath',
      pronunciation: 'bath',
      category: 'Food',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'Cooked rice, the staple at the centre of a Sri Lankan meal.',
        ),
      ],
      sentence: 'May I have rice and vegetable curry, please?',
      relatedWords: ['curry', 'water', 'tea'],
    ),
    TranslationEntry(
      english: 'Water',
      sinhala: 'වතුර',
      transliteration: 'Vathura',
      pronunciation: 'va-thu-ra',
      category: 'Food',
      meanings: [
        TranslationMeaning(partOfSpeech: 'noun', text: 'Water for drinking.'),
      ],
      sentence: 'Could I have a bottle of water?',
      relatedWords: ['tea', 'drink', 'bottle'],
    ),
    TranslationEntry(
      english: 'Where',
      sinhala: 'කොහෙද',
      transliteration: 'Kohēda',
      pronunciation: 'ko-hay-da',
      category: 'Directions',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'adverb',
          text: 'Used to ask about a place or position.',
        ),
      ],
      sentence: 'Where is the railway station?',
      relatedWords: ['left', 'right', 'near'],
    ),
    TranslationEntry(
      english: 'Left',
      sinhala: 'වම',
      transliteration: 'Vama',
      pronunciation: 'va-ma',
      category: 'Directions',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'The direction opposite to right.',
        ),
      ],
      sentence: 'Turn left after the old post office.',
      relatedWords: ['right', 'straight', 'near'],
    ),
  ];

  TranslationEntry? find(String query, {required bool fromEnglish}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final entry in entries) {
      final candidates = fromEnglish
          ? [entry.english]
          : [entry.sinhala, entry.transliteration, entry.pronunciation];
      if (candidates.any((value) => value.toLowerCase() == normalized)) {
        return entry;
      }
    }
    return null;
  }

  List<TranslationEntry> entriesForCategory(String category) =>
      entries.where((entry) => entry.category == category).take(4).toList();
}
