import 'package:flutter/material.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import 'field_note_editor_screen.dart';
import '../data/field_notes_store.dart';
import 'widgets/explorer_footer.dart';
import 'widgets/region_image.dart';

class FieldNotesArchiveScreen extends StatefulWidget {
  const FieldNotesArchiveScreen({
    super.key,
    required this.province,
    required this.site,
    required this.image,
    this.store,
  });

  final String province, site, image;
  final FieldNotesStore? store;

  @override
  State<FieldNotesArchiveScreen> createState() =>
      _FieldNotesArchiveScreenState();
}

class _FieldNotesArchiveScreenState extends State<FieldNotesArchiveScreen> {
  String filter = 'All Notes';

  List<FieldNote> notes = [];
  String query = '';
  bool loading = true;
  String? error;
  FieldNotesStore get store => widget.store ?? FieldNotesStore.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    try {
      await store.load(force: force);
      if (mounted) {
        setState(
          () => notes = store.notes
              .where((item) => item.province == widget.province)
              .toList(),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _delete(FieldNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete field note?'),
        content: Text(
          'Are you sure you want to delete the field note for ${note.site}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await store.delete(note.id);
      if (!mounted) return;
      setState(
        () => notes = store.notes
            .where((item) => item.province == widget.province)
            .toList(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Field note deleted')));
  }

  void _navigate(int index) {
    navigateToPrimaryDestination(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final visible = notes.where((note) {
      final matchesFilter =
          filter == 'All Notes' ||
          (filter == 'Recent' &&
              note.date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              )) ||
          (filter == 'Natural Sites' && note.category == 'Natural Site') ||
          note.category == filter;
      return matchesFilter &&
          '${note.site} ${note.text} ${note.tags.join(' ')}'
              .toLowerCase()
              .contains(query);
    }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEAEA),
        foregroundColor: AppColors.brown,
        centerTitle: true,
        leading: const RootlyBackButton(fallbackRoute: '/explorer'),
        title: const Text(
          'Rootly',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 17, 12, 24),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFFA35B46),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Field Notes Archive',
                    style: TextStyle(
                      color: AppColors.brown,
                      fontFamily: 'serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.province,
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Your personal observations and preservation logs.',
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 11),
          TextField(
            onChanged: (value) =>
                setState(() => query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search heritage sites or notes...',
              hintStyle: const TextStyle(fontSize: 10),
              prefixIcon: const Icon(Icons.search, size: 17),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFFD8C9C2)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final label in const [
                  'All Notes',
                  'Recent',
                  'Architectural',
                  'Natural Sites',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 9)),
                      selected: filter == label,
                      selectedColor: const Color(0xFFFFDCC2),
                      side: const BorderSide(color: Color(0xFFD8C9C2)),
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => filter = label),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (error != null)
            ListTile(
              title: Text(error!),
              trailing: TextButton(
                onPressed: () => _load(force: true),
                child: const Text('Retry'),
              ),
            ),
          if (!loading && error == null && visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: Text('No field notes in this category.')),
            )
          else
            for (final note in visible) ...[
              _NoteCard(
                note: note,
                onEdit: () async {
                  final result = await Navigator.push<FieldNoteEditorResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FieldNoteEditorScreen(
                        province: widget.province,
                        image: note.image,
                        initialSite: note.site,
                        initialCategory: note.category,
                        initialText: note.text,
                        isEditing: true,
                        noteId: note.id,
                        initialDate: note.date,
                        initialTags: note.tags,
                        store: store,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    await _load();
                  }
                },
                onDelete: () => _delete(note),
              ),
              const SizedBox(height: 13),
            ],
        ],
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 1,
        onSelected: _navigate,
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });
  final FieldNote note;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF8),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: const Color(0xFFE7D9D1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: RegionImage(source: note.image, width: 160, height: 105),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF5E9E1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(
              note.category.toUpperCase(),
              style: const TextStyle(
                fontSize: 7,
                color: AppColors.brown,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          note.site,
          style: const TextStyle(
            color: AppColors.brown,
            fontFamily: 'serif',
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          MaterialLocalizations.of(context).formatMediumDate(note.date),
          style: const TextStyle(fontSize: 8, color: Colors.black45),
        ),
        const SizedBox(height: 9),
        Text(
          '“${note.text}”',
          style: const TextStyle(
            fontSize: 10,
            height: 1.5,
            fontStyle: FontStyle.italic,
            color: Color(0xFF4D4541),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              "FIELD LOG  #${note.site.hashCode.abs().toString().padLeft(4, '0').substring(0, 4)}",
              style: const TextStyle(
                fontSize: 7,
                color: Colors.black38,
                letterSpacing: .5,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Edit note',
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.edit_outlined,
                size: 15,
                color: AppColors.brown,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Delete note',
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outline,
                size: 15,
                color: AppColors.brown,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
