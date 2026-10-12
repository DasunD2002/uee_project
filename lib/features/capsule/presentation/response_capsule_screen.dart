import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../capsules/data/capsule_store.dart';
import 'widgets/capsule_entries_view.dart';

class ResponseCapsuleScreen extends StatefulWidget {
  const ResponseCapsuleScreen({super.key});
  @override
  State<ResponseCapsuleScreen> createState() => _ResponseCapsuleScreenState();
}

enum _CapsuleMenuAction { edit, delete, lock }

class _ResponseCapsuleScreenState extends State<ResponseCapsuleScreen> {
  final store = CapsuleStore.instance;
  void _onNavSelected(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
    if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    }
    if (index == 3) {
      Navigator.pushNamedAndRemoveUntil(context, '/capsules', (_) => false);
    }
  }

  Future<void> _onMenuSelected(_CapsuleMenuAction action) async {
    if (action == _CapsuleMenuAction.edit) {
      await Navigator.pushNamed(context, '/edit-capsule');
      return;
    }
    final remove = action == _CapsuleMenuAction.delete;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(remove ? 'Delete Capsule?' : 'Seal Capsule?'),
        content: Text(
          remove
              ? 'This capsule will be archived from your vault. Its memories will be retained.'
              : 'Memories will be locked until the unlock date. Set that date in Edit Capsule Details before sealing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(remove ? 'Delete' : 'Seal'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      if (remove) {
        await store.delete();
        if (mounted) Navigator.pop(context);
      } else {
        await store.seal();
      }
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
    builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        toolbarHeight: 72,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(
          store.selected?['title'] ?? 'Your capsule',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          PopupMenuButton<_CapsuleMenuAction>(
            tooltip: 'More options',
            onSelected: _onMenuSelected,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _CapsuleMenuAction.edit,
                child: Text('Edit Capsule Details'),
              ),
              PopupMenuItem(
                value: _CapsuleMenuAction.delete,
                child: Text('Delete Capsule'),
              ),
              PopupMenuItem(
                value: _CapsuleMenuAction.lock,
                child: Text('Lock Settings'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.selected?['title'] ?? 'Your capsule',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(store.selected?['description'] ?? ''),
                  const SizedBox(height: 8),
                  Text(capsuleStatus(store.selected)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Contributions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const CapsuleEntriesView(),
        ],
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 3,
        onSelected: _onNavSelected,
      ),
    ),
  );
}
