import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/account_data_store.dart';
import '../../../core/services/supabase_service.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:convert';

/// Form used to collect the details for a new time capsule.
class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key, this.chainedFromCapsuleId});
  final String? chainedFromCapsuleId;

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'Family';
  bool _hasCoverPhoto = false, _saving = false, _uploading = false;
  String? _coverPhotoUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectCoverPhoto() async {
    if (_saving || _uploading) return;
    final session = await AccountSession.current();
    if (session == null || !mounted) return;
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Images',
            extensions: ['jpg', 'jpeg', 'png', 'webp'],
            mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
            uniformTypeIdentifiers: ['public.image'],
          ),
        ],
      );
      if (file == null || !mounted) return;
      setState(() => _uploading = true);
      if (await file.length() > 10 * 1024 * 1024) {
        throw StateError('Choose an image smaller than 10 MB.');
      }
      final extension = file.name.split('.').last.toLowerCase();
      final mimeType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final url = await SupabaseService().uploadBytes(
        await file.readAsBytes(),
        'capsules/${session.userId}/${DateTime.now().microsecondsSinceEpoch}.$extension',
        mimeType,
      );
      if (!mounted || !await session.isCurrent) return;
      setState(() {
        _coverPhotoUrl = url;
        _hasCoverPhoto = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _createCapsule() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final session = await AccountSession.current();
      if (session == null) throw StateError('Please sign in.');
      final response = await ApiService().post(
        '/capsules',
        sessionToken: session.token,
        body: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'type': _type.toLowerCase(),
          'privacy': 'private',
          'coverPhotoUrl': _coverPhotoUrl,
          'chainedFromCapsuleId': widget.chainedFromCapsuleId,
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw StateError(
          body['errorDescription'] ?? 'Could not create the capsule.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_titleController.text.trim()} capsule created'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFCFAF9),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFDFC),
      foregroundColor: AppColors.brown,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        'Create New Capsule',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 17),
        onPressed: () => Navigator.maybePop(context),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFEDE7E2)),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
          children: [
            _FormSection(
              title: '1. Define Capsule',
              subtitle: 'Give this memory a meaningful home.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _InputLabel('Title'),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      'Sinhala New Year Wishes 2025',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a capsule title'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  const _InputLabel('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      'A collection of greetings from the entire family...',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Add a short description'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  const _InputLabel('Who can view it?'),
                  _CapsuleTypePicker(
                    value: _type,
                    onChanged: (value) => setState(() => _type = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _FormSection(
              title: '2. Add Cover Photo',
              subtitle: 'Choose an image that brings this capsule to life.',
              child: _CoverPhotoPicker(
                hasCoverPhoto: _hasCoverPhoto,
                coverUrl: _coverPhotoUrl,
                onTap: _selectCoverPhoto,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _saving || _uploading ? null : _createCapsule,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_outlined, size: 17),
                    SizedBox(width: 8),
                    Text(
                      'Create Capsule',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hintText) => InputDecoration(
  hintText: hintText,
  hintStyle: const TextStyle(color: Color(0xFF7B7270), fontSize: 10),
  filled: true,
  fillColor: const Color(0xFFFFFEFD),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: Color(0xFFE5DDD8)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: Color(0xFFE5DDD8)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: AppColors.brown),
  ),
);

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppColors.brown,
      fontFamily: 'serif',
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      label,
      style: const TextStyle(color: AppColors.brown, fontSize: 10),
    ),
  );
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF0E8E3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x083B241D),
          blurRadius: 13,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF897C77), fontSize: 9),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _CoverPhotoPicker extends StatelessWidget {
  const _CoverPhotoPicker({
    required this.hasCoverPhoto,
    required this.onTap,
    this.coverUrl,
  });
  final bool hasCoverPhoto;
  final String? coverUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Ink(
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F4F1),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFEADFD9)),
      ),
      child: hasCoverPhoto
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x99000000)),
                      child: SizedBox(
                        height: 34,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Tap to change cover photo',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.brown,
                    size: 25,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Upload or take a photo',
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'JPG or PNG, up to 10 MB',
                  style: TextStyle(color: Color(0xFF897C77), fontSize: 8),
                ),
              ],
            ),
    ),
  );
}

class _CapsuleTypePicker extends StatelessWidget {
  const _CapsuleTypePicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(9),
    child: Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE5DDD8)),
      ),
      child: Row(
        children: ['Personal', 'Family', 'Community']
            .map(
              (type) => Expanded(
                child: InkWell(
                  onTap: () => onChanged(type),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == type
                          ? AppColors.brown
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: value == type ? Colors.white : AppColors.brown,
                        fontSize: 9,
                        fontWeight: value == type
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}
