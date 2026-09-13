import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';

/// Detail view for the "Grandson's 18th Birthday" response capsule,
/// showing the header card and a chronological contributions timeline.
class ResponseCapsuleScreen extends StatefulWidget {
  const ResponseCapsuleScreen({super.key});

  @override
  State<ResponseCapsuleScreen> createState() => _ResponseCapsuleScreenState();
}

enum _CapsuleMenuAction { edit, delete, lock }

class _ResponseCapsuleScreenState extends State<ResponseCapsuleScreen> {
  void _onNavSelected(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, '/capsules', (_) => false);
    }
  }

  void _onMenuSelected(_CapsuleMenuAction action) {
    switch (action) {
      case _CapsuleMenuAction.edit:
        Navigator.pushNamed(context, '/edit-capsule');
      case _CapsuleMenuAction.delete:
        _confirmDelete();
      case _CapsuleMenuAction.lock:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lock settings coming soon'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.brown,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
    }
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Capsule?',
            style: TextStyle(color: Color(0xFF4A2E2B), fontWeight: FontWeight.w800)),
        content: const Text(
          'This will permanently remove the capsule and all its memories. This cannot be undone.',
          style: TextStyle(color: Color(0xFF9E7A6E), fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF4A2E2B))),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC0574A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8F3),
    appBar: AppBar(
      backgroundColor: AppColors.brown,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 72,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
      centerTitle: false,
      title: const Text(
        "Grandson's 18th Birthday",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      actions: [
        PopupMenuButton<_CapsuleMenuAction>(
          tooltip: 'More options',
          icon: const Icon(Icons.more_vert_rounded, size: 22),
          onSelected: _onMenuSelected,
          color: const Color(0xFFFFF8F0),
          elevation: 8,
          shadowColor: const Color(0x333B1F14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => [
            // ── Edit ──────────────────────────────────────────────────────
            PopupMenuItem<_CapsuleMenuAction>(
              value: _CapsuleMenuAction.edit,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDE0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4A2E2B)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Capsule Details',
                    style: TextStyle(
                      color: Color(0xFF2E1A14),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // ── Divider ───────────────────────────────────────────────────
            const PopupMenuDivider(height: 1),
            // ── Delete ────────────────────────────────────────────────────
            PopupMenuItem<_CapsuleMenuAction>(
              value: _CapsuleMenuAction.delete,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCECEA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFC0574A)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delete Capsule',
                    style: TextStyle(
                      color: Color(0xFFC0574A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // ── Divider ───────────────────────────────────────────────────
            const PopupMenuDivider(height: 1),
            // ── Lock settings ─────────────────────────────────────────────
            PopupMenuItem<_CapsuleMenuAction>(
              value: _CapsuleMenuAction.lock,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF3A5FA0)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lock Settings',
                    style: TextStyle(
                      color: Color(0xFF2E1A14),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: const [
          _CapsuleHeaderCard(),
          SizedBox(height: 28),
          Text(
            'Contributions',
            style: TextStyle(
              color: Color(0xFF2E1A14),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -.3,
            ),
          ),
          SizedBox(height: 16),
          _ContributionTimeline(),
        ],
      ),
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 3,
      onSelected: _onNavSelected,
    ),
  );
}

// -- Header Card --------------------------------------------------------------

class _CapsuleHeaderCard extends StatelessWidget {
  const _CapsuleHeaderCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Color(0x133B1F14), blurRadius: 18, offset: Offset(0, 6)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/images/login_image.jpg',
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grandson's 18th Birthday",
                    style: TextStyle(
                      color: Color(0xFF2E1A14),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _AvatarStack(),
                      const SizedBox(width: 7),
                      const Text(
                        'Grandma, Uncle, Cousin',
                        style: TextStyle(color: Color(0xFF7A5C52), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8C9B5)),
          ),
          child: const Text(
            'Open (Until June 10, 2027)',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AvatarStack extends StatelessWidget {
  final _avatarColors = const [
    Color(0xFFD4A89A),
    Color(0xFF9BC4B2),
    Color(0xFFA8BDD4),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46,
    height: 20,
    child: Stack(
      children: [
        for (var i = 0; i < _avatarColors.length; i++)
          Positioned(
            left: i * 14.0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _avatarColors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    ),
  );
}

// -- Contribution Timeline ----------------------------------------------------

class _ContributionTimeline extends StatelessWidget {
  const _ContributionTimeline();

  static const _contributions = <_ContributionData>[
    _ContributionData(
      icon: Icons.mic_none_rounded,
      iconBg: Color(0xFFFFE8DA),
      title: 'Voice Recording — A story about his father',
      author: 'Grandma Kumari',
      date: 'Apr 14, 2024',
      duration: '2:14',
      isOwn: false,
    ),
    _ContributionData(
      icon: Icons.play_circle_outline_rounded,
      iconBg: Color(0xFFE3EEE8),
      title: 'Video Wish — Happy Birthday!',
      author: 'Cousin Dinuka',
      date: 'Apr 18, 2024',
      duration: '0:48',
      isOwn: false,
    ),
    _ContributionData(
      icon: Icons.description_outlined,
      iconBg: Color(0xFFEDE8F5),
      title: 'Traditional Proverb — "Watura giya thanata..."',
      author: 'Uncle Sarath',
      date: 'May 2, 2024',
      duration: null,
      isOwn: false,
    ),
    _ContributionData(
      icon: Icons.mail_outline_rounded,
      iconBg: Color(0xFFFFF0E5),
      title: 'Written Letter — Advice for the future',
      author: 'You',
      date: 'May 9, 2024',
      duration: null,
      isOwn: true,
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < _contributions.length; i++)
        _TimelineRow(
          data: _contributions[i],
          isLast: i == _contributions.length - 1,
        ),
    ],
  );
}

class _ContributionData {
  const _ContributionData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.author,
    required this.date,
    required this.duration,
    required this.isOwn,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String author;
  final String date;
  final String? duration;
  final bool isOwn;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.data, required this.isLast});
  final _ContributionData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Timeline spine
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.brown,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD9C0), width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: const Color(0xFFE5CFC7),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Contribution card
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0E4DF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A3B1F14),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, color: AppColors.brown, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Color(0xFF2E1A14),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.duration != null
                              ? '${data.author} · ${data.date} · ${data.duration}'
                              : '${data.author} · ${data.date}',
                          style: const TextStyle(
                            color: Color(0xFF9E7A6E),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (data.isOwn) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.edit_outlined, color: Color(0xFFBDA89F), size: 17),
                    const SizedBox(width: 4),
                    const Icon(Icons.delete_outline_rounded, color: Color(0xFFBDA89F), size: 17),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
