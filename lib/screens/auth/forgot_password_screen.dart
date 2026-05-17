import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMsg = 'Masukkan email yang valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _sent = true;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Terjadi kesalahan: $e';
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan ($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              if (!_sent) ...[
                Icon(Icons.lock_reset_rounded, size: 48, color: AppColors.primaryPurple),
                const SizedBox(height: 16),
                Text('Reset Password', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Masukkan email yang terdaftar. Kami akan mengirim link untuk mereset password kamu.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // Error
                if (_errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'student@university.edu',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Kirim Link Reset',
                  onPressed: _sendResetEmail,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.primaryPurpleVeryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.primaryPurple),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Cek folder inbox dan spam di email kamu setelah mengirim link reset.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    )),
                  ]),
                ),
              ] else ...[
                const SizedBox(height: 40),
                Center(child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 48),
                )),
                const SizedBox(height: 24),
                Center(child: Text('Email Terkirim!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                const SizedBox(height: 12),
                Center(child: Text(
                  'Link reset password telah dikirim ke ${_emailController.text.trim()}. Buka email dan klik link untuk mereset password.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 12),
                Center(child: Text(
                  'Cek juga folder Spam jika tidak ada di Inbox.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 32),
                CustomButton(text: 'Kembali ke Login', onPressed: () => Navigator.of(context).pop()),
                const SizedBox(height: 12),
                Center(child: GestureDetector(
                  onTap: () => setState(() {
                    _sent = false;
                    _errorMsg = null;
                  }),
                  child: Text('Kirim ulang email', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w600)),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
