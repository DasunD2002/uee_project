import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/capsule_memory.dart';

const _kBrown = Color(0xFF84321F);
const _kBrownDeep = Color(0xFF5A1E0E);
const _kMuted = Color(0xFFA07060);
const _kBorder = Color(0xFFEEDFD9);
const _kPeach = Color(0xFFFFF3E8);

class AddMemoryPickerSheet extends StatelessWidget {
  const AddMemoryPickerSheet({super.key});

  static Future<CapsuleMemory?> show(BuildContext context) {
    return showModalBottomSheet<CapsuleMemory?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMemoryPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD9C4BC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Add a Memory',
            style: TextStyle(
              color: _kBrownDeep,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the type of memory to seal inside this capsule',
            style: TextStyle(color: _kMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.photo_library_outlined,
            title: 'Photo Memory',
            subtitle: 'Pick from gallery or capture with camera',
            onTap: () async {
              Navigator.pop(context);
              final memory = await _pickPhotoOrVideo(context, isVideo: false);
              if (memory != null && context.mounted) {
                // Handled
              }
            },
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.videocam_outlined,
            title: 'Video Memory',
            subtitle: 'Preserve moving moments and greetings',
            onTap: () async {
              Navigator.pop(context);
              await _pickPhotoOrVideo(context, isVideo: true);
            },
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.mail_outline_rounded,
            title: 'Write a Letter',
            subtitle: 'Pen down personal thoughts, recipes, or wisdom',
            onTap: () async {
              Navigator.pop(context);
              await _openLetterEditor(context);
            },
          ),
        ],
      ),
    );
  }

  static Future<CapsuleMemory?> _pickPhotoOrVideo(BuildContext context, {required bool isVideo}) async {
    final picker = ImagePicker();

    // Source selection sheet (Camera or Gallery)
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFDF8F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isVideo ? 'Choose Video Source' : 'Choose Photo Source',
              style: const TextStyle(color: _kBrownDeep, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _kBrown),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _kBrown),
              title: const Text('Capture with Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    try {
      XFile? picked;
      if (isVideo) {
        picked = await picker.pickVideo(source: source);
      } else {
        picked = await picker.pickImage(source: source, imageQuality: 85);
      }

      if (picked != null && context.mounted) {
        return await showDialog<CapsuleMemory?>(
          context: context,
          builder: (ctx) => _PreviewAndCaptionDialog(
            file: File(picked!.path),
            isVideo: isVideo,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
    return null;
  }

  static Future<CapsuleMemory?> _openLetterEditor(BuildContext context) {
    return showDialog<CapsuleMemory?>(
      context: context,
      builder: (ctx) => const _LetterEditorDialog(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kPeach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _kBrown, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _kBrownDeep,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _kMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _kMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Preview and Caption Dialog for Photo/Video ───────────────────────────────

class _PreviewAndCaptionDialog extends StatefulWidget {
  const _PreviewAndCaptionDialog({required this.file, required this.isVideo});
  final File file;
  final bool isVideo;

  @override
  State<_PreviewAndCaptionDialog> createState() => _PreviewAndCaptionDialogState();
}

class _PreviewAndCaptionDialogState extends State<_PreviewAndCaptionDialog> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : (widget.isVideo ? 'Family Video' : 'Family Photo');
    final caption = _captionCtrl.text.trim();

    final memory = CapsuleMemory(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      type: widget.isVideo ? MemoryType.video : MemoryType.photo,
      content: widget.file.path,
      title: title,
      caption: caption,
      addedBy: 'You',
      createdAt: DateTime.now(),
      durationSeconds: widget.isVideo ? 45 : null,
    );
    Navigator.pop(context, memory);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFDF8F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isVideo ? 'Video Preview' : 'Photo Preview',
                  style: const TextStyle(
                    color: _kBrownDeep,
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: _kMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.isVideo
                  ? Container(
                      height: 200,
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 54),
                      ),
                    )
                  : Image.file(widget.file, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBrown, width: 1.5)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _captionCtrl,
              decoration: InputDecoration(
                labelText: 'Caption (Optional)',
                labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBrown, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Seal Memory into Capsule', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Letter Editor Dialog ──────────────────────────────────────────────────────

class _LetterEditorDialog extends StatefulWidget {
  const _LetterEditorDialog();

  @override
  State<_LetterEditorDialog> createState() => _LetterEditorDialogState();
}

class _LetterEditorDialogState extends State<_LetterEditorDialog> {
  final TextEditingController _titleCtrl = TextEditingController(text: 'A Letter for the Future');
  final TextEditingController _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your letter content')),
      );
      return;
    }

    final memory = CapsuleMemory(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      type: MemoryType.letter,
      content: _bodyCtrl.text.trim(),
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'A letter for you',
      caption: 'Words from the heart',
      addedBy: 'You',
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, memory);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFBF7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mail_outline_rounded, color: Color(0xFFC17B4F), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Write a Letter',
                      style: TextStyle(
                        color: _kBrownDeep,
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: _kMuted),
                ),
              ],
            ),
            const Divider(color: _kBorder, height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Letter Title',
                labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBrown, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Dear future self / family,\n\nWrite your thoughts, memories, recipes, or blessings here…',
                hintStyle: const TextStyle(color: _kMuted, fontSize: 13, height: 1.4),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBrown, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.lock_outline_rounded, size: 16),
                label: const Text('Seal Letter into Capsule', style: TextStyle(fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
