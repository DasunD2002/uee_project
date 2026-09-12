import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommunityAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(80);
  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 80,
    backgroundColor: const Color(0xFFFFEAEA),
    foregroundColor: AppColors.brown,
    centerTitle: true,
    title: const Text(
      'Rootly',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 38,
        fontWeight: FontWeight.bold,
      ),
    ),
    leading: Builder(
      builder: (context) => IconButton(
        tooltip: 'Open menu',
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(Icons.menu),
      ),
    ),
    actions: [
      IconButton(
        tooltip: 'Notifications',
        onPressed: () => Navigator.pushNamed(context, '/notifications'),
        icon: const Icon(Icons.notifications_none),
      ),
      const SizedBox(width: 12),
    ],
  );
}
