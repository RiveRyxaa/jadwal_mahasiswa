import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../widgets/countdown_widget.dart';
import '../../widgets/jadwal_card.dart';
import '../../widgets/tugas_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final jadwalProv = context.watch<JadwalProvider>();
    final tugasProv = context.watch<TugasProvider>();
    final user = auth.currentUser;
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Selamat Pagi' : now.hour < 17 ? 'Selamat Siang' : 'Selamat Malam';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greeting 👋', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(user?.nama ?? 'Mahasiswa', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(user?.nama.isNotEmpty == true ? user!.nama[0].toUpperCase() : 'M', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(DateFormat('EEEE, dd MMMM yyyy').format(now), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const SizedBox(height: 24),

              // Countdown Widget
              CountdownWidget(nextClass: jadwalProv.kelasBerikutnya, timeUntil: jadwalProv.waktuMenujuKelasBerikutnya),
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  _StatCard(icon: Icons.calendar_today_rounded, label: 'Jadwal Hari Ini', value: '${jadwalProv.jadwalHariIni.length}', color: AppColors.primaryPurple, isDark: isDark),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.assignment_outlined, label: 'Tugas Aktif', value: '${tugasProv.tugasAktif.length}', color: AppColors.warning, isDark: isDark),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.warning_amber_rounded, label: 'Overdue', value: '${tugasProv.tugasOverdue.length}', color: AppColors.error, isDark: isDark),
                ],
              ),
              const SizedBox(height: 28),

              // Today's Schedule
              _SectionHeader(title: 'Jadwal Hari Ini', icon: Icons.calendar_today_rounded),
              const SizedBox(height: 12),
              if (jadwalProv.jadwalHariIni.isEmpty)
                _EmptyState(message: 'Tidak ada jadwal hari ini', icon: Icons.event_available)
              else
                ...jadwalProv.jadwalHariIni.map((j) => JadwalCard(jadwal: j, isCompact: true)),

              const SizedBox(height: 24),

              // Upcoming Deadlines
              _SectionHeader(title: 'Deadline Terdekat', icon: Icons.access_alarm_rounded),
              const SizedBox(height: 12),
              if (tugasProv.tugasDeadlineTerdekat.isEmpty)
                _EmptyState(message: 'Tidak ada tugas aktif', icon: Icons.task_alt)
              else
                ...tugasProv.tugasDeadlineTerdekat.take(3).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TugasCard(
                    tugas: t,
                    onToggle: () => tugasProv.toggleStatus(user!.id, t.id),
                  ),
                )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: AppColors.primaryPurple),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primaryPurpleVeryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Icon(icon, size: 36, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
      ]),
    );
  }
}
