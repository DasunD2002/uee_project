import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true, activity = true, loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        notifications = prefs.getBool('settings.notifications') ?? true;
        activity = prefs.getBool('settings.activity') ?? true;
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> update(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = value is bool
          ? await prefs.setBool(key, value)
          : await prefs.setString(key, value as String);
      if (!ok) throw StateError('Save failed');
      if (!mounted) return;
      setState(() {
        if (key == 'settings.notifications') notifications = value as bool;
        if (key == 'settings.activity') activity = value as bool;
      });
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotSavePreference),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = AppLanguageProvider.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        title: Text(l10n.settingsTitle),
        backgroundColor: const Color(0xFFFAF8F6),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.makeRootlyYours,
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.manageAccountAndPreferences,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 26),

              // LANGUAGE SECTION
              _Section(l10n.sectionLanguage),
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.language,
                          color: AppColors.brown,
                        ),
                        title: Text(
                          l10n.appLanguageTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          languageProvider.currentLanguage.displayName,
                          style: const TextStyle(fontSize: 13, color: AppColors.brown),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => languageProvider.showLanguageDialog(context),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: SegmentedButton<AppLanguage>(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Color(0xFFFFEAEA);
                                }
                                return Colors.transparent;
                              },
                            ),
                            foregroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.brown;
                                }
                                return Colors.black87;
                              },
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: AppLanguage.english,
                              label: Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            ButtonSegment(
                              value: AppLanguage.sinhala,
                              label: Text('සිංහල', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            ButtonSegment(
                              value: AppLanguage.tamil,
                              label: Text('தமிழ்', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                          selected: {languageProvider.currentLanguage},
                          onSelectionChanged: (newSelection) {
                            languageProvider.setLanguage(newSelection.first);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ACCOUNT SECTION
              _Section(l10n.sectionAccount),
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.person_outline,
                        color: AppColors.brown,
                      ),
                      title: Text(l10n.myProfile),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                        color: AppColors.brown,
                      ),
                      title: Text(l10n.changePassword),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, '/change-password'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // PREFERENCES SECTION
              _Section(l10n.sectionPreferences),
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.notificationsTitle),
                      subtitle: Text(l10n.notificationsSubtitle),
                      value: notifications,
                      onChanged: loading
                          ? null
                          : (v) => update('settings.notifications', v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(l10n.activityStatusTitle),
                      subtitle: Text(l10n.activityStatusSubtitle),
                      value: activity,
                      onChanged: loading
                          ? null
                          : (v) => update('settings.activity', v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                ),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logOutButton),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.rootlyTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        color: AppColors.brown,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
