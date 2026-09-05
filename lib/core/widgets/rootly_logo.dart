import 'package:flutter/material.dart';

class RootlyLogo extends StatelessWidget {
  const RootlyLogo({super.key, this.size = 78});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * .2),
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 7, offset: Offset(2, 5))],
    ),
    child: Image.asset(
      'assets/images/rootly_logo.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFBFCAC7), Color(0xFF53675B), Color(0xFF7B665A)]),
        ),
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: EdgeInsets.all(9),
              child: Text('Rootly', style: TextStyle(color: Color(0xFFFFF2B0), fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 24)),
            ),
          ),
        ),
      ),
    ),
  );
}
