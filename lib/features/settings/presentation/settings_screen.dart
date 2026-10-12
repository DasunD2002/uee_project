import 'package:flutter/material.dart';
import '../../../core/services/account_data_store.dart';
import '../../auth/data/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final document = AccountDataStore('preferences');
  bool notifications = true, activity = true, loading = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      await document.load();
      if (!mounted) return;
      setState(() {
        notifications = document.data['notifications'] as bool? ?? true;
        activity = document.data['activity'] as bool? ?? true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> update(String key, Object value) async {
    try {
      setState(() => loading = true);
      await document.load();
      await document.save({
        ...document.data,
        key.replaceFirst('settings.', ''): value,
      });
      if (!mounted) return;
      setState(() {
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
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    document.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAF8F6),
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushNamed(context, '/profile'),
      ),
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
              onPressed: () async {
                await AuthService().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
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
