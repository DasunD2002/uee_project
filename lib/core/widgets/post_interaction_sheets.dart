import 'package:flutter/material.dart';
import '../../features/Profile/domain/social_store.dart';

Future<String?> askCollectionName(BuildContext context) => showDialog<String>(
  context: context,
  builder: (context) {
    String name = '';
    return StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: const Text('Create New collection'),
        content: TextField(
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Collection name'),
          onChanged: (v) => update(() => name = v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: name.isEmpty ? null : () => Navigator.pop(context, name),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  },
);

Future<void> chooseSavedCollections(
  BuildContext context,
  SavedStory story,
) async {
  final store = SocialStore.instance;
  final selected = store.collections
      .where((c) => c.stories.containsKey(story.id))
      .toSet();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Save to collection',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Choose where to keep this story.'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Create New collection'),
                onTap: () async {
                  final name = await askCollectionName(context);
                  if (name == null || !context.mounted) return;
                  final collection = store.addCollection(name);
                  update(() => selected.add(collection));
                },
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final collection in store.collections)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(collection.name),
                        subtitle: Text('${collection.count} stories'),
                        value: selected.contains(collection),
                        onChanged: (value) => update(() {
                          if (value == true) {
                            selected.add(collection);
                          } else {
                            selected.remove(collection);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  store.saveTo(story, selected);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> reportPost(BuildContext context, String id) async {
  String? reason;
  final result = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: const Text('Report the post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: [
                'Spam',
                'Harassment',
                'Inappropriate content',
                'False information',
                'Other',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => update(() => reason = v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: reason == null
                ? null
                : () => Navigator.pop(context, reason),
            child: const Text('Report'),
          ),
        ],
      ),
    ),
  );
  if (result == null || !context.mounted) return;
  SocialStore.instance.reports[id] = result;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Report saved on this device.')));
}
