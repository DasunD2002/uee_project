import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/capsules/presentation/create_capsule_screen.dart';
import 'features/capsule/presentation/capsule_screen.dart';
import 'features/capsule/presentation/family_receipt_screen.dart';
import 'features/explorer/presentation/explorer_shell.dart';
import 'features/explorer/presentation/sri_lanka_3d_map_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() => runApp(const RootlyApp());

class RootlyApp extends StatelessWidget {
  const RootlyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rootly',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brown,
        primary: AppColors.brown,
      ),
    ),
    routes: {
      '/': (_) => const SplashScreen(),
      '/login': (_) => const LoginScreen(),
      '/signup': (_) => const SignUpScreen(),
      '/create-capsule': (_) => const CreateCapsuleScreen(),
      '/capsules': (_) => const CapsuleScreen(),
      '/home': (_) => const HomeScreen(),
      '/capsule': (_) => const CapsuleScreen(),
      '/family-receipt': (_) => const FamilyReceiptScreen(),
      '/explorer': (_) => const ExplorerShell(),
      '/province-map': (_) => const SriLanka3DMapScreen(),
    },
  );
}
