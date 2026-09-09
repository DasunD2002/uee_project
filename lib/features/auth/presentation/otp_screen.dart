import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.email = ''});
  final String email;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final code = TextEditingController();
  String? error;
  int seconds = 30;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
        return;
      }
      setState(() => seconds--);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    code.dispose();
    super.dispose();
  }

  void check() {
    if (code.text != '123456') {
      setState(
        () => error = code.text.length != 6
            ? 'Enter all 6 digits.'
            : 'That code is incorrect. Try again.',
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFAF6),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFAF6),
      title: const Text('Verification'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFFFE1CC),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 46,
                    color: AppColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'One step closer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Verify your email to begin your Rootly journey${widget.email.isEmpty ? '.' : '.\n${widget.email}'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF71655F), height: 1.6),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: code,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 15,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (_) => setState(() => error = null),
                onSubmitted: (_) => check(),
                decoration: fieldDecoration(
                  '6-digit code',
                  '••••••',
                ).copyWith(errorText: error),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: check,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Check code'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: seconds > 0
                    ? null
                    : () {
                        setState(() {
                          seconds = 30;
                          code.clear();
                          error = null;
                        });
                        startCountdown();
                        showMessage(context, 'Demo code renewed: 123456');
                      },
                child: Text(
                  seconds > 0 ? 'Resend code in ${seconds}s' : 'Resend code',
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Demo verification • use 123456\nNo email or SMS is sent in this preview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71655F),
                    height: 1.5,
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
