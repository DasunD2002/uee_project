import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/auth/presentation/change_password_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/capsules/presentation/create_capsule_screen.dart';
import 'features/capsule/presentation/capsule_screen.dart';
import 'features/capsule/presentation/family_receipt_screen.dart';
import 'features/capsule/presentation/family_memories_screen.dart';
import 'features/explorer/presentation/explorer_shell.dart';
import 'features/explorer/presentation/sri_lanka_3d_map_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/Profile/presentation/profile_screen.dart';
import 'features/questions/domain/question.dart';
import 'features/questions/presentation/ask_question_screen.dart';
import 'features/questions/presentation/question_detail_screen.dart';
import 'features/questions/presentation/questions_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/translations/presentation/translation_screen.dart';
import 'features/quizzes/presentation/daily_quiz_screen.dart';
import 'features/quizzes/presentation/quiz_home_screen.dart';

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
      '/otp': (context) => OtpScreen(
        email: ModalRoute.of(context)?.settings.arguments as String? ?? '',
      ),
      '/forgot-password': (_) => const ChangePasswordScreen(isReset: true),
      '/change-password': (_) => const ChangePasswordScreen(),
      '/settings': (_) => const SettingsScreen(),
      '/create-capsule': (_) => const CreateCapsuleScreen(),
      '/capsules': (_) => const CapsuleScreen(),
      '/home': (_) => const HomeScreen(),
      '/profile': (_) => const ProfileScreen(),
      '/saved-posts': (_) => const ProfileScreen(showSavedPosts: true),
      '/capsule': (_) => const CapsuleScreen(),
      '/family-receipt': (_) => const FamilyReceiptScreen(),
      '/family-memories': (_) => const FamilyMemoriesScreen(),
      '/explorer': (_) => const ExplorerShell(),
      '/province-map': (_) => const SriLanka3DMapScreen(),
      '/questions': (_) => const QuestionsScreen(),
      '/question-detail': (context) => QuestionDetailScreen(
        question:
            ModalRoute.of(context)?.settings.arguments as Question? ??
            sampleQuestions.first,
      ),
      '/ask-question': (_) => const AskQuestionScreen(),
      '/notifications': (_) => const NotificationsScreen(),
      '/notification': (_) => const NotificationsScreen(),
      '/translations': (_) => const TranslationScreen(),
      '/quizzes': (_) => const QuizHomeScreen(),
      '/daily-quiz': (_) => const DailyQuizScreen(),
    },
  );
}
