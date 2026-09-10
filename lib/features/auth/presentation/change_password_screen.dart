import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.isReset = false});
  final bool isReset;
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      current = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  bool hidden = true;
  @override
  void dispose() {
    for (final c in [email, current, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    showMessage(
      context,
      'Password form completed in demo mode. No account password was changed.',
    );
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFAF6),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFAF6),
      title: Text(widget.isReset ? 'Reset password' : 'Change password'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFFFE1CC),
                    child: Icon(
                      Icons.lock_reset,
                      size: 42,
                      color: AppColors.brown,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isReset
                      ? 'A fresh start.'
                      : 'Keep your account secure.',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a password with at least 8 characters.',
                  style: TextStyle(color: Color(0xFF71655F)),
                ),
                const SizedBox(height: 26),
                if (widget.isReset)
                  AuthField(
                    label: 'Email address',
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v ?? '')
                        ? 'Enter a valid email'
                        : null,
                  )
                else
                  AuthField(
                    label: 'Current password',
                    controller: current,
                    obscureText: hidden,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Enter your current password'
                        : null,
                  ),
                const SizedBox(height: 18),
                AuthField(
                  label: 'New password',
                  controller: password,
                  obscureText: hidden,
                  validator: (v) => (v?.length ?? 0) < 8
                      ? 'Use at least 8 characters'
                      : !widget.isReset && v == current.text
                      ? 'Choose a different password'
                      : null,
                ),
                const SizedBox(height: 18),
                AuthField(
                  label: 'Confirm new password',
                  controller: confirm,
                  obscureText: hidden,
                  validator: (v) =>
                      v != password.text ? 'Passwords do not match' : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: !hidden,
                  title: const Text('Show passwords'),
                  onChanged: (v) => setState(() => hidden = !(v ?? false)),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(
                    widget.isReset ? 'Reset password' : 'Save password',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Preview only. Password changes require a connected account service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF71655F)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
