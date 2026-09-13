import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Colour tokens local to this screen
// ---------------------------------------------------------------------------
const _kBg         = Color(0xFFFDF8F5);
const _kCard       = Color(0xFFFFFFFF);
const _kBrown      = Color(0xFF4A2E2B);
const _kBrownLight = Color(0xFF7A5147);
const _kRose       = Color(0xFFE8B4A8);
const _kRoseMid    = Color(0xFFF5DDD8);
const _kMuted      = Color(0xFFB09590);
const _kBorder     = Color(0xFFEEE0DB);
const _kDelete     = Color(0xFFC0574A);

/// Screen for editing an existing time capsule.
///
/// Placed at: lib/features/capsule/presentation/edit_capsule_screen.dart
class EditCapsuleScreen extends StatefulWidget {
  const EditCapsuleScreen({super.key});

  @override
  State<EditCapsuleScreen> createState() => _EditCapsuleScreenState();
}

class _EditCapsuleScreenState extends State<EditCapsuleScreen> {
  final _titleCtrl       = TextEditingController(text: "Grandson's 18th Birthday");
  final _descCtrl        = TextEditingController();
  final _unlockDateCtrl  = TextEditingController(text: 'June 10, 2027');
  String  _category      = 'Family';
  bool    _allowContribs = true;

  static const _categories = ['Personal', 'Family', 'Community'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _unlockDateCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ──────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2027, 6, 10),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kBrown,
            onPrimary: Colors.white,
            surface: _kBg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final months = [
        'January','February','March','April','May','June',
        'July','August','September','October','November','December',
      ];
      setState(() {
        _unlockDateCtrl.text = '${months[picked.month - 1]} ${picked.day}, ${picked.year}';
      });
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Capsule updated successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ── Delete confirmation ──────────────────────────────────────────────────
  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteSheet(
        onDelete: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // go back
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            _SectionLabel('Capsule Info'),
            const SizedBox(height: 10),
            _FieldCard(children: [
              _InputField(
                label: 'Capsule Title',
                controller: _titleCtrl,
                icon: Icons.edit_note_rounded,
              ),
              _Divider(),
              _InputField(
                label: 'Description / Note',
                controller: _descCtrl,
                icon: Icons.notes_rounded,
                minLines: 3,
                maxLines: 5,
                hint: 'Add a personal note about this capsule…',
              ),
            ]),

            const SizedBox(height: 20),
            _SectionLabel('Unlock Date'),
            const SizedBox(height: 10),
            _FieldCard(children: [
              _DateField(
                controller: _unlockDateCtrl,
                onTap: _pickDate,
              ),
            ]),

            const SizedBox(height: 20),
            _SectionLabel('Category'),
            const SizedBox(height: 10),
            _CategoryPills(
              categories: _categories,
              selected: _category,
              onSelected: (v) => setState(() => _category = v),
            ),

            const SizedBox(height: 20),
            _SectionLabel('Cover Photo'),
            const SizedBox(height: 10),
            const _CoverPhotoSection(),

            const SizedBox(height: 20),
            _SectionLabel('Privacy & Permissions'),
            const SizedBox(height: 10),
            _FieldCard(children: [
              _ToggleRow(
                icon: Icons.group_add_outlined,
                label: 'Allow members to add contributions',
                value: _allowContribs,
                onChanged: (v) => setState(() => _allowContribs = v),
              ),
            ]),

            const SizedBox(height: 32),
            _SaveButton(onPressed: _save),
            const SizedBox(height: 16),
            _DeleteLink(onPressed: _confirmDelete),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: _kCard,
    foregroundColor: _kBrown,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    toolbarHeight: 60,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
      tooltip: 'Back',
      onPressed: () => Navigator.maybePop(context),
    ),
    title: const Text(
      'Edit Capsule',
      style: TextStyle(
        color: _kBrown,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -.2,
      ),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: _kBorder),
    ),
  );
}

// ============================================================================
// Reusable sub-widgets
// ============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: _kMuted,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    ),
  );
}

// ── Card wrapper ─────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kBorder),
      boxShadow: const [
        BoxShadow(color: Color(0x0A3B1F14), blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: _kBorder, indent: 16, endIndent: 16);
}

// ── Text input ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _kMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: _kMuted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(color: _kBrown, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kRose, fontSize: 13),
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
          ),
          cursorColor: _kBrown,
        ),
      ],
    ),
  );
}

// ── Date field ───────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({required this.controller, required this.onTap});
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _kRoseMid,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.lock_clock_rounded, color: AppColors.brown, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unlock Date', style: TextStyle(color: _kMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, val, __) => Text(
                    val.text.isEmpty ? 'Select a date' : val.text,
                    style: TextStyle(
                      color: val.text.isEmpty ? _kRose : _kBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

// ── Category pills ───────────────────────────────────────────────────────────

class _CategoryPills extends StatelessWidget {
  const _CategoryPills({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: categories.map((cat) {
      final isSelected = cat == selected;
      return GestureDetector(
        onTap: () => onSelected(cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _kBrown : _kCard,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? _kBrown : _kBorder, width: isSelected ? 0 : 1),
            boxShadow: isSelected
                ? [const BoxShadow(color: Color(0x224A2E2B), blurRadius: 8, offset: Offset(0, 3))]
                : [],
          ),
          child: Text(
            cat,
            style: TextStyle(
              color: isSelected ? Colors.white : _kBrownLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// ── Cover photo section ──────────────────────────────────────────────────────

class _CoverPhotoSection extends StatelessWidget {
  const _CoverPhotoSection();

  @override
  Widget build(BuildContext context) => Container(
    height: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Color(0x143B1F14), blurRadius: 14, offset: Offset(0, 5)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          Image.asset('assets/images/login_image.jpg', fit: BoxFit.cover),
          // Dark scrim
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(140),
                ],
                stops: const [.45, 1],
              ),
            ),
          ),
          // Change button
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 15, color: _kBrown),
                      SizedBox(width: 6),
                      Text(
                        'Change Cover Photo',
                        style: TextStyle(color: _kBrown, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Toggle row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _kRoseMid,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.brown, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: _kBrown, fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.brown,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: _kBorder,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ],
    ),
  );
}

// ── Save button ──────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _kBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, size: 18),
          SizedBox(width: 8),
          Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

// ── Delete link ──────────────────────────────────────────────────────────────

class _DeleteLink extends StatelessWidget {
  const _DeleteLink({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: _kDelete),
      child: const Text(
        'Delete Capsule',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
      ),
    ),
  );
}

// ── Delete confirmation sheet ─────────────────────────────────────────────────

class _DeleteSheet extends StatelessWidget {
  const _DeleteSheet({required this.onDelete});
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
    decoration: BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFCECEA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_forever_rounded, color: _kDelete, size: 26),
        ),
        const SizedBox(height: 16),
        const Text(
          'Delete Capsule?',
          style: TextStyle(color: _kBrown, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'This will permanently remove the capsule and all its memories. This action cannot be undone.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _kMuted, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBrown,
                  side: const BorderSide(color: _kBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onDelete,
                style: FilledButton.styleFrom(
                  backgroundColor: _kDelete,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
