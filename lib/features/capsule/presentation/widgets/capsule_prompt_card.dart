import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CapsulePromptCard extends StatelessWidget {
  const CapsulePromptCard({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(color: Color(0x241D0A04), blurRadius: 24, offset: Offset(0, 12)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 182,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/login_image.jpg', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x8C35140B)],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xEFFFFFFB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.brown),
                      SizedBox(width: 5),
                      Text('MEMORY VAULT', style: TextStyle(color: AppColors.brown, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .6)),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 17,
                bottom: 15,
                child: Text(
                  'Save what matters\nfor later.',
                  style: TextStyle(color: Colors.white, fontSize: 25, height: .95, fontWeight: FontWeight.w800, letterSpacing: -.5),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('A little time capsule for a big life.', style: TextStyle(color: Color(0xFF39241D), fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              const Text('Gather your stories, recipes and wishes. Choose\nwhen they should be opened again.', style: TextStyle(color: Color(0xFF675B56), fontSize: 11, height: 1.4)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Create Your First Capsule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
