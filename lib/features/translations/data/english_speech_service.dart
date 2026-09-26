import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechResultCallback = void Function(String text, bool finalResult);

abstract class EnglishSpeechService {
  bool get isListening;

  Future<bool> initialize({
    required ValueChanged<bool> onListeningChanged,
    required ValueChanged<String> onError,
  });

  Future<void> listen({required SpeechResultCallback onResult});

  Future<void> stop();

  Future<void> cancel();
}

class DeviceEnglishSpeechService implements EnglishSpeechService {
  final SpeechToText _speech = SpeechToText();

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize({
    required ValueChanged<bool> onListeningChanged,
    required ValueChanged<String> onError,
  }) => _speech.initialize(
    onStatus: (status) => onListeningChanged(status == 'listening'),
    onError: (SpeechRecognitionError error) => onError(error.errorMsg),
  );

  @override
  Future<void> listen({required SpeechResultCallback onResult}) async {
    final locales = await _speech.locales();
    String? englishLocale;
    for (final locale in locales) {
      final normalized = locale.localeId.toLowerCase().replaceAll('-', '_');
      if (normalized == 'en_us') {
        englishLocale = locale.localeId;
        break;
      }
      if (englishLocale == null && normalized.startsWith('en_')) {
        englishLocale = locale.localeId;
      }
    }

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) =>
          onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        localeId: englishLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}
