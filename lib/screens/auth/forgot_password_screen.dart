import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.lock_reset_rounded, size: 48, color: AppColors.primaryPurple),
              const SizedBox(height: 16),
              Text('Reset Password', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Masukkan email yang terdaftar untuk mereset password.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const SizedBox(height: 32),
              if (!_sent) ...[
                CustomTextField(controller: _emailController, labelText: 'Email', hintText: 'student@university.edu', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 24),
                CustomButton(text: 'Send Reset Link', onPressed: () {
                  if (_emailController.text.isNotEmpty) {
                    setState(() => _sent = true);
                  }
                }),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Link reset password telah dikirim ke ${_emailController.text}', style: const TextStyle(color: AppColors.success))),
                  ]),
                ),
                const SizedBox(height: 24),
                CustomButton(text: 'Kembali ke Login', onPressed: () => Navigator.of(context).pop()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
