import 'package:flutter/material.dart';
import '../../capsules/data/capsule_store.dart';
import 'widgets/capsule_entries_view.dart';

import '../../../core/theme/app_colors.dart';

/// The individual memories stored in the Family Recipe capsule.
class FamilyMemoriesScreen extends StatelessWidget {
  const FamilyMemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFECEE),
      foregroundColor: AppColors.brown,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 76,
      leading: const Icon(Icons.menu_rounded),
      centerTitle: true,
      title: const Text(
        'Rootly',
        style: TextStyle(
          color: AppColors.brown,
          fontFamily: 'serif',
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, size: 23),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _RoundBackButton(onPressed: () => Navigator.pop(context)),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    CapsuleStore.instance.selected?['title'] ?? 'Your memories',
                    style: TextStyle(
                      color: AppColors.brown,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Divider(color: Color(0xFFEEDFD9), height: 1),
            const SizedBox(height: 26),
            const Text('Tap any memory to open it.'),
            const SizedBox(height: 14),
            const CapsuleEntriesView(),
            const SizedBox(height: 29),
            const Divider(color: Color(0xFFEEDFD9), height: 1),
            const SizedBox(height: 19),
            SizedBox(
              height: 41,
              child: FilledButton.icon(
                onPressed: () async {
                  final store = CapsuleStore.instance;
                  final parent = store.selected;
                  try {
                    await store.createResponse();
                    if (context.mounted) {
                      await Navigator.pushNamed(context, '/response-capsule');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  } finally {
                    if (parent != null) store.select(parent);
                  }
                },
                icon: const Icon(Icons.hub_outlined, size: 17),
                label: const Text(
                  'Create a Response Capsule',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD6B6),
                  foregroundColor: AppColors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 29,
    height: 29,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.brown,
        side: const BorderSide(color: Color(0xFFE9D9D3)),
        shape: const CircleBorder(),
      ),
      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 13),
    ),
  );
}
