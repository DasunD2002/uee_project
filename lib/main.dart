import 'dart:async';
import 'package:flutter/material.dart';
import 'features/explorer/presentation/explorer_shell.dart';

void main() => runApp(const RootlyApp());

const brown = Color(0xFF84321F);

class RootlyApp extends StatelessWidget {
  const RootlyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rootly',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(seedColor: brown, primary: brown),
    ),
    routes: {
      '/': (_) => const SplashScreen(),
      '/login': (_) => const LoginScreen(),
      '/signup': (_) => const SignUpScreen(),
      '/home': (_) => const HomeScreen(),
      '/explorer': (_) => const ExplorerShell(),
    },
  );
}

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
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 7,
          offset: Offset(2, 5),
        ),
      ],
    ),
    child: Image.asset(
      'assets/images/rootly_logo.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBFCAC7), Color(0xFF53675B), Color(0xFF7B665A)],
          ),
        ),
        child: const Center(
          child: FittedBox(
            child: Padding(
              padding: EdgeInsets.all(9),
              child: Text(
                'Rootly',
                style: TextStyle(
                  color: Color(0xFFFFF2B0),
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

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

  void openLogin() {
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFC4937D), Color(0xFFF8F4F2)],
            ),
          ),
          child: InkWell(
            onTap: openLogin,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 7),
                    const Center(child: RootlyLogo(size: 96)),
                    const Spacer(flex: 7),
                    const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF95513C),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    const Text(
                      'Explore Culture. Learn new things...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '2026 All Right Received',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'V.2.1.1',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF858585)),
      filled: true,
      fillColor: const Color(0xFFF3F1F1),
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(13, 12, 8, 9),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 34),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF999999)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: brown, width: 1.5),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 44,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: brown,
        shape: const StadiumBorder(),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    ),
  );
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 42,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFD9D9D9)),
        shape: const StadiumBorder(),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/google_icon.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 13),
          const Text('Sign in with Google'),
        ],
      ),
    ),
  );
}

void message(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final key = GlobalKey<FormState>(),
      email = TextEditingController(),
      password = TextEditingController();
  bool hidden = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            children: [
              SizedBox(
                height: box.maxHeight * .53,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/login_image.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF69B5B6),
                          Color(0xFFBEDAD0),
                          Color(0xFF405738),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.landscape,
                        size: 90,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -72),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                    ),
                  ),
                  child: Form(
                    key: key,
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Welcome Back...',
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 22),
                        AuthField(
                          label: 'Email',
                          hint: 'e.g:- john@gmail.com',
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            onPressed: email.clear,
                          ),
                          validator: (v) =>
                              v == null ||
                                  !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 13),
                        AuthField(
                          label: 'Password',
                          controller: password,
                          obscureText: hidden,
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 19,
                            ),
                            onPressed: () => setState(() => hidden = !hidden),
                          ),
                          validator: (v) => (v?.length ?? 0) < 6
                              ? 'Password must have at least 6 characters'
                              : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => message(
                              context,
                              'Password reset link requested.',
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Forget Password ?',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5574E8),
                              ),
                            ),
                          ),
                        ),
                        PrimaryButton(
                          text: 'Login',
                          onPressed: () {
                            if (key.currentState!.validate())
                              Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                        const SizedBox(height: 9),
                        GoogleButton(
                          onPressed: () =>
                              message(context, 'Google sign-in selected.'),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Still don't have account? ",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5574E8),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/signup',
                              ),
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF5574E8),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Explore'),
    (icon: Icons.map_outlined, label: 'Map'),
    (icon: Icons.forum_outlined, label: 'Questions'),
    (icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFFFCE8E8),
      foregroundColor: brown,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.menu, size: 20),
        tooltip: 'Menu',
      ),
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, size: 20),
          tooltip: 'Search',
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/explorer'),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFFFD8BD),
                    child: Icon(Icons.explore_outlined, color: brown),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore cultural places',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Discover suggestions, recent searches, and the map.',
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = selectedIndex == index;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFFD8BD)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 18, color: brown),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: brown,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final key = GlobalKey<FormState>(),
      name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  String? age;
  bool hidePassword = true, hideConfirm = true;
  @override
  void dispose() {
    for (final c in [name, email, phone, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(29, 18, 29, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 38),
            child: Form(
              key: key,
              child: Column(
                children: [
                  const RootlyLogo(size: 68),
                  const SizedBox(height: 14),
                  const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Explore Culture and Learn new things',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 28),
                  AuthField(
                    label: 'Name',
                    hint: 'e.g:- John alex',
                    controller: name,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      onPressed: name.clear,
                    ),
                    validator: (v) =>
                        (v?.trim().length ?? 0) < 2 ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: age,
                    isDense: true,
                    decoration: fieldDecoration('Age', 'e.g:- 23'),
                    items: List.generate(83, (i) => '${i + 18}')
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (v) => setState(() => age = v),
                  ),
                  const SizedBox(height: 8),
                  AuthField(
                    label: 'Email',
                    hint: 'e.g:- john@gmail.com',
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v == null || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  AuthField(
                    label: 'Phone Number',
                    hint: 'e.g:- 0XXXXXXXXX',
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => !RegExp(r'^0\d{9}$').hasMatch(v ?? '')
                        ? 'Enter a valid 10 digit phone number'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  AuthField(
                    label: 'Password',
                    controller: password,
                    obscureText: hidePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                      ),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                    validator: (v) => (v?.length ?? 0) < 6
                        ? 'Use at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  AuthField(
                    label: 'Confirm Password',
                    controller: confirm,
                    obscureText: hideConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                      ),
                      onPressed: () =>
                          setState(() => hideConfirm = !hideConfirm),
                    ),
                    validator: (v) =>
                        v != password.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    text: 'Create an account',
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        message(context, 'Account created successfully.');
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (mounted)
                            Navigator.pushReplacementNamed(context, '/login');
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  GoogleButton(
                    onPressed: () =>
                        message(context, 'Google sign-up selected.'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have account? ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5574E8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5574E8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

InputDecoration fieldDecoration(String label, String hint) => InputDecoration(
  labelText: label,
  hintText: hint,
  labelStyle: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF858585)),
  filled: true,
  fillColor: const Color(0xFFF3F1F1),
  isDense: true,
  contentPadding: const EdgeInsets.fromLTRB(13, 9, 8, 8),
  enabledBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF999999)),
  ),
  focusedBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: brown, width: 1.5),
  ),
);
