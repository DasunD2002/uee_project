import 'package:flutter/material.dart';
import '../localization/app_language_provider.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommunityAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
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
          tooltip: l10n.openMenuTooltip,
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu),
        ),
      ),
      actions: [
        IconButton(
          tooltip: l10n.switchLanguageTooltip,
          onPressed: () => AppLanguageProvider.instance.showLanguageDialog(context),
          icon: const Icon(Icons.language),
        ),
        IconButton(
          tooltip: l10n.notificationsTooltip,
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(Icons.notifications_none),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
