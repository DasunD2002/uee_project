import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/home/presentation/widgets/home_drawer.dart';
import 'package:uee_project/features/translations/data/english_speech_service.dart';
import 'package:uee_project/features/translations/data/translation_service.dart';
import 'package:uee_project/features/translations/domain/translation_entry.dart';
import 'package:uee_project/features/translations/presentation/translation_screen.dart';

void main() {
  late FakeTranslationService service;
  late FakeEnglishSpeechService speechService;

  setUp(() {
    service = FakeTranslationService();
    speechService = FakeEnglishSpeechService();
  });

  Widget translationApp({Widget? home}) => MaterialApp(
    home:
        home ??
        TranslationScreen(
          translationService: service,
          speechService: speechService,
        ),
    routes: {
      '/translations': (_) => TranslationScreen(
        translationService: service,
        speechService: speechService,
      ),
      '/notifications': (_) => const Scaffold(body: Text('Notifications')),
      '/home': (_) => const Scaffold(body: Text('Home destination')),
      '/explorer': (_) => const Scaffold(body: Text('Explore destination')),
      '/questions': (_) => const Scaffold(body: Text('Questions destination')),
      '/capsule': (_) => const Scaffold(body: Text('Capsule destination')),
    },
  );

  testWidgets('translation lookup, language swap, and glossary work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(translationApp());
    await tester.pumpAndSettle();
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Stūpaya'), findsOneWidget);
    expect(find.text('Word details'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('translation-input')),
      'temple',
    );
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pumpAndSettle();
    expect(find.text('Pansala'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('swap-translation-languages')));
    await tester.pump();
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('translation-input')),
    );
    expect(field.controller!.text, 'පන්සල');

    await tester.scrollUntilVisible(
      find.text('Recent lookups'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent lookups'), findsOneWidget);
  });

  testWidgets('drawer Translation item opens the translation page', (
    tester,
  ) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      translationApp(
        home: Scaffold(
          key: scaffoldKey,
          drawer: const HomeDrawer(selectedSection: 'Home'),
          body: const SizedBox(),
        ),
      ),
    );

    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Translation'));
    await tester.pumpAndSettle();
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Stūpaya'), findsOneWidget);
  });

  testWidgets('unknown words show the backend error without stale results', (
    tester,
  ) async {
    await tester.pumpWidget(translationApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('translation-input')),
      'unknown',
    );
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pumpAndSettle();

    expect(find.text('Translation unavailable'), findsOneWidget);
    expect(find.text('Stūpaya'), findsNothing);
    expect(find.textContaining('not found'), findsOneWidget);
  });

  testWidgets('English speech fills the input and requests a translation', (
    tester,
  ) async {
    await tester.pumpWidget(translationApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('translation-voice-input')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('translation-input')),
    );
    expect(field.controller!.text, 'temple');
    expect(find.text('Pansala'), findsOneWidget);
    expect(service.lookupTexts.last, 'temple');
    expect(speechService.initializeCalls, 1);
  });

  testWidgets(
    'speech timeout is retryable and does not expose platform codes',
    (tester) async {
      speechService.errorOnListen = 'error_speech_timeout';
      await tester.pumpWidget(translationApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('translation-voice-input')));
      await tester.pumpAndSettle();

      expect(
        find.text('No speech was detected. Tap the microphone and try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('error_speech_timeout'), findsNothing);

      speechService.errorOnListen = null;
      await tester.tap(find.byKey(const ValueKey('translation-voice-input')));
      await tester.pumpAndSettle();

      expect(find.text('Pansala'), findsOneWidget);
      expect(speechService.listenCalls, 2);
    },
  );

  testWidgets('translation footer navigates to primary destinations', (
    tester,
  ) async {
    await tester.pumpWidget(translationApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();
    expect(find.text('Questions destination'), findsOneWidget);
  });
}

class FakeTranslationService implements TranslationService {
  final lookupTexts = <String>[];
  final entries = <TranslationEntry>[
    const TranslationEntry(
      id: 'translation-1',
      english: 'Stupa',
      sinhala: 'ස්තූපය',
      transliteration: 'Stūpaya',
      pronunciation: 'stoo-pa-ya',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'A dome-shaped Buddhist monument.',
        ),
      ],
      sentence: 'We walked quietly around the ancient stupa.',
      relatedWords: ['relic', 'temple'],
      category: 'Temple',
    ),
    const TranslationEntry(
      id: 'translation-2',
      english: 'Temple',
      sinhala: 'පන්සල',
      transliteration: 'Pansala',
      pronunciation: 'pan-sa-la',
      meanings: [
        TranslationMeaning(
          partOfSpeech: 'noun',
          text: 'A Buddhist place of worship.',
        ),
      ],
      sentence: 'Is the temple open this morning?',
      relatedWords: ['shrine', 'monastery'],
      category: 'Temple',
    ),
  ];

  @override
  Future<TranslationPage> getGlossary({
    String? category,
    int page = 0,
    int size = 10,
  }) async {
    final matches = entries
        .where((entry) => category == null || entry.category == category)
        .take(size)
        .toList();
    return TranslationPage(
      items: matches,
      page: page,
      size: size,
      total: matches.length,
      hasNext: false,
    );
  }

  @override
  Future<TranslationEntry> lookup({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final normalized = text.trim().toLowerCase();
    lookupTexts.add(normalized);
    for (final entry in entries) {
      final candidate = sourceLanguage == 'en' ? entry.english : entry.sinhala;
      if (candidate.toLowerCase() == normalized) return entry;
    }
    throw const TranslationApiException(
      'Translation was not found in the offline word bank',
      statusCode: 404,
    );
  }
}

class FakeEnglishSpeechService implements EnglishSpeechService {
  ValueChanged<bool>? _onListeningChanged;
  ValueChanged<String>? _onError;
  String? errorOnListen;
  int initializeCalls = 0;
  int listenCalls = 0;

  @override
  bool isListening = false;

  @override
  Future<bool> initialize({
    required ValueChanged<bool> onListeningChanged,
    required ValueChanged<String> onError,
  }) async {
    initializeCalls++;
    _onListeningChanged = onListeningChanged;
    _onError = onError;
    return true;
  }

  @override
  Future<void> listen({required SpeechResultCallback onResult}) async {
    listenCalls++;
    isListening = true;
    _onListeningChanged?.call(true);
    final error = errorOnListen;
    if (error != null) {
      isListening = false;
      _onError?.call(error);
      _onListeningChanged?.call(false);
      return;
    }
    onResult('temple', true);
    isListening = false;
    _onListeningChanged?.call(false);
  }

  @override
  Future<void> stop() async {
    isListening = false;
    _onListeningChanged?.call(false);
  }

  @override
  Future<void> cancel() => stop();
}
