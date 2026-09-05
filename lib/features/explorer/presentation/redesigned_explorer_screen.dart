import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'place_detail_screen.dart';

class RedesignedExplorerScreen extends StatelessWidget {
  const RedesignedExplorerScreen({super.key, required this.onOpenDrawer});
  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true, backgroundColor: const Color(0xFFFFEAEA), foregroundColor: AppColors.brown, centerTitle: true,
        leading: IconButton(onPressed: onOpenDrawer, icon: const Icon(Icons.menu, size: 20)),
        title: const Text('Rootly', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 20))],
      ),
      SliverPadding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 20), sliver: SliverList(delegate: SliverChildListDelegate.fixed([
        const _ExplorerSearch(), const SizedBox(height: 10), const _CategoryRow(), const SizedBox(height: 18),
        const Text('Recommended for You', style: TextStyle(color: AppColors.brown, fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 10),
        _PlaceCard(image: 'assets/images/gal_vihara.png', category: 'Classical Era', title: 'Gal Vihara', location: 'Polonnaruwa', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceDetailScreen()))),
        const SizedBox(height: 12),
        _PlaceCard(image: 'assets/images/login_image.jpg', category: 'Heritage Site', title: 'Sigiriya Rock Fortress', location: 'Matale', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceDetailScreen(title: 'Sigiriya Rock Fortress', imagePath: 'assets/images/login_image.jpg')))),
      ]))),
    ]),
  );
}

class _ExplorerSearch extends StatelessWidget {
  const _ExplorerSearch();
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: SizedBox(height: 36, child: TextField(decoration: InputDecoration(hintText: 'Search...', hintStyle: const TextStyle(fontSize: 11), prefixIcon: const Icon(Icons.search, size: 17), filled: true, fillColor: const Color(0xFFF0EEEE), contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none))))),
    const SizedBox(width: 7), Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE8E1DE))), child: const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.brown)),
  ]);
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();
  @override Widget build(BuildContext context) => SizedBox(height: 30, child: ListView(scrollDirection: Axis.horizontal, children: ['All Era', 'Ancient Ruins', 'Sacred Sites', 'Craft'].map((label) => Padding(padding: const EdgeInsets.only(right: 7), child: ActionChip(label: Text(label, style: const TextStyle(fontSize: 9)), padding: const EdgeInsets.symmetric(horizontal: 4), visualDensity: VisualDensity.compact, onPressed: () {}))).toList()));
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.image, required this.category, required this.title, required this.location, required this.onTap});
  final String image, category, title, location;
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => AspectRatio(aspectRatio: .88, child: Card(
    margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    child: InkWell(onTap: onTap, child: Stack(fit: StackFit.expand, children: [
      Image.asset(image, fit: BoxFit.cover),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xD9000000)], stops: [.48, 1]))),
      Positioned(left: 12, right: 12, bottom: 13, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DecoratedBox(decoration: BoxDecoration(color: const Color(0xFFFFE1C8), borderRadius: BorderRadius.circular(11)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text(category, style: const TextStyle(color: AppColors.brown, fontSize: 9)))), const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 23)),
        Text('● $location', style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ])),
    ])),
  ));
}
