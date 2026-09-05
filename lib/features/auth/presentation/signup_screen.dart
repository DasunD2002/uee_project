import 'package:flutter/material.dart';
import '../../../core/widgets/auth_widgets.dart';
import '../../../core/widgets/rootly_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), phone = TextEditingController(), password = TextEditingController(), confirm = TextEditingController();
  String? age;
  bool hidePassword = true, hideConfirm = true;
  @override
  void dispose() { for (final c in [name, email, phone, password, confirm]) { c.dispose(); } super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: LayoutBuilder(builder: (context, box) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(29, 18, 29, 20),
    child: ConstrainedBox(constraints: BoxConstraints(minHeight: box.maxHeight - 38), child: Form(key: key, child: Column(children: [
      const RootlyLogo(size: 68), const SizedBox(height: 14),
      const Text('Sign Up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 2),
      const Text('Explore Culture and Learn new things', style: TextStyle(fontSize: 12)), const SizedBox(height: 28),
      AuthField(label: 'Name', hint: 'e.g:- John alex', controller: name, suffixIcon: IconButton(icon: const Icon(Icons.cancel_outlined, size: 18), onPressed: name.clear), validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Enter your name' : null), const SizedBox(height: 8),
      DropdownButtonFormField<String>(initialValue: age, isDense: true, decoration: fieldDecoration('Age', 'e.g:- 23'), items: List.generate(83, (i) => '${i + 18}').map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => age = v)), const SizedBox(height: 8),
      AuthField(label: 'Email', hint: 'e.g:- john@gmail.com', controller: email, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? 'Enter a valid email' : null), const SizedBox(height: 8),
      AuthField(label: 'Phone Number', hint: 'e.g:- 0XXXXXXXXX', controller: phone, keyboardType: TextInputType.phone, validator: (v) => !RegExp(r'^0\d{9}$').hasMatch(v ?? '') ? 'Enter a valid 10 digit phone number' : null), const SizedBox(height: 8),
      AuthField(label: 'Password', controller: password, obscureText: hidePassword, suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19), onPressed: () => setState(() => hidePassword = !hidePassword)), validator: (v) => (v?.length ?? 0) < 6 ? 'Use at least 6 characters' : null), const SizedBox(height: 8),
      AuthField(label: 'Confirm Password', controller: confirm, obscureText: hideConfirm, suffixIcon: IconButton(icon: Icon(hideConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19), onPressed: () => setState(() => hideConfirm = !hideConfirm)), validator: (v) => v != password.text ? 'Passwords do not match' : null), const SizedBox(height: 22),
      PrimaryButton(text: 'Create an account', onPressed: () { if (key.currentState!.validate()) { showMessage(context, 'Account created successfully.'); Future.delayed(const Duration(milliseconds: 600), () { if (mounted) Navigator.pushReplacementNamed(context, '/login'); }); } }),
      const SizedBox(height: 10), GoogleButton(onPressed: () => showMessage(context, 'Google sign-up selected.')), const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already have account? ', style: TextStyle(fontSize: 11, color: Color(0xFF5574E8))), GestureDetector(onTap: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Sign in', style: TextStyle(fontSize: 11, color: Color(0xFF5574E8), decoration: TextDecoration.underline)))]),
    ]))),
  ))));
}
