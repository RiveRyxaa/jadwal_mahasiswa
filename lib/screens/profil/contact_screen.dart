import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/custom_button.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _pesanController = TextEditingController();
  String _selectedSubject = 'Pilih alasan menghubungi';
  bool _isSending = false;

  final List<String> _subjects = [
    'Pilih alasan menghubungi',
    'Pertanyaan Umum',
    'Masalah Teknis',
    'Saran & Masukan',
    'Laporan Bug',
    'Lainnya',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_namaController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _pesanController.text.trim().isEmpty ||
        _selectedSubject == 'Pilih alasan menghubungi') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon lengkapi semua field'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    // Simulate sending
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSending = false);
        _namaController.clear();
        _emailController.clear();
        _pesanController.clear();
        setState(() => _selectedSubject = 'Pilih alasan menghubungi');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pesan berhasil dikirim! Kami akan merespons dalam 24 jam.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungi Kami'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 22),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Bantuan'),
                  content: const Text('Hubungi kami melalui email atau kirim pesan langsung melalui form di bawah.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Section ──
            Text(
              'Kami Siap Membantu\nPerjalanan Akademik Anda',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Punya pertanyaan tentang SobatKuliah atau butuh bantuan teknis? Tim dukungan kami tersedia untuk memastikan pengalaman belajar Anda tetap lancar dan produktif.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),

            // ── Contact Cards ──
            _ContactCard(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFFE8924F),
              iconBgColor: const Color(0xFFFFF3E8),
              title: 'Email',
              subtitle: 'ridhovahrezi@gmail.com',
              info: 'Balasan dalam 24 jam',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFF4F9FE8),
              iconBgColor: const Color(0xFFE8F2FF),
              title: 'Telepon',
              subtitle: '+62 812 4955 4812',
              info: 'Senin - Jumat, 09:00 - 17:00 WIB',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.support_agent_rounded,
              iconColor: AppColors.primaryPurple,
              iconBgColor: AppColors.primaryPurpleVeryLight,
              title: 'Pusat Bantuan',
              subtitle: 'Cari jawaban instan di FAQ kami',
              info: 'Jelajahi FAQ',
              isLink: true,
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // ── Send Message Form ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kirim Pesan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Nama Lengkap
                  _buildLabel(context, 'Nama Lengkap'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(hintText: 'Budi Santoso'),
                  ),
                  const SizedBox(height: 16),

                  // Email Kampus
                  _buildLabel(context, 'Email Anda'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'budi@univ.ac.id'),
                  ),
                  const SizedBox(height: 16),

                  // Subjek
                  _buildLabel(context, 'Subjek'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubject,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 14, color: s == 'Pilih alasan menghubungi' ? AppColors.textHint : null)))).toList(),
                    onChanged: (val) => setState(() => _selectedSubject = val!),
                  ),
                  const SizedBox(height: 16),

                  // Pesan
                  _buildLabel(context, 'Pesan Anda'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _pesanController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Tuliskan detail pertanyaan atau kendala Anda di sini...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Send Button
                  CustomButton(
                    text: 'Kirim Pesan  ✉',
                    onPressed: _sendMessage,
                    isLoading: _isSending,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String info;
  final bool isLink;
  final bool isDark;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.info,
    this.isLink = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.15) : iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLink ? AppColors.primaryPurple : AppColors.success,
                    fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (isLink) Icon(Icons.open_in_new, size: 16, color: AppColors.primaryPurple),
        ],
      ),
    );
  }
}
