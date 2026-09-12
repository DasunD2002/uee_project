import 'package:flutter/material.dart';

class CapsuleTile extends StatelessWidget {
  const CapsuleTile({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Open Family Receipt capsule',
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(context, '/family-receipt'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Color(0x121E100A), blurRadius: 14, offset: Offset(0, 6)),
      ],
    ),
          child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/login_image.jpg',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Family recipes',
                style: TextStyle(
                  color: Color(0xFF493027),
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Locked until April 12, 2026',
                style: TextStyle(color: Color(0xFF6F6560), fontSize: 10),
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: Color(0xFFFFE3D3), shape: BoxShape.circle),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF84321F),
            size: 17,
          ),
        ),
      ],
          ),
        ),
      ),
    ),
  );
}
