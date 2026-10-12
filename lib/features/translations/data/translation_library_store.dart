import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/account_data_store.dart';
import '../../../core/services/api_service.dart';
import '../domain/translation_entry.dart';

class TranslationLibraryStore extends ChangeNotifier {
  TranslationLibraryStore({AccountDataStore? document})
    : document = document ?? AccountDataStore('translations') {
    this.document!.addListener(notifyListeners);
  }

  /// In-memory library for isolated previews and widget fixtures.
  TranslationLibraryStore.inMemory() : document = null;

  static final instance = isTestEnvironment
      ? TranslationLibraryStore.inMemory()
      : TranslationLibraryStore();
  final AccountDataStore? document;
  Map<String, dynamic> _memory = {};
  Future<void> _tail = Future.value();
  int _generation = 0;

  Map<String, dynamic> get _data => document?.data ?? _memory;
  String? get error => document?.error;
  List<TranslationEntry> get recent => _entries('recent');
  List<TranslationEntry> get saved => _entries('saved');
  Set<String> get favourites =>
      List<String>.from(_data['favourites'] as List? ?? []).toSet();

  static String entryKey(TranslationEntry entry) =>
      entry.id.isNotEmpty ? entry.id : entry.english.toLowerCase();

  List<TranslationEntry> _entries(String key) => (_data[key] as List? ?? [])
      .map(
        (value) =>
            TranslationEntry.fromJson(Map<String, dynamic>.from(value as Map)),
      )
      .toList();

  bool isSaved(TranslationEntry entry) =>
      saved.any((value) => entryKey(value) == entryKey(entry));

  Future<void> load({bool force = false}) async {
    if (document != null) await document!.load(force: force);
  }

  Future<void> _change(void Function(Map<String, dynamic> snapshot) change) {
    final sessionFuture = AccountSession.current();
    final generation = _generation;
    final operation = _tail.catchError((Object _) {}).then((_) async {
      final session = await sessionFuture;
      if (generation != _generation ||
          (document != null && (session == null || !await session.isCurrent))) {
        throw StateError('Your account changed. Please reopen this screen.');
      }
      await load();
      if (generation != _generation ||
          (document != null && !await session!.isCurrent)) {
        throw StateError('Your account changed. Please reopen this screen.');
      }
      final snapshot = jsonDecode(jsonEncode(_data)) as Map<String, dynamic>;
      change(snapshot);
      if (document != null) {
        await document!.save(snapshot);
      } else {
        _memory = snapshot;
        notifyListeners();
      }
    });
    _tail = operation;
    return operation;
  }

  Future<void> remember(TranslationEntry entry) => _change((snapshot) {
    final entries = recent
      ..removeWhere((value) => entryKey(value) == entryKey(entry))
      ..insert(0, entry);
    snapshot['recent'] = entries
        .take(6)
        .map((value) => value.toJson())
        .toList();
  });

  Future<void> toggleFavourite(TranslationEntry entry) => _change((snapshot) {
    final ids = favourites;
    if (!ids.add(entryKey(entry))) ids.remove(entryKey(entry));
    snapshot['favourites'] = ids.toList();
  });

  Future<void> toggleSaved(TranslationEntry entry) => _change((snapshot) {
    final entries = saved;
    if (isSaved(entry)) {
      entries.removeWhere((value) => entryKey(value) == entryKey(entry));
    } else {
      entries.insert(0, entry);
    }
    snapshot['saved'] = entries.map((value) => value.toJson()).toList();
  });

  void reset() {
    _generation++;
    _tail = Future.value();
    _memory = {};
    document?.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _generation++;
    document?.removeListener(notifyListeners);
    super.dispose();
  }
}
