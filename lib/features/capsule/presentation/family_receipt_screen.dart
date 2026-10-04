import '../../capsules/data/capsule_store.dart';
import 'widgets/capsule_entries_view.dart';

import 'package:flutter/material.dart';

import '../../explorer/presentation/widgets/explorer_footer.dart';
import 'add_memory_screen.dart';

// ── Local colour tokens ──────────────────────────────────────────────────────
const _kBrown = Color(0xFF84321F);
const _kPeach = Color(0xFFFFF3E8);
const _kPeachBd = Color(0xFFD9B49E);

/// Contents of the selected time capsule.
class FamilyReceiptScreen extends StatefulWidget {
  const FamilyReceiptScreen({super.key});

  @override
  State<FamilyReceiptScreen> createState() => _FamilyReceiptScreenState();
}

class _FamilyReceiptScreenState extends State<FamilyReceiptScreen>
    with TickerProviderStateMixin {
  // Glow pulse on the primary CTA
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  void _onNavSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, '/capsules', (_) => false);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CapsuleStore.instance,
    builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xFFFFF8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EF),
        foregroundColor: _kBrown,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back to capsules',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text(
          'Your capsule',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Capsule settings',
            onPressed: () => Navigator.pushNamed(context, '/response-capsule'),
            icon: const Icon(Icons.more_vert),
          ),
          IconButton(
            tooltip: 'Share capsule',
            onPressed: () => _showShareSheet(context),
            icon: const Icon(Icons.ios_share_rounded, size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 28),
          child: Column(
            children: [
              // ── Title ─────────────────────────────────────────────────
              Text(
                CapsuleStore.instance.selected?['title'] ?? 'Your capsule',
                style: TextStyle(
                  color: _kBrown,
                  fontFamily: 'serif',
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // ── Unlock status badge ────────────────────────────────────
              Text(capsuleStatus(CapsuleStore.instance.selected)),
              const SizedBox(height: 10),

              // ── Contributor avatars + memory counter ───────────────────
              Text('${CapsuleStore.instance.entries.length} memories'),
              const SizedBox(height: 18),

              // ── Polaroid scatter ───────────────────────────────────────
              const Expanded(
                child: SingleChildScrollView(child: CapsuleEntriesView()),
              ),

              // ── Action buttons row ─────────────────────────────────────
              const SizedBox(height: 12),
              _ActionButtonsRow(
                onAddMemory: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
                ),
                onVoiceNote: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
                ),
              ),
              const SizedBox(height: 10),

              // ── Primary CTA with glow ──────────────────────────────────
              _GlowCTA(
                glowCtrl: _glowCtrl,
                onPressed: () =>
                    Navigator.pushNamed(context, '/family-memories'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 3,
        onSelected: (index) => _onNavSelected(context, index),
      ),
    ),
  );

  Future<void> _showShareSheet(BuildContext context) async {
    final controller = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite a contributor'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Contributor user ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (id == null || id.isEmpty) return;
    try {
      await CapsuleStore.instance.invite(id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contributor invited.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

// ── Action buttons row ────────────────────────────────────────────────────────

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.onAddMemory,
    required this.onVoiceNote,
  });
  final VoidCallback onAddMemory;
  final VoidCallback onVoiceNote;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onAddMemory,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text(
              'Add Memory',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kBrown,
              side: const BorderSide(color: _kPeachBd, width: 1.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: _kPeach,
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onVoiceNote,
            icon: const Icon(Icons.mic_none_rounded, size: 17),
            label: const Text(
              'Voice Note',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kBrown,
              side: const BorderSide(color: _kPeachBd, width: 1.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: const Color(0xFFFFF8F0),
            ),
          ),
        ),
      ),
    ],
  );
}

// ── Glow CTA ──────────────────────────────────────────────────────────────────

class _GlowCTA extends StatelessWidget {
  const _GlowCTA({required this.glowCtrl, required this.onPressed});
  final AnimationController glowCtrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowCtrl,
      builder: (_, child) => Container(
        width: double.infinity,
        height: 47,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: _kBrown.withAlpha((60 + 80 * glowCtrl.value).toInt()),
              blurRadius: 14 + 10 * glowCtrl.value,
              spreadRadius: glowCtrl.value * 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _kBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Text(
          'View Your Memories',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
