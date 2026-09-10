import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String language = 'English';
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
        language = prefs.getString('settings.language') ?? 'English';
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
        if (key == 'settings.language') language = value as String;
        if (key == 'settings.notifications') notifications = value as bool;
        if (key == 'settings.activity') activity = value as bool;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your preference. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAF8F6),
    drawer: const HomeDrawer(selectedSection: 'Settings'),
    appBar: AppBar(
      title: const Text('Settings'),
      backgroundColor: const Color(0xFFFAF8F6),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Make Rootly yours',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your account and preferences.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 26),
            const _Section('ACCOUNT'),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: AppColors.brown,
                    ),
                    title: const Text('My profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: AppColors.brown,
                    ),
                    title: const Text('Change password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, '/change-password'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _Section('PREFERENCES'),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  key: ValueKey(language),
                  initialValue: language,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Preferred language',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(
                      value: 'Sinhala',
                      child: Text('සිංහල · Sinhala'),
                    ),
                    DropdownMenuItem(
                      value: 'Tamil',
                      child: Text('தமிழ் · Tamil'),
                    ),
                  ],
                  onChanged: loading
                      ? null
                      : (v) {
                          if (v != null) update('settings.language', v);
                        },
                ),
              ),
            ),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Receive story and community updates'),
                    value: notifications,
                    onChanged: loading
                        ? null
                        : (v) => update('settings.notifications', v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Activity status'),
                    subtitle: const Text('Let others see when you are active'),
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
              label: const Text('Log out'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rootly • Explore culture. Share your story.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
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
