import 'package:flutter/material.dart';

import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../domain/capsule_model.dart';
import '../data/capsule_service.dart';
import 'widgets/capsule_prompt_card.dart';
import 'widgets/capsule_tile.dart';

// ── Local palette ─────────────────────────────────────────────────────────────
const _kBg = Color(0xFFFDF8F5);
const _kBrown = Color(0xFF84321F);
const _kDeep = Color(0xFF39231B);
const _kMuted = Color(0xFF6B5D58);
const _kBorder = Color(0xFFEEDFD9);
const _kPeach = Color(0xFFFFE8DA);

/// Dashboard reached from the Capsule item in the primary navigation.
class CapsuleScreen extends StatefulWidget {
  const CapsuleScreen({super.key});

  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  final CapsuleService _capsuleService = CapsuleService();
  List<CapsuleModel> _capsules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCapsules();
  }

  Future<void> _loadCapsules() async {
    setState(() => _isLoading = true);
    final list = await _capsuleService.getCapsules();
    if (!mounted) return;
    setState(() {
      _capsules = list;
      _isLoading = false;
    });
  }

  Future<void> _navigateToCreate() async {
    final res = await Navigator.pushNamed(context, '/create-capsule');
    if (res == true) {
      _loadCapsules();
    }
  }

  void _onNavSelected(BuildContext context, int index) {
    navigateToPrimaryDestination(context, index, currentIndex: 3);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _kBg,
      drawer: const HomeDrawer(selectedSection: 'Time capsule'),
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: _kBg,
        foregroundColor: _kBrown,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Rootly',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _kBrown,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: l10n.openMenuTooltip,
            icon: const Icon(Icons.menu_rounded, size: 21),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.switchLanguageTooltip,
            onPressed: () =>
                AppLanguageProvider.instance.showLanguageDialog(context),
            icon: const Icon(Icons.language, size: 21),
          ),
          IconButton(
            tooltip: l10n.notificationsTooltip,
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, size: 21),
          ),
          const SizedBox(width: 4),
        ],
        // Thin bottom divider instead of shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _kBorder),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kBrown))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero greeting ─────────────────────────────────────────────
            Text(
              l10n.capsuleHeroTitle,
              style: const TextStyle(
                color: _kDeep,
                fontSize: 31,
                height: .97,
                fontWeight: FontWeight.w800,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.capsuleHeroSubtitle,
              style: const TextStyle(
                color: _kMuted,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 26),

            // ── Stat chips row ────────────────────────────────────────────
            _StatRow(capsuleCount: _capsules.isNotEmpty ? _capsules.length : 1),
            const SizedBox(height: 24),

            // ── Prompt / hero card ────────────────────────────────────────
            CapsulePromptCard(
              onCreate: _navigateToCreate,
            ),
            const SizedBox(height: 28),

            // ── Section header ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.yourTimeCapsules,
                  style: const TextStyle(
                    color: Color(0xFF574640),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/family-receipt'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _kPeach,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDDB69E)),
                    ),
                    child: Text(
                      '1 ${l10n.statProtected.toLowerCase()}',
                      style: const TextStyle(
                        color: _kBrown,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const CapsuleTile(),
            const SizedBox(height: 14),

            // ── Empty state hint ──────────────────────────────────────────
            _EmptyStateHint(
              onTap: _navigateToCreate,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 3,
        onSelected: (index) => _onNavSelected(context, index),
      ),
    );
  }
}

// ── Stat chips ────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({this.capsuleCount = 1});
  final int capsuleCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _StatChip(
          icon: Icons.lock_clock_outlined,
          value: capsuleCount.toString().padLeft(2, '0'),
          label: l10n.statCapsules,
          bg: const Color(0xFFFFECDE),
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.favorite_border_rounded,
          value: '12',
          label: l10n.statMemories,
          bg: const Color(0xFFE4EFEA),
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.people_outline_rounded,
          value: '04',
          label: l10n.statContributors,
          bg: const Color(0xFFF0EBF8),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.bg,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: const Color(0xFF5E3A30)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF38251F),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF7A5E55), fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state dashed hint ───────────────────────────────────────────────────

class _EmptyStateHint extends StatelessWidget {
  const _EmptyStateHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPeach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: _kBrown, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.plantCapsulePrompt,
                    style: const TextStyle(
                      color: _kDeep,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.plantCapsuleSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFFBBA9A2),
            ),
          ],
        ),
      ),
    );
  }
}
