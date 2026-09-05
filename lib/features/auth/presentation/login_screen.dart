import 'package:flutter/material.dart';
import '../../../core/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final key = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: LayoutBuilder(builder: (context, box) => SingleChildScrollView(
      child: ConstrainedBox(constraints: BoxConstraints(minHeight: box.maxHeight), child: Column(children: [
        SizedBox(height: box.maxHeight * .53, width: double.infinity, child: Image.asset('assets/images/login_image.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF69B5B6), Color(0xFFBEDAD0), Color(0xFF405738)])), child: Center(child: Icon(Icons.landscape, size: 90, color: Colors.white70))))),
        Transform.translate(offset: const Offset(0, -72), child: Container(
          width: double.infinity, padding: const EdgeInsets.fromLTRB(30, 20, 30, 22),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(70))),
          child: Form(key: key, child: Column(children: [
            const Text('Login', style: TextStyle(fontSize: 31, fontWeight: FontWeight.bold)), const SizedBox(height: 3),
            const Text('Welcome Back...', style: TextStyle(fontSize: 17)), const SizedBox(height: 22),
            AuthField(label: 'Email', hint: 'e.g:- john@gmail.com', controller: email, keyboardType: TextInputType.emailAddress, suffixIcon: IconButton(icon: const Icon(Icons.cancel_outlined, size: 18), onPressed: email.clear), validator: (v) => v == null || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? 'Enter a valid email' : null),
            const SizedBox(height: 13),
            AuthField(label: 'Password', controller: password, obscureText: hidden, suffixIcon: IconButton(icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19), onPressed: () => setState(() => hidden = !hidden)), validator: (v) => (v?.length ?? 0) < 6 ? 'Password must have at least 6 characters' : null),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => showMessage(context, 'Password reset link requested.'), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: Size.zero), child: const Text('Forget Password ?', style: TextStyle(fontSize: 11, color: Color(0xFF5574E8))))),
            PrimaryButton(text: 'Login', onPressed: () { if (key.currentState!.validate()) Navigator.pushReplacementNamed(context, '/home'); }),
            const SizedBox(height: 9), GoogleButton(onPressed: () => showMessage(context, 'Google sign-in selected.')), const SizedBox(height: 9),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Still don't have account? ", style: TextStyle(fontSize: 11, color: Color(0xFF5574E8))), GestureDetector(onTap: () => Navigator.pushReplacementNamed(context, '/signup'), child: const Text('Sign up', style: TextStyle(fontSize: 11, color: Color(0xFF5574E8), decoration: TextDecoration.underline)))]),
          ])),
        )),
      ])),
    )),
  );
}
