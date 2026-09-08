import 'package:flutter/material.dart';

class CapsuleTile extends StatelessWidget {
  const CapsuleTile({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [
        BoxShadow(color: Color(0x0D000000), blurRadius: 7, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.asset(
            'assets/images/login_image.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Family Recipes',
                style: TextStyle(
                  color: Color(0xFF493027),
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Sealed on April 12, 2024',
                style: TextStyle(color: Color(0xFF6F6560), fontSize: 8),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          color: const Color(0xFFFFF0EC),
          child: const Text(
            '2 YEARS LEFT',
            style: TextStyle(
              color: Color(0xFF634941),
              fontFamily: 'serif',
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
