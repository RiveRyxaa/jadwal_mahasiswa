import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _universitasController = TextEditingController();
  final _jurusanController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universitasController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      universitas: _universitasController.text.trim(),
      jurusan: _jurusanController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/icon.png',
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(height: 16),
              Text('Buat Akun', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
              const SizedBox(height: 6),
              Text('Bergabung dengan SobatKuliah dan atur kehidupan akademikmu', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(controller: _namaController, labelText: 'Nama Lengkap', hintText: 'Masukkan nama lengkap', prefixIcon: Icons.person_outline, validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _emailController, labelText: 'Email', hintText: 'mahasiswa@universitas.ac.id', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) { if (v == null || v.isEmpty) return 'Email tidak boleh kosong'; if (!v.contains('@')) return 'Format email tidak valid'; return null; }),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _passwordController, labelText: 'Password', hintText: 'Minimal 6 karakter', prefixIcon: Icons.lock_outline, obscureText: _obscurePassword, suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), validator: (v) { if (v == null || v.isEmpty) return 'Password tidak boleh kosong'; if (v.length < 6) return 'Password minimal 6 karakter'; return null; }),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _confirmPasswordController, labelText: 'Konfirmasi Password', hintText: 'Ulangi password', prefixIcon: Icons.lock_outline, obscureText: _obscureConfirm, suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)), validator: (v) => v != _passwordController.text ? 'Password tidak cocok' : null),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _universitasController, labelText: 'Universitas', hintText: 'Nama universitas', prefixIcon: Icons.account_balance_outlined),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _jurusanController, labelText: 'Jurusan', hintText: 'Nama jurusan', prefixIcon: Icons.book_outlined),
                      const SizedBox(height: 28),
                      CustomButton(text: 'Register', onPressed: _handleRegister, isLoading: auth.isLoading),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Sudah punya akun? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                GestureDetector(onTap: () => Navigator.of(context).pop(), child: Text('Masuk', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
