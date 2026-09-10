import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';

/// The contents of Kumari's family-recipe time capsule.
class FamilyReceiptScreen extends StatelessWidget {
  const FamilyReceiptScreen({super.key});

  void _onNavSelected(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    } else if (index == 3) {
      Navigator.pushNamedAndRemoveUntil(context, '/capsules', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8EF),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFF8EF),
      foregroundColor: AppColors.brown,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Back to capsules',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
      ),
      title: const Text('Your capsule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      centerTitle: true,
    ),
    body: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 10, 28, 28),
        child: Column(
          children: [
            const Text(
              'Sinhala New Year 2024',
              style: TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _MemoryCard(
                      alignment: const Alignment(-.72, -.72),
                      angle: -.04,
                      image: 'assets/images/login_image.jpg',
                      caption: 'Aachchi te ka',
                    ),
                    _MemoryCard(
                      alignment: const Alignment(.72, -.58),
                      angle: .08,
                      image: 'assets/images/gal_vihara.png',
                      caption: 'The family table',
                    ),
                    _MemoryCard(
                      alignment: const Alignment(-.62, .62),
                      angle: .03,
                      image: 'assets/images/mask_carver.png',
                      caption: 'Her blessing',
                    ),
                    _LetterCard(),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x24000000), blurRadius: 12)]),
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.brown, size: 31),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 47,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                child: const Text('View Your Memories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: ExplorerFooter(selectedIndex: 3, onSelected: (index) => _onNavSelected(context, index)),
  );
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.alignment, required this.angle, required this.image, required this.caption});
  final Alignment alignment;
  final double angle;
  final String image;
  final String caption;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Transform.rotate(
      angle: angle,
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), boxShadow: const [BoxShadow(color: Color(0x1A4D3022), blurRadius: 9, offset: Offset(0, 4))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.asset(image, height: 94, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 7),
          Text(caption, style: const TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 10, fontStyle: FontStyle.italic)),
        ]),
      ),
    ),
  );
}

class _LetterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
    alignment: const Alignment(.63, .64),
    child: Container(
      width: 106,
      height: 115,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), boxShadow: const [BoxShadow(color: Color(0x1A4D3022), blurRadius: 9, offset: Offset(0, 4))]),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.mail_outline_rounded, color: Color(0xFFC17B4F), size: 30),
        SizedBox(height: 20),
        Text('A letter for you', style: TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 10)),
      ]),
    ),
  );
}
