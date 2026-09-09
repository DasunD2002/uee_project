import 'dart:typed_data';
import '../domain/profile_photo_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool saving = false,
      picking = false,
      photoChanged = false,
      photoLoading = true;
  Uint8List? photo;
  Future<void> loadPhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString('profile.avatar');
      if (mounted) {
        setState(() => photo = encoded == null ? null : base64Decode(encoded));
      }
    } catch (_) {
      if (mounted) showMessage(context, 'Could not load your photo.');
    } finally {
      if (mounted) setState(() => photoLoading = false);
    }
  }

  Future<void> changePhoto() async {
    setState(() => picking = true);
    try {
      final bytes = await pickProfilePhoto();
      if (bytes != null && mounted) {
        setState(() {
          photo = bytes;
          photoChanged = true;
        });
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Choose a valid JPG or PNG under 10 MB.');
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadPhoto();
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
      final prefs = await SharedPreferences.getInstance();
      if (photoChanged &&
          photo != null &&
          !await prefs.setString('profile.avatar', base64Encode(photo!))) {
        throw StateError('Photo save failed');
      }
      if (!await prefs.setString('profile.details', jsonEncode(details))) {
        throw StateError('Save failed');
      }
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
                Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: photo == null
                        ? const AssetImage('assets/images/profile_avatar.png')
                        : MemoryImage(photo!),
                  ),
                ),
                TextButton.icon(
                  onPressed: photoLoading || picking || saving
                      ? null
                      : changePhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                    picking ? 'Opening photo...' : 'Change profile image',
                  ),
                ),
                const SizedBox(height: 20),
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
                  onPressed: saving || picking || photoLoading ? null : save,
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
