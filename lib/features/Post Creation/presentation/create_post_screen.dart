import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/community_app_bar.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../domain/user_post.dart';
import 'widgets/post_fields.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.post});
  final UserPost? post;
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title, story;
  final tag = TextEditingController();
  late List<String> tags;
  late List<PostMedia> proofs;
  PostMedia? cover;
  String? category, place, district, language;
  bool disableComments = false, isPrivate = false, picking = false;
  bool get editing => widget.post != null;

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    title = TextEditingController(text: post?.title);
    story = TextEditingController(text: post?.story);
    tags = [...?post?.tags];
    proofs = [...?post?.proofs];
    cover = post?.cover;
    category = post?.category;
    place = post?.place;
    district = post?.district;
    language = post?.language;
    disableComments = post?.disableComments ?? false;
    isPrivate = post?.isPrivate ?? false;
  }

  @override
  void dispose() {
    title.dispose();
    story.dispose();
    tag.dispose();
    super.dispose();
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> pickMedia({bool proof = false}) async {
    if (picking) return;
    setState(() => picking = true);
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Photos and videos',
            extensions: ['jpg', 'jpeg', 'png', 'mp4'],
            mimeTypes: ['image/jpeg', 'image/png', 'video/mp4'],
            uniformTypeIdentifiers: [
              'public.jpeg',
              'public.png',
              'public.mpeg-4',
            ],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 50 * 1024 * 1024) {
        if (mounted) message('Choose a file smaller than 50 MB.');
        return;
      }
      final media = PostMedia(name: file.name, bytes: await file.readAsBytes());
      if (!mounted) return;
      setState(() {
        if (proof) {
          proofs.add(media);
        } else {
          cover = media;
        }
      });
    } catch (_) {
      if (mounted) message('Could not open the file. Please try again.');
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  void addTag() {
    final values = tag.text
        .split(RegExp(r'[,\s]+'))
        .map((s) => s.replaceFirst(RegExp(r'^#'), '').trim())
        .where((s) => s.isNotEmpty);
    setState(() {
      tags = {...tags, ...values}.toList();
      tag.clear();
    });
  }

  void save({bool draft = false}) {
    if (!draft && !formKey.currentState!.validate()) return;
    if (!draft && cover == null && (widget.post?.asset.isEmpty ?? true)) {
      message('Add a cover photo or video.');
      return;
    }
    addTag();
    Navigator.pop(
      context,
      PostEditorResult(
        post: UserPost(
          id:
              widget.post?.id ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          title: title.text.trim(),
          story: story.text.trim(),
          category: category ?? '',
          place: place ?? '',
          district: district ?? '',
          language: language ?? '',
          tags: tags,
          cover: cover,
          proofs: proofs,
          asset: widget.post?.asset ?? '',
          disableComments: disableComments,
          isPrivate: isPrivate,
          isDraft: draft,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This post will be removed from your profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context, const PostEditorResult(deleted: true));
    }
  }

  Widget dropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> changed,
  ) => PostField(
    label,
    child: DropdownButtonFormField<String>(
      initialValue: value == '' ? null : value,
      isExpanded: true,
      decoration: postDecoration(),
      icon: const Icon(Icons.expand_more, color: AppColors.brown),
      items: options
          .map(
            (v) => DropdownMenuItem(
              value: v,
              child: Text(v, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      validator: (v) =>
          v == null || v.isEmpty ? 'Select ${label.toLowerCase()}' : null,
      onChanged: changed,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    drawer: const HomeDrawer(),
    appBar: const CommunityAppBar(),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Form(
            key: formKey,
            // Keep every field mounted so validation includes off-screen inputs.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(21, 12, 21, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      color: postFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        IconButton.filled(
                          tooltip: 'Back',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF925844),
                          ),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final navigator = Navigator.of(context);
                            if (navigator.canPop()) {
                              navigator.pop();
                            } else {
                              navigator.pushReplacementNamed('/profile');
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                editing ? 'Edit Post' : 'Create Post',
                                style: const TextStyle(
                                  color: AppColors.brown,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (editing)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    widget.post!.isDraft
                                        ? 'Draft'
                                        : 'Published · 2 hours ago       ◉ 256 Viewers',
                                    style: const TextStyle(
                                      color: AppColors.brown,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PostField(
                    'Cover photo or video',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        children: [
                          Container(
                            height: 188,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: postFill,
                              border: Border.all(
                                color: const Color(0xFFFFCEAB),
                              ),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: cover != null
                                ? (cover!.isVideo
                                      ? Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.video_file,
                                                size: 45,
                                              ),
                                              Text(cover!.name, maxLines: 2),
                                            ],
                                          ),
                                        )
                                      : Image.memory(
                                          cover!.bytes,
                                          fit: BoxFit.cover,
                                        ))
                                : editing && widget.post!.asset.isNotEmpty
                                ? Image.asset(
                                    widget.post!.asset,
                                    fit: BoxFit.cover,
                                  )
                                : InkWell(
                                    onTap: picking ? null : pickMedia,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(0xFFFFDABB),
                                          child: Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: AppColors.brown,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Add photo or video',
                                          style: TextStyle(
                                            color: AppColors.brown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'JPG, PNG or MP4 · up to 50 MB',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          if (cover != null || editing)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: FilledButton.tonal(
                                onPressed: picking ? null : pickMedia,
                                child: const Text('Replace'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PostField(
                    'Title',
                    child: TextFormField(
                      controller: title,
                      decoration: postDecoration('Give your story a title'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter a title'
                          : null,
                    ),
                  ),
                  PostField(
                    'Story',
                    child: TextFormField(
                      controller: story,
                      minLines: 6,
                      maxLines: 12,
                      decoration: postDecoration(
                        'Tell the story behind this place, craft or tradition...',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Tell your story'
                          : null,
                    ),
                  ),
                  dropdown('Category', category, [
                    'Heritage Site',
                    'Craft',
                    'Tradition',
                    'Nature',
                    'Festival',
                  ], (v) => setState(() => category = v)),
                  dropdown('Related place', place, [
                    'Sigiriya Rock Fortress',
                    'Ambalangoda',
                    'Kandy',
                    'Galle Fort',
                    'Other',
                  ], (v) => setState(() => place = v)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: dropdown('District', district, [
                          'Ampara',
                          'Anuradhapura',
                          'Badulla',
                          'Batticaloa',
                          'Colombo',
                          'Galle',
                          'Gampaha',
                          'Hambantota',
                          'Jaffna',
                          'Kalutara',
                          'Kandy',
                          'Kegalle',
                          'Kilinochchi',
                          'Kurunegala',
                          'Mannar',
                          'Matale',
                          'Matara',
                          'Monaragala',
                          'Mullaitivu',
                          'Nuwara Eliya',
                          'Polonnaruwa',
                          'Puttalam',
                          'Ratnapura',
                          'Trincomalee',
                          'Vavuniya',
                        ], (v) => setState(() => district = v)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: dropdown('Language', language, [
                          'English',
                          'Sinhala',
                          'Tamil',
                        ], (v) => setState(() => language = v)),
                      ),
                    ],
                  ),
                  PostField(
                    'Tags',
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: postFill,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        children: [
                          if (tags.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 6,
                                children: tags
                                    .map(
                                      (t) => Chip(
                                        label: Text('#$t'),
                                        backgroundColor: const Color(
                                          0xFFFFDABB,
                                        ),
                                        side: BorderSide.none,
                                        onDeleted: () =>
                                            setState(() => tags.remove(t)),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          TextField(
                            controller: tag,
                            onSubmitted: (_) => addTag(),
                            decoration: InputDecoration(
                              hintText: 'Add tags, e.g. temple',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                tooltip: 'Add tag',
                                onPressed: addTag,
                                icon: const Icon(Icons.add),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PostField(
                    'Add Proofs (Extra images videos)',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final proof in proofs)
                          InputChip(
                            label: SizedBox(
                              width: 110,
                              child: Text(
                                proof.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onDeleted: () =>
                                setState(() => proofs.remove(proof)),
                          ),
                        IconButton.filledTonal(
                          tooltip: 'Add proof',
                          onPressed: picking
                              ? null
                              : () => pickMedia(proof: true),
                          icon: const Icon(Icons.add, size: 30),
                        ),
                      ],
                    ),
                  ),
                  PostField(
                    'Comments',
                    child: Row(
                      children: [
                        const Expanded(child: Text('Disable Comments')),
                        Switch(
                          value: disableComments,
                          activeThumbColor: AppColors.brown,
                          onChanged: (v) => setState(() => disableComments = v),
                        ),
                      ],
                    ),
                  ),
                  PostField(
                    'Visibility',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('Public'),
                              icon: Icon(Icons.public),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('Private'),
                              icon: Icon(Icons.lock_outline),
                            ),
                          ],
                          selected: {isPrivate},
                          onSelectionChanged: (v) =>
                              setState(() => isPrivate = v.first),
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            backgroundColor: postFill,
                            selectedBackgroundColor: AppColors.brown,
                            selectedForegroundColor: Colors.white,
                            foregroundColor: AppColors.brown,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPrivate
                              ? 'Only you can see this story.'
                              : 'Anyone on Rootly can find and save this story.',
                          style: const TextStyle(
                            color: Color(0xFF95857F),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PostAction(
                    editing ? 'Save Changes' : 'Create Post',
                    onPressed: save,
                  ),
                  const SizedBox(height: 16),
                  PostAction(
                    editing ? 'Delete Post' : 'Save as Draft',
                    outlined: true,
                    onPressed: editing ? delete : () => save(draft: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
