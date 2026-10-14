import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/account_data_store.dart';
import '../../../capsules/data/capsule_store.dart';

String capsuleStatus(Map<String, dynamic>? capsule) {
  final date = DateTime.tryParse(
    capsule?['unlockCondition']?['date']?.toString() ?? '',
  )?.toLocal();
  if (capsule?['status'] == 'sealed' &&
      date != null &&
      date.isAfter(DateTime.now())) {
    return 'Sealed until ${date.day}/${date.month}/${date.year}';
  }
  return capsule?['status'] == 'sealed' || capsule?['status'] == 'unlocked'
      ? 'Unlocked'
      : 'Open for contributions';
}

class CapsuleEntriesView extends StatefulWidget {
  const CapsuleEntriesView({super.key});
  @override
  State<CapsuleEntriesView> createState() => _CapsuleEntriesViewState();
}

class _CapsuleEntriesViewState extends State<CapsuleEntriesView> {
  final store = CapsuleStore.instance;
  String? userId;
  @override
  void initState() {
    super.initState();
    store.loadEntries();
    AccountSession.current().then((session) {
      if (mounted) setState(() => userId = session?.userId);
    });
  }

  Future<void> _open(Map<String, dynamic> entry) async {
    final content = entry['content'] as String;
    if (entry['type'] == 'letter' || entry['type'] == 'photo') {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            entry['caption']?.toString().isNotEmpty == true
                ? entry['caption']
                : 'Memory',
          ),
          content: SingleChildScrollView(
            child: entry['type'] == 'letter'
                ? SelectableText(content)
                : Image.network(
                    content,
                    errorBuilder: (_, _, _) =>
                        const Text('Could not load the photo.'),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }
    final uri = Uri.tryParse(content);
    if (uri == null || uri.scheme != 'https' || !await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this memory.')),
        );
      }
    }
  }

  Future<void> _edit(Map<String, dynamic> entry) async {
    final controller = TextEditingController(
      text: entry['type'] == 'letter' ? entry['content'] : entry['caption'],
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit memory'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          maxLength: entry['type'] == 'letter' ? 30000 : 1000,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;
    try {
      await store.saveEntry({
        'type': entry['type'],
        'content': entry['type'] == 'letter' ? result : entry['content'],
        'caption': entry['type'] == 'letter' ? entry['caption'] : result,
      }, entryId: entry['id']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _delete(Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this memory?'),
        content: const Text('This memory will be archived from this capsule.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await store.deleteEntry(entry['id']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      if (store.entriesLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (store.entriesError != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(store.entriesError!, textAlign: TextAlign.center),
            TextButton(
              onPressed: store.loadEntries,
              child: const Text('Retry'),
            ),
          ],
        );
      }
      if (store.entries.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No memories yet. Add your first memory to this capsule.',
            textAlign: TextAlign.center,
          ),
        );
      }
      return Column(
        children: [
          for (final entry in store.entries)
            Card(
              child: ListTile(
                leading: entry['type'] == 'photo'
                    ? Image.network(
                        entry['content'],
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      )
                    : Icon(switch (entry['type']) {
                        'voice' => Icons.mic_outlined,
                        'video' => Icons.play_circle_outline,
                        _ => Icons.mail_outline,
                      }),
                title: Text(
                  entry['caption']?.toString().isNotEmpty == true
                      ? entry['caption']
                      : '${entry['type']} memory',
                ),
                subtitle: Text(
                  entry['contributorId'] == userId
                      ? 'Added by you'
                      : 'Family contributor',
                ),
                onTap: () => _open(entry),
                trailing:
                    entry['contributorId'] == userId &&
                        store.selected?['status'] == 'open'
                    ? PopupMenuButton<String>(
                        onSelected: (value) =>
                            value == 'edit' ? _edit(entry) : _delete(entry),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'remove', child: Text('Remove')),
                        ],
                      )
                    : null,
              ),
            ),
        ],
      );
    },
  );
}
