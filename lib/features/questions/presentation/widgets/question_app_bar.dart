import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class QuestionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuestionAppBar({
    super.key,
    this.showBackButton = false,
    this.showNotifications = true,
  });

  final bool showBackButton;
  final bool showNotifications;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 72,
    backgroundColor: const Color(0xFFFFEEEE),
    foregroundColor: AppColors.brown,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: showBackButton
        ? IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
          )
        : Builder(
            builder: (scaffoldContext) => IconButton(
              tooltip: 'Open menu',
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
              icon: const Icon(Icons.menu_rounded, size: 21),
            ),
          ),
    title: const Text(
      'Rootly',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 27,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: [
      if (showNotifications)
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, size: 21),
        )
      else
        const SizedBox(width: 48),
      const SizedBox(width: 3),
    ],
  );
}
