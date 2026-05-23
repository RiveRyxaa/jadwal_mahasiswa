import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../models/tugas_model.dart';
import '../main_navigation.dart';
import '../jadwal/tambah_jadwal_screen.dart';
import '../tugas/tambah_tugas_screen.dart';
import '../notification/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final jadwalProv = context.watch<JadwalProvider>();
    final tugasProv = context.watch<TugasProvider>();
    final user = auth.currentUser;
    final nextClass = jadwalProv.kelasBerikutnya;
    final timeUntil = jadwalProv.waktuMenujuKelasBerikutnya;
    final todayJadwal = jadwalProv.jadwalHariIni;
    final now = DateTime.now();
    final currentMin = now.hour * 60 + now.minute;

    // Tasks stats
    final totalTugas = tugasProv.tugasList.length;
    final selesai = tugasProv.tugasSelesai.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──
              _TopBar(user: user, isDark: isDark),
              const SizedBox(height: 24),

              // ── Next Class Card ──
              _NextClassCard(
                nextClass: nextClass,
                timeUntil: timeUntil,
                onViewDetails: () {
                  if (nextClass != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TambahJadwalScreen(jadwal: nextClass)),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // ── Stats Row ──
              Row(children: [
                Expanded(child: _StatCard(
                  icon: Icons.menu_book_rounded,
                  value: totalTugas > 0 ? ((selesai / totalTugas) * 4).toStringAsFixed(2) : '0.00',
                  label: 'IPK • ${DateFormat('yyyy').format(now)}',
                  badge: 'RATA-RATA AKADEMIK',
                  isDark: isDark,
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
                  onTap: () => MainNavigation.switchTab(context, 2),
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$selesai/$totalTugas',
                    label: '',
                    badge: 'TUGAS SELESAI',
                    isDark: isDark,
                  ),
                )),
              ]),
              const SizedBox(height: 28),

              // ── Today's Schedule ──
              Row(children: [
                Text("Jadwal Hari Ini", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => MainNavigation.switchTab(context, 1),
                  child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primaryPurple, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 14),
              if (todayJadwal.isEmpty)
                _EmptyBox(text: 'Tidak ada kelas hari ini', icon: Icons.event_available, isDark: isDark)
              else
                ...todayJadwal.map((j) {
                  final sp = j.jamMulai.split(':');
                  final hour = int.parse(sp[0]);
                  final ampm = hour >= 12 ? 'PM' : 'AM';
                  final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                  final timeStr = '${h12.toString().padLeft(2, '0')}:${sp[1]}';
                  final startMin = int.parse(sp[0]) * 60 + int.parse(sp[1]);
                  final ep = j.jamSelesai.split(':');
                  final endMin = int.parse(ep[0]) * 60 + int.parse(ep[1]);
                  final isLive = currentMin >= startMin && currentMin < endMin;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TambahJadwalScreen(jadwal: j)),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isLive ? AppColors.primaryPurple : (isDark ? AppColors.darkCard : AppColors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isLive ? AppColors.primaryPurple : (isDark ? AppColors.darkBorder : AppColors.divider)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isLive ? Colors.white.withValues(alpha: 0.2) : (isDark ? AppColors.darkSurface : AppColors.primaryPurpleVeryLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(children: [
                            Text(timeStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isLive ? Colors.white : AppColors.primaryPurple)),
                            Text(ampm, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isLive ? Colors.white.withValues(alpha: 0.7) : AppColors.primaryPurple.withValues(alpha: 0.6))),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(j.namaMatkul, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLive ? Colors.white : null)),
                          Text('Lec. ${j.ruangan} • ${j.namaDosen}', style: TextStyle(fontSize: 11, color: isLive ? Colors.white.withValues(alpha: 0.7) : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary))),
                        ])),
                        if (isLive) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                          child: const Text('BERLANGSUNG', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // ── Upcoming Tasks ──
              Row(children: [
                Text('Tugas Mendatang', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TambahTugasScreen()),
                    );
                  },
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: AppColors.primaryPurple, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              if (tugasProv.tugasDeadlineTerdekat.isEmpty)
                _EmptyBox(text: 'Belum ada tugas', icon: Icons.task_alt, isDark: isDark)
              else
                ...tugasProv.tugasDeadlineTerdekat.take(3).map((t) => _TaskItem(
                  tugas: t,
                  isDark: isDark,
                  onToggle: () {
                    final userId = auth.currentUser?.id ?? '';
                    tugasProv.toggleStatus(userId, t.id);
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TambahTugasScreen(tugas: t)),
                    );
                  },
                )),

              // More tasks hint
              if (tugasProv.tugasAktif.length > 3) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => MainNavigation.switchTab(context, 2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.primaryPurpleVeryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                    ),
                    child: Column(children: [
                      Text('Kamu punya ${tugasProv.tugasAktif.length - 3} tugas lagi bulan ini.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      const Text('Lihat semua tugas', style: TextStyle(color: AppColors.primaryPurple, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ──
class _TopBar extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  const _TopBar({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(
          user?.nama?.isNotEmpty == true ? user!.nama[0].toUpperCase() : 'M',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        )),
      ),
      const SizedBox(width: 10),
      Text('SobatKuliah', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
      const Spacer(),
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          );
        },
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
          ),
          child: Icon(Icons.notifications_none_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, size: 22),
        ),
      ),
    ]);
  }
}

// ── Next Class Card ──
class _NextClassCard extends StatelessWidget {
  final dynamic nextClass;
  final Duration? timeUntil;
  final VoidCallback? onViewDetails;
  const _NextClassCard({required this.nextClass, required this.timeUntil, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    if (nextClass == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _badge('KELAS BERIKUTNYA'),
          const SizedBox(height: 12),
          const Text('Tidak ada kelas mendatang', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Tambahkan jadwal untuk memulai', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
        ]),
      );
    }

    final hours = timeUntil?.inHours ?? 0;
    final minutes = (timeUntil?.inMinutes ?? 0) % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _badge('KELAS BERIKUTNYA'),
        const SizedBox(height: 14),
        Text(nextClass.namaMatkul, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.8), size: 16),
          const SizedBox(width: 6),
          Text('${nextClass.jamMulai} - ${nextClass.ruangan}', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Text('Mulai dalam ${hours}j ${minutes}m', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onViewDetails,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Lihat Detail', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  static Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String badge;
  final bool isDark;
  const _StatCard({required this.icon, required this.value, required this.label, required this.badge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primaryPurple, size: 22),
          const Spacer(),
          Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        ],
      ]),
    );
  }
}

// ── Task Item ──
class _TaskItem extends StatelessWidget {
  final TugasModel tugas;
  final bool isDark;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  const _TaskItem({required this.tugas, required this.isDark, this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final deadlineStr = DateFormat('EEEE, h:mm a').format(tugas.deadline);
    final isUrgent = tugas.prioritas == Prioritas.tinggi;
    final diff = tugas.deadline.difference(DateTime.now());
    final badgeText = isUrgent ? 'MENDESAK' : (diff.inDays <= 7 ? 'MINGGU INI' : 'MENDATANG');
    final badgeColor = isUrgent ? AppColors.error : (diff.inDays <= 7 ? AppColors.warning : AppColors.primaryPurple);
    final isCompleted = tugas.status == StatusTugas.selesai;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Checkbox - tappable
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22, height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryPurple : Colors.transparent,
                border: Border.all(color: isCompleted ? AppColors.primaryPurple : (isDark ? AppColors.darkBorder : AppColors.border), width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(tugas.judul, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, decoration: isCompleted ? TextDecoration.lineThrough : null))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: badgeColor)),
              ),
            ]),
            if (tugas.deskripsi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(tugas.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            ],
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.calendar_today, size: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
              const SizedBox(width: 4),
              Text(deadlineStr, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

// ── Empty Box ──
class _EmptyBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;
  const _EmptyBox({required this.text, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primaryPurpleVeryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Icon(icon, size: 32, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
      ]),
    );
  }
}
