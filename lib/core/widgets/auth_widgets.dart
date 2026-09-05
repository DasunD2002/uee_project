import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthField extends StatelessWidget {
  const AuthField({super.key, required this.label, this.hint, this.controller, this.keyboardType, this.obscureText = false, this.suffixIcon, this.validator});
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
    decoration: fieldDecoration(label, hint).copyWith(
      contentPadding: const EdgeInsets.fromLTRB(13, 12, 8, 9),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 34),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
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
      style: FilledButton.styleFrom(backgroundColor: AppColors.brown, shape: const StadiumBorder()),
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
      style: OutlinedButton.styleFrom(foregroundColor: Colors.black87, backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFD9D9D9)), shape: const StadiumBorder(), elevation: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/images/google_icon.png', width: 22, height: 22), const SizedBox(width: 13), const Text('Sign in with Google')]),
    ),
  );
}

InputDecoration fieldDecoration(String label, String? hint) => InputDecoration(
  labelText: label,
  hintText: hint,
  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF858585)),
  filled: true,
  fillColor: const Color(0xFFF3F1F1),
  isDense: true,
  contentPadding: const EdgeInsets.fromLTRB(13, 9, 8, 8),
  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF999999))),
  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brown, width: 1.5)),
);

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}
