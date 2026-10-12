import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../capsule/domain/capsule_model.dart';
import '../../capsule/data/capsule_service.dart';

/// Form used to collect the details for a new time capsule.
class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final CapsuleService _capsuleService = CapsuleService();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  String _type = 'Family';
  XFile? _coverImageFile;
  Uint8List? _coverImageBytes;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectCoverPhoto() async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFDF8F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCCFC9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Add Cover Photo',
              style: TextStyle(
                color: AppColors.brown,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select an image to bring your capsule to life',
              style: TextStyle(color: Color(0xFF897C77), fontSize: 11),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3EAE4),
                child: Icon(Icons.photo_library_outlined, color: AppColors.brown, size: 20),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown),
              ),
              subtitle: const Text('Pick JPG or PNG up to 10 MB', style: TextStyle(fontSize: 10, color: Color(0xFF897C77))),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 4),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3EAE4),
                child: Icon(Icons.camera_alt_outlined, color: AppColors.brown, size: 20),
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown),
              ),
              subtitle: const Text('Use camera to capture now', style: TextStyle(fontSize: 10, color: Color(0xFF897C77))),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            if (_coverImageBytes != null) ...[
              const Divider(height: 20, color: Color(0xFFEDE2DC)),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFDEDED),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                ),
                title: const Text(
                  'Remove Cover Photo',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _coverImageFile = null;
                    _coverImageBytes = null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (bytes.lengthInBytes > 10 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected image exceeds 10 MB limit. Please choose a smaller image.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _coverImageFile = picked;
          _coverImageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createCapsule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    String? coverImageUrl;
    if (_coverImageBytes != null && _coverImageFile != null) {
      try {
        final ext = _coverImageFile!.name.split('.').lastOrNull ?? 'jpg';
        final path = 'capsules/${DateTime.now().millisecondsSinceEpoch}_cover.$ext';
        final mimeType = _coverImageFile!.mimeType ?? 'image/$ext';
        coverImageUrl = await _supabaseService.uploadBytes(
          _coverImageBytes!,
          path,
          mimeType,
        );
      } catch (_) {
        // If Supabase upload fails, gracefully fallback
      }
      coverImageUrl ??= 'assets/images/login_image.jpg';
    }

    final capsule = CapsuleModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _type,
      type: _type,
      coverImageUrl: coverImageUrl,
    );

    final error = await _capsuleService.createCapsule(capsule);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      NotificationService().showNotification(
        title: 'Capsule Created! ✨',
        body: '"${_titleController.text.trim()}" has been safely preserved in your vault.',
        icon: Icons.lock_clock_outlined,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_titleController.text.trim()} capsule created successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green[800],
        ),
      );
      Navigator.maybePop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[800],
        ),
      );
    }
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
                    decoration: _inputDecoration('Sinhala New Year Wishes 2025'),
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
                imageBytes: _coverImageBytes,
                onTap: _selectCoverPhoto,
                onRemove: _coverImageBytes != null
                    ? () => setState(() {
                        _coverImageFile = null;
                        _coverImageBytes = null;
                      })
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _createCapsule,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_outlined, size: 17),
                          SizedBox(width: 8),
                          Text(
                            'Create Capsule',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
        BoxShadow(color: Color(0x083B241D), blurRadius: 13, offset: Offset(0, 5)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: Color(0xFF897C77), fontSize: 9)),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _CoverPhotoPicker extends StatelessWidget {
  const _CoverPhotoPicker({
    required this.imageBytes,
    required this.onTap,
    this.onRemove,
  });

  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

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
      child: imageBytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes!, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 36,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xCC000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.bottomCenter,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Tap to change cover photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onRemove,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 15,
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
                  child: Icon(Icons.add_a_photo_outlined,
                      color: AppColors.brown, size: 25),
                ),
                SizedBox(height: 10),
                Text('Upload or take a photo',
                    style: TextStyle(
                        color: AppColors.brown,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('JPG or PNG, up to 10 MB',
                    style: TextStyle(color: Color(0xFF897C77), fontSize: 8)),
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
                      color: value == type ? AppColors.brown : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: value == type ? Colors.white : AppColors.brown,
                        fontSize: 9,
                        fontWeight: value == type ? FontWeight.w700 : FontWeight.w500,
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
