import '../../../core/services/account_data_store.dart';

class FieldNote {
  const FieldNote({
    required this.id,
    required this.province,
    required this.site,
    required this.category,
    required this.text,
    required this.image,
    required this.date,
    this.tags = const [],
  });
  final String id, province, site, category, text, image;
  final DateTime date;
  final List<String> tags;

  factory FieldNote.fromJson(Map<String, dynamic> json) => FieldNote(
    id: json['id'] as String,
    province: json['province'] as String,
    site: json['site'] as String,
    category: json['category'] as String,
    text: json['text'] as String,
    image: json['image'] as String,
    date: DateTime.parse(json['date'] as String),
    tags: List<String>.from(json['tags'] as List? ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'province': province,
    'site': site,
    'category': category,
    'text': text,
    'image': image,
    'date': date.toIso8601String(),
    'tags': tags,
  };
}

class FieldNotesStore {
  FieldNotesStore({AccountDataStore? document})
    : document = document ?? AccountDataStore('field-notes');
  static final instance = FieldNotesStore();
  final AccountDataStore document;

  List<FieldNote> get notes => (document.data['notes'] as List? ?? [])
      .map((item) => FieldNote.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();

  Future<void> load({bool force = false}) => document.load(force: force);

  Future<void> _tail = Future.value();
  int _generation = 0;

  Future<void> _queue(Future<void> Function() action) {
    final sessionFuture = AccountSession.current();
    final generation = _generation;
    final operation = _tail.catchError((Object _) {}).then((_) async {
      final session = await sessionFuture;
      if (session == null ||
          generation != _generation ||
          !await session.isCurrent) {
        throw StateError('Your account changed. Please reopen this screen.');
      }
      await load();
      if (generation != _generation || !await session.isCurrent) {
        throw StateError('Your account changed. Please reopen this screen.');
      }
      await action();
    });
    _tail = operation;
    return operation;
  }

  Future<void> save(FieldNote note) => _queue(() async {
    await load();
    final items = notes;
    final index = items.indexWhere((item) => item.id == note.id);
    if (index < 0) {
      items.insert(0, note);
    } else {
      items[index] = note;
    }
    await document.save({'notes': items.map((item) => item.toJson()).toList()});
  });

  Future<void> delete(String id) => _queue(() async {
    await load();
    await document.save({
      'notes': notes
          .where((item) => item.id != id)
          .map((item) => item.toJson())
          .toList(),
    });
  });

  void reset() {
    _generation++;
    _tail = Future.value();
    document.reset();
  }
}
