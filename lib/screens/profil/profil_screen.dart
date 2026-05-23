import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'contact_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  final _namaController = TextEditingController();
  final _univController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _univController.dispose();
    _jurusanController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(user?.nama.isNotEmpty == true ? user!.nama[0].toUpperCase() : 'M', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(user?.nama ?? 'Mahasiswa', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                if (user?.universitas.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text('${user!.universitas} • ${user.jurusan}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ]),
            ),
            const SizedBox(height: 24),

            // Settings List
            _SettingsTile(icon: Icons.edit_outlined, title: 'Edit Profil', onTap: () {
              _namaController.text = user?.nama ?? '';
              _univController.text = user?.universitas ?? '';
              _jurusanController.text = user?.jurusan ?? '';
              setState(() { _isEditingProfile = true; _isChangingPassword = false; });
            }),
            _SettingsTile(icon: Icons.lock_outline, title: 'Ganti Password', onTap: () {
              _oldPassController.clear(); _newPassController.clear();
              setState(() { _isChangingPassword = true; _isEditingProfile = false; });
            }),
            _SettingsTile(icon: Icons.headset_mic_outlined, title: 'Hubungi Kami', onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactScreen()));
            }),
            _SettingsTile(
              icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              title: isDark ? 'Mode Terang' : 'Mode Gelap',
              trailing: Switch(value: themeProv.isDarkMode, onChanged: (_) => themeProv.toggleTheme(), activeTrackColor: AppColors.primaryPurple),
              onTap: () => themeProv.toggleTheme(),
            ),
            const SizedBox(height: 8),
            _SettingsTile(icon: Icons.logout, title: 'Keluar', iconColor: AppColors.error, titleColor: AppColors.error, onTap: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Keluar'),
                content: const Text('Yakin ingin keluar?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                  TextButton(onPressed: () { Navigator.pop(ctx); auth.logout(); Navigator.of(context).pushReplacementNamed('/login'); }, child: const Text('Keluar', style: TextStyle(color: AppColors.error))),
                ],
              ));
            }),

            // Edit Profile Form
            if (_isEditingProfile) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                ),
                child: Column(children: [
                  CustomTextField(controller: _namaController, labelText: 'Nama', hintText: 'Nama lengkap', prefixIcon: Icons.person_outline),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _univController, labelText: 'Universitas', hintText: 'Nama universitas', prefixIcon: Icons.account_balance_outlined),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _jurusanController, labelText: 'Jurusan', hintText: 'Nama jurusan', prefixIcon: Icons.book_outlined),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: CustomButton(text: 'Batal', isOutlined: true, onPressed: () => setState(() => _isEditingProfile = false))),
                    const SizedBox(width: 12),
                    Expanded(child: CustomButton(text: 'Simpan', onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await auth.updateProfile(nama: _namaController.text.trim(), universitas: _univController.text.trim(), jurusan: _jurusanController.text.trim());
                      if (ok && mounted) { setState(() => _isEditingProfile = false); messenger.showSnackBar(SnackBar(content: const Text('Profil berhasil diupdate'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); }
                    })),
                  ]),
                ]),
              ),
            ],

            // Change Password Form
            if (_isChangingPassword) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                ),
                child: Column(children: [
                  CustomTextField(controller: _oldPassController, labelText: 'Password Lama', hintText: 'Masukkan password lama', prefixIcon: Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _newPassController, labelText: 'Password Baru', hintText: 'Minimal 6 karakter', prefixIcon: Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: CustomButton(text: 'Batal', isOutlined: true, onPressed: () => setState(() => _isChangingPassword = false))),
                    const SizedBox(width: 12),
                    Expanded(child: CustomButton(text: 'Simpan', onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (_newPassController.text.length < 6) { messenger.showSnackBar(SnackBar(content: const Text('Password minimal 6 karakter'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); return; }
                      final ok = await auth.changePassword(oldPassword: _oldPassController.text, newPassword: _newPassController.text);
                      if (ok && mounted) { setState(() => _isChangingPassword = false); messenger.showSnackBar(SnackBar(content: const Text('Password berhasil diubah'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); }
                      else if (mounted && auth.error != null) { messenger.showSnackBar(SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); }
                    })),
                  ]),
                ]),
              ),
            ],

            const SizedBox(height: 32),
            Text('SobatKuliah v1.0.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.trailing, this.iconColor, this.titleColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.primaryPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: titleColor)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
