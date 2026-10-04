import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../data/english_speech_service.dart';
import '../data/translation_service.dart';
import '../data/translation_library_store.dart';
import '../../../core/services/api_service.dart';
import '../domain/translation_entry.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({
    super.key,
    this.translationService,
    this.speechService,
    this.libraryStore,
  });

  final TranslationService? translationService;
  final EnglishSpeechService? speechService;
  final TranslationLibraryStore? libraryStore;

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  static const _categories = <String>[
    'Temple',
    'Greetings',
    'Food',
    'Directions',
  ];

  final _controller = TextEditingController(text: 'stupa');
  late final TranslationLibraryStore _library;
  bool _libraryLoading = true;
  Set<String> get _favourites => _library.favourites;
  List<TranslationEntry> get _recentEntries => _library.recent;
  late final TranslationService _translationService;
  late final EnglishSpeechService _speechService;
  Timer? _lookupDebounce;
  int _lookupRequest = 0;
  int _glossaryRequest = 0;
  bool _fromEnglish = true;
  String _category = 'Temple';
  TranslationEntry? _entry;
  List<TranslationEntry> _glossaryEntries = const [];
  bool _lookupLoading = true;
  bool _glossaryLoading = true;
  String? _lookupError;
  String? _glossaryError;
  bool _speechInitialized = false;
  bool _speechInitializing = false;
  bool _listening = false;
  bool _speechHasResult = false;
  bool _disposing = false;

  @override
  void initState() {
    super.initState();
    _translationService = widget.translationService ?? ApiTranslationService();
    _speechService = widget.speechService ?? DeviceEnglishSpeechService();
    _library =
        widget.libraryStore ??
        (isTestEnvironment
            ? TranslationLibraryStore.inMemory()
            : TranslationLibraryStore.instance);
    _library.addListener(_libraryChanged);
    _loadLibrary();
    _performLookup('stupa');
    _loadGlossary();
  }

  @override
  void dispose() {
    _disposing = true;
    _library.removeListener(_libraryChanged);
    _lookupDebounce?.cancel();
    if (_speechInitialized) unawaited(_speechService.cancel());
    _controller.dispose();
    super.dispose();
  }

  void _queueLookup(String value) {
    _lookupDebounce?.cancel();
    final text = value.trim();
    final request = ++_lookupRequest;
    if (text.isEmpty) {
      setState(() {
        _entry = null;
        _lookupLoading = false;
        _lookupError = null;
      });
      return;
    }
    setState(() {
      _entry = null;
      _lookupLoading = true;
      _lookupError = null;
    });
    _lookupDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _performLookup(text, request: request),
    );
  }

  Future<void> _performLookup(
    String value, {
    bool remember = false,
    int? request,
  }) async {
    _lookupDebounce?.cancel();
    final text = value.trim();
    if (text.isEmpty) {
      _clearInput();
      return;
    }
    final currentRequest = request ?? ++_lookupRequest;
    if (mounted) {
      setState(() {
        _lookupLoading = true;
        _lookupError = null;
      });
    }
    try {
      final entry = await _translationService.lookup(
        text: text,
        sourceLanguage: _fromEnglish ? 'en' : 'si',
        targetLanguage: _fromEnglish ? 'si' : 'en',
      );
      if (!mounted || currentRequest != _lookupRequest) return;
      setState(() {
        _entry = entry;
        _lookupLoading = false;
        _lookupError = null;
        if (remember) _rememberWithoutRebuild(entry);
      });
    } catch (error) {
      if (!mounted || currentRequest != _lookupRequest) return;
      setState(() {
        _entry = null;
        _lookupLoading = false;
        _lookupError = error.toString();
      });
    }
  }

  Future<void> _loadGlossary() async {
    final currentRequest = ++_glossaryRequest;
    setState(() {
      _glossaryLoading = true;
      _glossaryError = null;
    });
    try {
      final page = await _translationService.getGlossary(
        category: _category,
        size: 4,
      );
      if (!mounted || currentRequest != _glossaryRequest) return;
      setState(() {
        _glossaryEntries = page.items;
        _glossaryLoading = false;
      });
    } catch (error) {
      if (!mounted || currentRequest != _glossaryRequest) return;
      setState(() {
        _glossaryEntries = const [];
        _glossaryLoading = false;
        _glossaryError = error.toString();
      });
    }
  }

  void _selectCategory(String category) {
    if (_category == category) return;
    setState(() => _category = category);
    _loadGlossary();
  }

  void _libraryChanged() {
    if (mounted && !_disposing) setState(() {});
  }

  Future<void> _loadLibrary() async {
    if (mounted) setState(() => _libraryLoading = true);
    try {
      await _library.load(force: true);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _libraryLoading = false);
    }
  }

  Future<void> _saveLibrary(Future<void> Function() save) async {
    try {
      await save();
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  void _rememberWithoutRebuild(TranslationEntry entry) {
    unawaited(_saveLibrary(() => _library.remember(entry)));
  }

  void _selectEntry(TranslationEntry entry) {
    _lookupDebounce?.cancel();
    _lookupRequest++;
    final input = _fromEnglish ? entry.english : entry.sinhala;
    _controller
      ..text = input
      ..selection = TextSelection.collapsed(offset: input.length);
    setState(() {
      _entry = entry;
      _lookupLoading = false;
      _lookupError = null;
      _rememberWithoutRebuild(entry);
    });
  }

  void _swapLanguages() {
    _stopVoiceInput();
    _lookupDebounce?.cancel();
    _lookupRequest++;
    final entry = _entry;
    final pendingText = _controller.text.trim();
    setState(() {
      _fromEnglish = !_fromEnglish;
      if (entry == null) return;
      final input = _fromEnglish ? entry.english : entry.sinhala;
      _controller
        ..text = input
        ..selection = TextSelection.collapsed(offset: input.length);
      _entry = entry;
    });
    if (entry == null && pendingText.isNotEmpty) {
      _performLookup(pendingText);
    }
  }

  void _clearInput() {
    _stopVoiceInput();
    _lookupDebounce?.cancel();
    _lookupRequest++;
    _controller.clear();
    setState(() {
      _entry = null;
      _lookupLoading = false;
      _lookupError = null;
    });
  }

  void _toggleFavourite() {
    final entry = _entry;
    if (entry == null || _libraryLoading) return;
    unawaited(_saveLibrary(() => _library.toggleFavourite(entry)));
  }

  String _entryKey(TranslationEntry entry) =>
      TranslationLibraryStore.entryKey(entry);

  Future<void> _toggleVoiceInput() async {
    if (!_fromEnglish) {
      _showMessage('Voice input is available for English words only');
      return;
    }
    if (_speechInitializing) return;
    if (_listening || _speechService.isListening) {
      await _speechService.stop();
      if (mounted && !_disposing) setState(() => _listening = false);
      return;
    }

    setState(() => _speechInitializing = true);
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speechService.initialize(
          onListeningChanged: (listening) {
            if (mounted && !_disposing) {
              setState(() => _listening = listening);
            }
          },
          onError: _handleSpeechError,
        );
      }
      if (!_speechInitialized) {
        _showMessage(
          'Speech recognition is unavailable or microphone permission was denied',
        );
        return;
      }
      _speechHasResult = false;
      await _speechService.listen(onResult: _handleSpeechResult);
    } catch (_) {
      if (mounted && !_disposing) {
        _showMessage('Voice input could not start. Please try again.');
      }
    } finally {
      if (mounted && !_disposing) {
        setState(() => _speechInitializing = false);
      }
    }
  }

  void _handleSpeechResult(String value, bool finalResult) {
    if (!mounted || _disposing) return;
    final recognized = value.trim();
    if (recognized.isEmpty) return;
    _speechHasResult = true;
    final text = recognized.length > 120
        ? recognized.substring(0, 120)
        : recognized;
    _controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    if (finalResult) {
      _performLookup(text, remember: true);
    } else {
      _queueLookup(text);
    }
  }

  void _handleSpeechError(String message) {
    if (!mounted || _disposing) return;
    final normalized = message.toLowerCase();
    final noSpeechDetected =
        normalized.contains('speech_timeout') ||
        normalized.contains('no_match');
    setState(() {
      _listening = false;
      _speechInitializing = false;
    });

    if (noSpeechDetected && _speechHasResult) return;
    if (noSpeechDetected) {
      _showMessage('No speech was detected. Tap the microphone and try again.');
    } else if (normalized.contains('permission')) {
      _showMessage('Microphone permission is required for voice input.');
    } else if (normalized.contains('network')) {
      _showMessage(
        'Speech recognition needs a working internet connection. Please try again.',
      );
    } else if (normalized.contains('audio')) {
      _showMessage('The microphone could not be accessed. Please try again.');
    } else if (normalized.contains('busy')) {
      _showMessage('Speech recognition is busy. Wait a moment and try again.');
    } else {
      _showMessage('Voice input could not complete. Please try again.');
    }
  }

  void _stopVoiceInput() {
    if (!_speechInitialized || (!_listening && !_speechService.isListening)) {
      return;
    }
    unawaited(_speechService.stop());
    if (mounted && !_disposing) setState(() => _listening = false);
  }

  void _copyTranslation() {
    final entry = _entry;
    if (entry == null) return;
    final translation = _fromEnglish ? entry.sinhala : entry.english;
    Clipboard.setData(ClipboardData(text: translation));
    _showMessage('Translation copied');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      drawer: const HomeDrawer(selectedSection: 'Translation'),
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: const Color(0xFFFFEEEE),
        foregroundColor: AppColors.brown,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            tooltip: 'Open menu',
            onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            icon: const Icon(Icons.menu_rounded, size: 21),
          ),
        ),
        title: const Text(
          'Rootly',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 27,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, size: 21),
          ),
          const SizedBox(width: 3),
        ],
      ),
      body: ListView(
        key: const ValueKey('translation-scroll-view'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 34),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Translate',
                  style: TextStyle(
                    color: Color(0xFF39251E),
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: entry != null && _library.isSaved(entry)
                    ? 'Remove saved translation'
                    : 'Save translation',
                onPressed: entry == null || _libraryLoading
                    ? null
                    : () => _saveLibrary(() => _library.toggleSaved(entry)),
                icon: Icon(
                  entry != null && _library.isSaved(entry)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE8DBD2), height: 16),
          _LanguageSelector(fromEnglish: _fromEnglish, onSwap: _swapLanguages),
          const SizedBox(height: 15),
          _TranslationInput(
            controller: _controller,
            fromEnglish: _fromEnglish,
            onChanged: _queueLookup,
            onSubmitted: (value) => _performLookup(value, remember: true),
            onClear: _clearInput,
            listening: _listening,
            microphoneBusy: _speechInitializing,
            onMicrophone: _toggleVoiceInput,
            onScan: () => _showMessage('Text scanning is not configured yet.'),
          ),
          const SizedBox(height: 14),
          _TranslationResult(
            entry: entry,
            fromEnglish: _fromEnglish,
            loading: _lookupLoading,
            error: _lookupError,
            favourite: entry != null && _favourites.contains(_entryKey(entry)),
            onSpeak: () =>
                _showMessage('Pronunciation playback is not configured yet.'),
            onCopy: _copyTranslation,
            onFavourite: _toggleFavourite,
          ),
          const SizedBox(height: 14),
          _WordDetails(entry: entry),
          const SizedBox(height: 14),
          const _SectionTitle('Heritage glossary'),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: category == _category,
                  showCheckmark: false,
                  onSelected: (_) => _selectCategory(category),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.brown,
                  side: BorderSide(
                    color: category == _category
                        ? AppColors.brown
                        : const Color(0xFFE7D7CC),
                  ),
                  labelStyle: TextStyle(
                    color: category == _category
                        ? Colors.white
                        : const Color(0xFF735E54),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (_glossaryLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_glossaryError != null)
            _TranslationError(message: _glossaryError!, onRetry: _loadGlossary)
          else
            _GlossaryList(entries: _glossaryEntries, onSelected: _selectEntry),
          const SizedBox(height: 14),
          if (_library.error != null)
            _TranslationError(message: _library.error!, onRetry: _loadLibrary),
          const _SectionTitle('Recent lookups'),
          const SizedBox(height: 8),
          if (_recentEntries.isEmpty)
            const Text(
              'Your successful lookups will appear here.',
              style: TextStyle(color: Color(0xFF8C786E), fontSize: 11),
            )
          else
            for (final recentEntry in _recentEntries) ...[
              _RecentLookup(
                entry: recentEntry,
                favourite: _favourites.contains(_entryKey(recentEntry)),
                onTap: _selectEntry,
                onFavourite: (entry) =>
                    _saveLibrary(() => _library.toggleFavourite(entry)),
              ),
              const SizedBox(height: 7),
            ],
        ],
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: null,
        onSelected: (index) => navigateToPrimaryDestination(context, index),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.fromEnglish, required this.onSwap});

  final bool fromEnglish;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _LanguagePill(
          language: fromEnglish ? 'English' : 'Sinhala',
          caption: fromEnglish ? 'English' : 'සිංහල',
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: IconButton(
          key: const ValueKey('swap-translation-languages'),
          tooltip: 'Swap languages',
          onPressed: onSwap,
          style: IconButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE7D7CC)),
            backgroundColor: Colors.white,
          ),
          icon: const Icon(
            Icons.swap_vert_rounded,
            color: AppColors.brown,
            size: 20,
          ),
        ),
      ),
      Expanded(
        child: _LanguagePill(
          language: fromEnglish ? 'Sinhala' : 'English',
          caption: fromEnglish ? 'සිංහල' : 'English',
        ),
      ),
    ],
  );
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.language, required this.caption});

  final String language;
  final String caption;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF5),
          border: Border.all(color: const Color(0xFFE7D7CC)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          language,
          style: const TextStyle(
            color: Color(0xFF3D2B24),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 3),
      Text(
        caption,
        style: const TextStyle(color: Color(0xFFB09C91), fontSize: 8),
      ),
    ],
  );
}

class _TranslationInput extends StatelessWidget {
  const _TranslationInput({
    required this.controller,
    required this.fromEnglish,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.listening,
    required this.microphoneBusy,
    required this.onMicrophone,
    required this.onScan,
  });

  final TextEditingController controller;
  final bool fromEnglish;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool listening;
  final bool microphoneBusy;
  final VoidCallback onMicrophone;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    padding: const EdgeInsets.fromLTRB(13, 10, 10, 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFAF5),
      border: Border.all(color: const Color(0xFFE7D7CC)),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('translation-input'),
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            maxLength: 120,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              color: const Color(0xFF49342C),
              fontFamily: fromEnglish ? 'serif' : null,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: fromEnglish
                  ? 'Type an English word'
                  : 'සිංහල වචනයක් ලියන්න',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear text',
                      onPressed: onClear,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFA58E82),
                        size: 18,
                      ),
                    ),
            ),
          ),
        ),
        const Divider(color: Color(0xFFE9DCD3), height: 1),
        Row(
          children: [
            IconButton(
              key: const ValueKey('translation-voice-input'),
              tooltip: listening ? 'Stop voice input' : 'Voice input',
              onPressed: microphoneBusy ? null : onMicrophone,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                listening ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
                color: listening ? AppColors.brown : const Color(0xFF8D7569),
                size: 18,
              ),
            ),
            IconButton(
              tooltip: 'Scan text',
              onPressed: onScan,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.document_scanner_outlined,
                color: Color(0xFF8D7569),
                size: 18,
              ),
            ),
            const Spacer(),
            Text(
              '${controller.text.length}/120',
              style: const TextStyle(color: Color(0xFFA58E82), fontSize: 9),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ],
    ),
  );
}

class _TranslationResult extends StatelessWidget {
  const _TranslationResult({
    required this.entry,
    required this.fromEnglish,
    required this.loading,
    required this.error,
    required this.favourite,
    required this.onSpeak,
    required this.onCopy,
    required this.onFavourite,
  });

  final TranslationEntry? entry;
  final bool fromEnglish;
  final bool loading;
  final String? error;
  final bool favourite;
  final VoidCallback onSpeak;
  final VoidCallback onCopy;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final value = entry;
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF7E2E1B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : error != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Translation unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: const TextStyle(
                    color: Color(0xFFFFDCC8),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            )
          : value == null
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No saved translation',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Try a word from the heritage glossary below.',
                  style: TextStyle(color: Color(0xFFFFDCC8), fontSize: 11),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fromEnglish ? value.transliteration : value.english,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 45),
                Text(
                  fromEnglish
                      ? '${value.sinhala}  ·  ${value.pronunciation}'
                      : value.transliteration,
                  style: const TextStyle(
                    color: Color(0xFFFFDCC8),
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ResultButton(
                      tooltip: 'Play pronunciation',
                      icon: Icons.volume_up_outlined,
                      onPressed: onSpeak,
                    ),
                    const SizedBox(width: 7),
                    _ResultButton(
                      tooltip: 'Copy translation',
                      icon: Icons.copy_rounded,
                      onPressed: onCopy,
                    ),
                    const SizedBox(width: 7),
                    _ResultButton(
                      tooltip: favourite
                          ? 'Remove from favourites'
                          : 'Add to favourites',
                      icon: favourite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      onPressed: onFavourite,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: const Color(0xFF913B27),
      foregroundColor: Colors.white,
    ),
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 18),
  );
}

class _TranslationError extends StatelessWidget {
  const _TranslationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE7D7CC)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF8C4A3A), fontSize: 11),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _WordDetails extends StatelessWidget {
  const _WordDetails({required this.entry});

  final TranslationEntry? entry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 17, 16, 15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE7D7CC)),
      borderRadius: BorderRadius.circular(15),
    ),
    child: entry == null
        ? const Text(
            'Word details will appear after a matching translation is found.',
            style: TextStyle(color: Color(0xFF8C786E), fontSize: 11),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Word details',
                style: TextStyle(
                  color: Color(0xFF3B2821),
                  fontFamily: 'serif',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 9),
              for (var index = 0; index < entry!.meanings.length; index++) ...[
                _MeaningRow(number: index + 1, meaning: entry!.meanings[index]),
                if (index != entry!.meanings.length - 1)
                  const SizedBox(height: 10),
              ],
              const SizedBox(height: 15),
              const Text(
                'IN A SENTENCE',
                style: TextStyle(
                  color: Color(0xFF806C62),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFF0CDAE), width: 2),
                  ),
                ),
                child: Text(
                  entry!.sentence,
                  style: const TextStyle(
                    color: Color(0xFF5F4A41),
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final word in entry!.relatedWords)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAF5),
                        border: Border.all(color: const Color(0xFFE7D7CC)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                          color: Color(0xFF806C62),
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
  );
}

class _MeaningRow extends StatelessWidget {
  const _MeaningRow({required this.number, required this.meaning});

  final int number;
  final TranslationMeaning meaning;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 17,
        child: Text(
          '$number',
          style: const TextStyle(color: Color(0xFFB28E7D), fontSize: 10),
        ),
      ),
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${meaning.partOfSpeech}  ',
                style: const TextStyle(
                  color: AppColors.brown,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: meaning.text),
            ],
          ),
          style: const TextStyle(
            color: Color(0xFF4E3A32),
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: Color(0xFF3B2821),
      fontFamily: 'serif',
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _GlossaryList extends StatelessWidget {
  const _GlossaryList({required this.entries, required this.onSelected});

  final List<TranslationEntry> entries;
  final ValueChanged<TranslationEntry> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE7D7CC)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          InkWell(
            onTap: () => onSelected(entries[index]),
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entries[index].english,
                        style: const TextStyle(
                          color: Color(0xFF403029),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFB39E93),
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (index != entries.length - 1)
            const Divider(color: Color(0xFFE9DED7), height: 1),
        ],
      ],
    ),
  );
}

class _RecentLookup extends StatelessWidget {
  const _RecentLookup({
    required this.entry,
    required this.favourite,
    required this.onTap,
    required this.onFavourite,
  });

  final TranslationEntry entry;
  final bool favourite;
  final ValueChanged<TranslationEntry> onTap;
  final ValueChanged<TranslationEntry> onFavourite;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFE7D7CC)),
    ),
    child: InkWell(
      onTap: () => onTap(entry),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 47,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 0, 6, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E8DC),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'EN → SI',
                  style: TextStyle(
                    color: Color(0xFF927D71),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.english,
                  style: const TextStyle(
                    color: Color(0xFF3F2D26),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: () => onFavourite(entry),
                icon: Icon(
                  favourite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.brown,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
