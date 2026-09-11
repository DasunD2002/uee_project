import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import 'widgets/explorer_footer.dart';

class FieldNoteEditorResult {
  const FieldNoteEditorResult({
    required this.site,
    required this.category,
    required this.text,
  });
  final String site, category, text;
}

class FieldNoteEditorScreen extends StatefulWidget {
  const FieldNoteEditorScreen({
    super.key,
    required this.province,
    required this.image,
    this.initialSite = '',
    this.initialCategory = 'Architectural',
    this.initialText = '',
    this.isEditing = false,
  });

  final String province, image, initialSite, initialCategory, initialText;
  final bool isEditing;

  @override
  State<FieldNoteEditorScreen> createState() => _FieldNoteEditorScreenState();
}

class _FieldNoteEditorScreenState extends State<FieldNoteEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController siteController;
  late final TextEditingController journalController;
  late String category;

  @override
  void initState() {
    super.initState();
    siteController = TextEditingController(text: widget.initialSite);
    journalController = TextEditingController(text: widget.initialText);
    category = widget.initialCategory;
  }

  @override
  void dispose() {
    siteController.dispose();
    journalController.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      FieldNoteEditorResult(
        site: siteController.text.trim(),
        category: category,
        text: journalController.text.trim(),
      ),
    );
  }

  void navigate(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFDFC),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA),
      foregroundColor: AppColors.brown,
      centerTitle: true,
      leading: const RootlyBackButton(fallbackRoute: '/explorer'),
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(Icons.notifications_none, size: 20),
        ),
      ],
    ),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 26),
        children: [
          Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBDD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.isEditing ? 'Edit Note' : 'Create Field Note',
              style: const TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.asset(
              widget.image,
              height: 205,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('SITE NAME'),
          TextFormField(
            controller: siteController,
            decoration: const InputDecoration(
              hintText: 'Enter heritage site',
              isDense: true,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a site name'
                : null,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('DATE'),
                    TextFormField(
                      initialValue: 'Oct 12, 2024',
                      readOnly: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        suffixIcon: Icon(
                          Icons.calendar_month_outlined,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('CATEGORY'),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(isDense: true),
                      items:
                          const [
                                'Architectural',
                                'Sacred Site',
                                'Rock Art',
                                'Natural Site',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => category = value ?? category),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _FieldLabel('TAGS'),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              for (final tag in [
                'Rock Carving ×',
                '${widget.province.replaceAll(' Province', '')} ×',
              ])
                Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 8)),
                  backgroundColor: const Color(0xFFFFDCC2),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                ),
              ActionChip(
                label: const Text('+ Add Tag', style: TextStyle(fontSize: 8)),
                visualDensity: VisualDensity.compact,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 17),
          const _FieldLabel('JOURNAL ENTRY'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF4),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE8D8CF)),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: journalController,
                  minLines: 10,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    hintText:
                        'Record your observations, details, and preservation notes...',
                    hintStyle: TextStyle(fontSize: 11),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(13),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Write a journal entry'
                      : null,
                ),
                Container(
                  height: 36,
                  color: const Color(0xFFF0ECEA),
                  child: const Row(
                    children: [
                      SizedBox(width: 9),
                      Icon(Icons.format_bold, size: 15),
                      SizedBox(width: 13),
                      Icon(Icons.format_italic, size: 15),
                      SizedBox(width: 13),
                      Icon(Icons.format_list_bulleted, size: 15),
                      SizedBox(width: 13),
                      Icon(Icons.location_on_outlined, size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brown,
                    minimumSize: const Size.fromHeight(44),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'Discard Changes',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brown,
                    minimumSize: const Size.fromHeight(44),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    widget.isEditing ? 'Save Entry' : 'Create Note',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    bottomNavigationBar: ExplorerFooter(selectedIndex: 1, onSelected: navigate),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w800,
        letterSpacing: .6,
      ),
    ),
  );
}
