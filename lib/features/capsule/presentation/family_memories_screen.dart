import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The individual memories stored in the Family Recipe capsule.
class FamilyMemoriesScreen extends StatelessWidget {
  const FamilyMemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFECEE),
      foregroundColor: AppColors.brown,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 76,
      leading: const Icon(Icons.menu_rounded),
      centerTitle: true,
      title: const Text(
        'Rootly',
        style: TextStyle(
          color: AppColors.brown,
          fontFamily: 'serif',
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, size: 23),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _RoundBackButton(onPressed: () => Navigator.pop(context)),
                const SizedBox(width: 11),
                const Expanded(
                  child: Text(
                    'Opened: Family Recipe',
                    style: TextStyle(color: AppColors.brown, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Divider(color: Color(0xFFEEDFD9), height: 1),
            const SizedBox(height: 26),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                '4 memories from 3 contributors, sealed for one year. Tap any memory to open it.',
                style: TextStyle(color: Color(0xFFB77B6C), fontSize: 12, height: 1.3),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MemoryTile(
                    image: 'assets/images/login_image.jpg',
                    title: 'The whole family at\nthe Avurudu table',
                    author: 'Uncle Sarath',
                    likes: '12',
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: _MemoryTile(
                    icon: Icons.mic_none_rounded,
                    title: 'Blessings for the\nnew year',
                    author: 'Grandma Kumari',
                    likes: '24',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MemoryTile(
                    image: 'assets/images/mask_carver.png',
                    title: 'Aachchi and Nangi,\non the veranda',
                    author: 'You',
                    likes: '31',
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: _MemoryTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'A letter to open\nwhen you turn 18',
                    author: 'Grandma Kumari',
                    likes: '18',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 29),
            const Divider(color: Color(0xFFEEDFD9), height: 1),
            const SizedBox(height: 19),
            SizedBox(
              height: 41,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/response-capsule'),
                icon: const Icon(Icons.hub_outlined, size: 17),
                label: const Text('Create a Response Capsule', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD6B6),
                  foregroundColor: AppColors.brown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 29,
    height: 29,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.brown,
        side: const BorderSide(color: Color(0xFFE9D9D3)),
        shape: const CircleBorder(),
      ),
      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 13),
    ),
  );
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({this.image, this.icon, required this.title, required this.author, required this.likes});

  final String? image;
  final IconData? icon;
  final String title;
  final String author;
  final String likes;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFF0E1DB)),
      boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 7, offset: Offset(0, 3))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 88,
          width: double.infinity,
          child: image != null
              ? Image.asset(image!, fit: BoxFit.cover)
              : Center(child: Icon(icon, size: 29, color: AppColors.brown)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 12, fontWeight: FontWeight.w700, height: 1.08)),
              const SizedBox(height: 5),
              Text(author, style: const TextStyle(color: Color(0xFFC2978D), fontSize: 9)),
              const SizedBox(height: 7),
              Row(children: [const Icon(Icons.favorite_border_rounded, color: AppColors.brown, size: 14), const SizedBox(width: 4), Text(likes, style: const TextStyle(color: AppColors.brown, fontSize: 10))]),
            ],
          ),
        ),
      ],
    ),
  );
}
