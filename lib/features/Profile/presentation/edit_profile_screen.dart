import 'package:flutter/material.dart';
import '../../../core/widgets/auth_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.details});
  final Map<String, String> details;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> fields;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    fields = widget.details.map(
      (k, v) => MapEntry(k, TextEditingController(text: v)),
    );
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      final details = fields.map((k, v) => MapEntry(k, v.text.trim()));
      if (mounted) Navigator.pop(context, details);
    } catch (_) {
      if (mounted) {
        setState(() => saving = false);
        showMessage(context, 'Could not save your profile. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Profile Data')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Profile information',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Choose what people see on your profile.'),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                AuthField(
                  label: 'Name',
                  controller: fields['name'],
                  validator: (v) =>
                      (v?.trim().length ?? 0) < 2 ? 'Enter your name' : null,
                ),
                const SizedBox(height: 18),
                AuthField(
                  label: 'Username',
                  controller: fields['handle'],
                  validator: (v) =>
                      !RegExp(
                        r'^@[a-zA-Z0-9._]{3,30}$',
                      ).hasMatch(v?.trim() ?? '')
                      ? 'Use @ followed by 3–30 letters, numbers, dots or underscores'
                      : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: fields['bio'],
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 200,
                  decoration: fieldDecoration(
                    'Bio',
                    'Tell people about yourself',
                  ),
                ),
                const SizedBox(height: 18),
                AuthField(label: 'Location', controller: fields['location']),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: Text(saving ? 'Saving...' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
