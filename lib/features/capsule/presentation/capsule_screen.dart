import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/capsule_prompt_card.dart';
import 'widgets/capsule_tile.dart';

/// Dashboard reached from the Capsule item in the primary navigation.
class CapsuleScreen extends StatelessWidget {
  const CapsuleScreen({super.key});

  void _onNavSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFCFAF9),
    drawer: const HomeDrawer(),
    appBar: AppBar(
      toolbarHeight: 80,
      backgroundColor: const Color(0xFFFFE9EA),
      foregroundColor: AppColors.brown,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 29,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu_rounded, size: 22),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, size: 22),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ayubowan,\nKumari!',
            style: TextStyle(
              color: Color(0xFF30201B),
              fontSize: 30,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your Cultural Legacy',
            style: TextStyle(
              color: Color(0xFF6B5D58),
              fontFamily: 'serif',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 21),
          CapsulePromptCard(onCreate: () {}),
          const SizedBox(height: 17),
          const Text(
            'ACTIVE CAPSULES (LOCKED)',
            style: TextStyle(
              color: Color(0xFF574640),
              fontFamily: 'serif',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .45,
            ),
          ),
          const SizedBox(height: 10),
          const CapsuleTile(),
        ],
      ),
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 3,
      onSelected: (index) => _onNavSelected(context, index),
    ),
  );
}
