import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
  String _type = 'Family';
  bool _hasCoverPhoto = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectCoverPhoto() {
    // The screen is ready to connect to image_picker when photo storage is added.
    setState(() => _hasCoverPhoto = true);
  }

  void _createCapsule() {
    if (!_formKey.currentState!.validate()) return;
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
                hasCoverPhoto: _hasCoverPhoto,
                onTap: _selectCoverPhoto,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _createCapsule,
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
  const _CoverPhotoPicker({required this.hasCoverPhoto, required this.onTap});
  final bool hasCoverPhoto;
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
                  Image.asset('assets/images/login_image.jpg', fit: BoxFit.cover),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x99000000)),
                      child: SizedBox(
                        height: 34,
                        width: double.infinity,
                        child: Center(
                          child: Text('Tap to change cover photo',
                              style: TextStyle(color: Colors.white, fontSize: 10)),
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
