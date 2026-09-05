import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.category, required this.imagePath, required this.title, required this.location, required this.description, required this.likes, required this.comments});
  final String category, imagePath, title, location, description, likes, comments;
  @override Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero, elevation: 1.5, color: Colors.white, clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        AspectRatio(aspectRatio: 1.95, child: Image.asset(imagePath, fit: BoxFit.cover)),
        Positioned(top: 8, left: 8, child: DecoratedBox(decoration: BoxDecoration(color: const Color(0xFFFFE3CA), borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), child: Text(category, style: const TextStyle(color: AppColors.brown, fontSize: 9, fontWeight: FontWeight.w600))))),
        Positioned(top: 8, right: 8, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.more_horiz, size: 20))),
      ]),
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2)), const SizedBox(height: 6),
        Row(children: [const Icon(Icons.location_on_outlined, size: 13, color: AppColors.brown), const SizedBox(width: 3), Text(location, style: const TextStyle(fontSize: 10, color: Colors.grey)), const Text(' · 6 hours ago', style: TextStyle(fontSize: 10, color: Colors.grey))]),
        const SizedBox(height: 8), Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xFF5F5A57), height: 1.4)), const Divider(height: 18),
        Row(children: [const Icon(Icons.favorite_border, size: 17, color: AppColors.brown), const SizedBox(width: 4), Text(likes, style: const TextStyle(fontSize: 10)), const SizedBox(width: 14), const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.brown), const SizedBox(width: 4), Text(comments, style: const TextStyle(fontSize: 10)), const Spacer(), const Text('Amaya', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)), const SizedBox(width: 6), const CircleAvatar(radius: 10, backgroundColor: Color(0xFFE9B99A), child: Icon(Icons.person, size: 14, color: AppColors.brown)), const SizedBox(width: 12), const Icon(Icons.bookmark_border, size: 18), const SizedBox(width: 13), const Icon(Icons.ios_share, size: 17)]),
      ])),
    ]),
  );
}
