import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/explorer_footer.dart';
import 'journey_planner_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, this.title = 'Gal Vihara', this.imagePath = 'assets/images/gal_vihara.png'});
  final String title, imagePath;
  @override State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override Widget build(BuildContext context) => Scaffold(
    key: scaffoldKey, drawer: const HomeDrawer(), backgroundColor: const Color(0xFFF8F6F4),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA), foregroundColor: AppColors.brown, centerTitle: true,
      leading: IconButton(onPressed: () => scaffoldKey.currentState?.openDrawer(), icon: const Icon(Icons.menu, size: 20)),
      title: const Text('Rootly', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 24)),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 20))],
    ),
    body: ListView(children: [
      Stack(alignment: Alignment.bottomLeft, children: [
        SizedBox(height: 230, width: double.infinity, child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC000000)])))),
        Positioned(left: 15, right: 15, bottom: 15, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: const TextStyle(color: Colors.white, fontFamily: 'serif', fontSize: 29, fontWeight: FontWeight.bold)),
          const Text('The silent witnesses of a kingdom', style: TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 5), const Text('● Polonnaruwa, Sri Lanka  ·  Classical Era', style: TextStyle(color: Colors.white70, fontSize: 9)),
        ])),
      ]),
      Padding(padding: const EdgeInsets.all(12), child: Column(children: [
        _ContentCard(title: 'Historical Narrative', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Carved directly into the granite during the Polonnaruwa era, Gal Vihara is one of Sri Lanka’s most remarkable collections of ancient Buddhist sculpture. The four serene figures reveal the extraordinary skill and spiritual devotion of their creators.', style: _bodyStyle),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset('assets/images/gal_vihara.png', height: 150, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 5), const Text('Detail of the reclining Buddha and surrounding rock carvings.', style: TextStyle(fontSize: 8, color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12), const Text('The standing figure and reclining Buddha continue to inspire visitors with their calm expressions, balanced proportions, and the remarkable preservation of their hand-carved details.', style: _bodyStyle),
        ])),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JourneyPlannerScreen(
                  selectedTitle: widget.title,
                  selectedImagePath: widget.imagePath,
                ),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('Add to Journey'),
          ),
        ),
        const SizedBox(height: 12),
        const _ContentCard(title: 'Visitor Essentials', child: Column(children: [
          _InfoRow(icon: Icons.schedule, title: 'Hours', value: '6:00 AM – 6:00 PM Daily'),
          _InfoRow(icon: Icons.confirmation_number_outlined, title: 'Tickets', value: 'Included in Polonnaruwa Ancient City pass'),
          _InfoRow(icon: Icons.accessibility_new, title: 'Accessibility', value: 'Flat sandy paths; mostly wheelchair accessible'),
        ])),
      ])),
    ]),
    bottomNavigationBar: ExplorerFooter(selectedIndex: 1, onSelected: (index) {
      if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      if (index == 1) Navigator.pop(context);
      if (index == 3) Navigator.pushNamed(context, '/province-map');
    }),
  );
}

const _bodyStyle = TextStyle(fontSize: 11, height: 1.55, color: Color(0xFF534B47));

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.child}); final String title; final Widget child;
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE8E0DC))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 17, fontWeight: FontWeight.bold)), const Divider(), child]));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value}); final IconData icon; final String title, value;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 18, color: AppColors.brown), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]))]));
}
