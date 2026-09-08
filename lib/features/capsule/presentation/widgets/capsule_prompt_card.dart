import 'package:flutter/material.dart';

class CapsulePromptCard extends StatelessWidget {
  const CapsulePromptCard({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFFE7E1DF)),
      boxShadow: const [
        BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 162,
          width: double.infinity,
          child: Image.asset(
            'assets/images/login_image.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start Your Legacy Today.',
                style: TextStyle(
                  color: Color(0xFF39241D),
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 11),
              const Text(
                'Create a digital capsule of stories, recipes,\nand wishes. Seal it for a future date, place,\nor\nperson.',
                style: TextStyle(
                  color: Color(0xFF675B56),
                  fontSize: 14,
                  height: 1.42,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 37,
                child: ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Create Your First Capsule',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF4B2519),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
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
