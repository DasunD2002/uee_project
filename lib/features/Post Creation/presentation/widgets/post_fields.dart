import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

const postFill = Color(0xFFFFF5EC);

InputDecoration postDecoration([String? hint]) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
  filled: true,
  fillColor: postFill,
  contentPadding: const EdgeInsets.all(15),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(13),
    borderSide: const BorderSide(color: Color(0xFFFFCEAB)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(13),
    borderSide: const BorderSide(color: Color(0xFFFFCEAB)),
  ),
);

class PostField extends StatelessWidget {
  const PostField(this.label, {super.key, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.brown,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class PostAction extends StatelessWidget {
  const PostAction(
    this.label, {
    super.key,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      elevation: outlined ? 0 : 6,
      backgroundColor: outlined ? Colors.white : AppColors.brown,
      foregroundColor: outlined ? AppColors.brown : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: outlined
            ? const BorderSide(color: Color(0xFFDDC5BD))
            : BorderSide.none,
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
