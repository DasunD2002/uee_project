import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/rootly_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 3), openLogin);
  }
  void openLogin() { if (mounted) Navigator.pushReplacementNamed(context, '/login'); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFC4937D), Color(0xFFF8F4F2)])),
          child: InkWell(
            onTap: openLogin,
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 34, vertical: 22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Spacer(flex: 7), Center(child: RootlyLogo(size: 96)), Spacer(flex: 7),
                  Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF95513C)))),
                  Spacer(flex: 2), Text('Explore Culture. Learn new things...', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12), Text('2026 All Right Received', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                  SizedBox(height: 5), Text('V.2.1.1', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                ]),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
