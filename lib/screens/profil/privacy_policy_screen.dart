import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terakhir diperbarui: 15 Juni 2026',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionTitle('1. Pendahuluan', isDark),
            _SectionBody(
              'SobatKuliah adalah aplikasi manajemen jadwal kuliah dan tugas untuk mahasiswa. '
              'Kami menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi yang Anda berikan. '
              'Kebijakan privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda.',
              isDark,
            ),
            const SizedBox(height: 20),

            _SectionTitle('2. Data yang Dikumpulkan', isDark),
            _BulletList([
              'Nama lengkap — untuk personalisasi tampilan aplikasi',
              'Alamat email — untuk autentikasi dan login akun',
              'Nama universitas & jurusan — untuk personalisasi profil',
              'Jadwal kuliah — disimpan secara lokal di perangkat Anda',
              'Data tugas — disimpan secara lokal di perangkat Anda',
            ], isDark),
            const SizedBox(height: 20),

            _SectionTitle('3. Cara Kami Menggunakan Data', isDark),
            _BulletList([
              'Autentikasi akun (login/register) melalui Firebase Authentication',
              'Menampilkan jadwal kuliah dan tugas Anda',
              'Mengirim notifikasi pengingat jadwal dan deadline tugas',
              'Menyediakan fitur reset password melalui email',
              'Personalisasi tampilan aplikasi (nama, avatar)',
            ], isDark),
            const SizedBox(height: 20),

            _SectionTitle('4. Penyimpanan Data', isDark),
            _SectionBody(
              'Data autentikasi (email, password terenkripsi) disimpan di Firebase Authentication yang dikelola oleh Google. '
              'Data jadwal kuliah dan tugas disimpan secara lokal di perangkat Anda menggunakan SharedPreferences. '
              'Kami tidak mengunggah data jadwal atau tugas Anda ke server manapun.',
              isDark,
            ),
            const SizedBox(height: 20),

            _SectionTitle('5. Izin Aplikasi', isDark),
            _PermissionItem(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              desc: 'Untuk mengirim pengingat jadwal kuliah dan deadline tugas',
              isDark: isDark,
            ),
            _PermissionItem(
              icon: Icons.alarm_outlined,
              title: 'Alarm Tepat Waktu',
              desc: 'Untuk menjadwalkan notifikasi pada waktu yang tepat',
              isDark: isDark,
            ),
            _PermissionItem(
              icon: Icons.restart_alt_outlined,
              title: 'Boot Completed',
              desc: 'Untuk menjadwalkan ulang notifikasi setelah perangkat di-restart',
              isDark: isDark,
            ),
            _PermissionItem(
              icon: Icons.vibration_outlined,
              title: 'Getaran',
              desc: 'Untuk memberikan getaran saat notifikasi masuk',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _SectionTitle('6. Keamanan Data', isDark),
            _SectionBody(
              'Kami menggunakan Firebase Authentication dari Google yang menyediakan enkripsi dan keamanan tingkat industri. '
              'Password Anda tidak pernah disimpan dalam bentuk teks biasa. '
              'Data lokal disimpan di penyimpanan internal aplikasi yang tidak dapat diakses oleh aplikasi lain.',
              isDark,
            ),
            const SizedBox(height: 20),

            _SectionTitle('7. Hak Pengguna', isDark),
            _BulletList([
              'Mengubah data profil (nama, universitas, jurusan) kapan saja',
              'Mengubah password akun',
              'Menghapus data jadwal dan tugas secara mandiri',
              'Menghapus akun dengan menghubungi developer',
              'Menonaktifkan notifikasi melalui pengaturan perangkat',
            ], isDark),
            const SizedBox(height: 20),

            _SectionTitle('8. Layanan Pihak Ketiga', isDark),
            _BulletList([
              'Firebase Authentication — untuk autentikasi pengguna',
              'Google Sign-In — untuk login menggunakan akun Google',
              'Google Fonts — untuk tampilan font aplikasi',
            ], isDark),
            _SectionBody(
              '\nLayanan pihak ketiga ini memiliki kebijakan privasi masing-masing. '
              'Kami menyarankan Anda untuk membaca kebijakan privasi mereka.',
              isDark,
            ),
            const SizedBox(height: 20),

            _SectionTitle('9. Perubahan Kebijakan', isDark),
            _SectionBody(
              'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. '
              'Perubahan akan diinformasikan melalui pembaruan aplikasi. '
              'Dengan terus menggunakan aplikasi, Anda menyetujui kebijakan privasi yang berlaku.',
              isDark,
            ),
            const SizedBox(height: 20),

            _SectionTitle('10. Hubungi Kami', isDark),
            _SectionBody(
              'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, silakan hubungi kami:',
              isDark,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.primaryPurpleVeryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.email_outlined, size: 18, color: AppColors.primaryPurple),
                    const SizedBox(width: 8),
                    Text(
                      'sobatkuliah.dev@gmail.com',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.person_outlined, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Developer: RiveRyxa',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2026 SobatKuliah. Hak cipta dilindungi.',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ──
class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Section Body ──
class _SectionBody extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionBody(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }
}

// ── Bullet List ──
class _BulletList extends StatelessWidget {
  final List<String> items;
  final bool isDark;
  const _BulletList(this.items, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ── Permission Item ──
class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isDark;
  const _PermissionItem({required this.icon, required this.title, required this.desc, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
