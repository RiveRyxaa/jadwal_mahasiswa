import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../models/tugas_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jadwalProv = context.watch<JadwalProvider>();
    final tugasProv = context.watch<TugasProvider>();
    final now = DateTime.now();

    // Build notification items
    final List<_NotifItem> items = [];

    // 1) Jadwal notifications - classes within 15 minutes
    final todayJadwal = jadwalProv.jadwalHariIni;
    for (final j in todayJadwal) {
      final parts = j.jamMulai.split(':');
      final classTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      final diff = classTime.difference(now);

      if (diff.inMinutes > 0 && diff.inMinutes <= 15) {
        items.add(_NotifItem(
          icon: Icons.school_rounded,
          iconColor: AppColors.error,
          bgColor: AppColors.error,
          title: 'Kelas Dimulai ${diff.inMinutes} Menit Lagi!',
          subtitle: '${j.namaMatkul} • ${j.jamMulai} - ${j.jamSelesai}',
          detail: j.ruangan.isNotEmpty ? '📍 ${j.ruangan}' : '',
          time: '${diff.inMinutes}m lagi',
          type: _NotifType.urgent,
        ));
      } else if (diff.inMinutes > 15 && diff.inMinutes <= 60) {
        items.add(_NotifItem(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.warning,
          bgColor: AppColors.warning,
          title: 'Kelas Mendatang',
          subtitle: '${j.namaMatkul} • ${j.jamMulai} - ${j.jamSelesai}',
          detail: j.ruangan.isNotEmpty ? '📍 ${j.ruangan}' : '',
          time: '${diff.inMinutes}m lagi',
          type: _NotifType.warning,
        ));
      } else if (diff.inMinutes > 60) {
        items.add(_NotifItem(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.primaryPurple,
          bgColor: AppColors.primaryPurple,
          title: 'Jadwal Hari Ini',
          subtitle: '${j.namaMatkul} • ${j.jamMulai} - ${j.jamSelesai}',
          detail: j.ruangan.isNotEmpty ? '📍 ${j.ruangan}' : '',
          time: '${diff.inHours}j ${diff.inMinutes % 60}m lagi',
          type: _NotifType.info,
        ));
      }
    }

    // 2) Upcoming classes tomorrow
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final tomorrowIndex = now.weekday % 7; // weekday: Mon=1, Sun=7
    final tomorrowJadwal = jadwalProv.getJadwalByHari(days[tomorrowIndex]);
    if (tomorrowJadwal.isNotEmpty) {
      items.add(_NotifItem(
        icon: Icons.event_rounded,
        iconColor: const Color(0xFF4F9FE8),
        bgColor: const Color(0xFF4F9FE8),
        title: 'Jadwal Besok (${days[tomorrowIndex]})',
        subtitle: '${tomorrowJadwal.length} kelas: ${tomorrowJadwal.map((j) => j.namaMatkul).join(", ")}',
        detail: 'Kelas pertama: ${tomorrowJadwal.first.jamMulai}',
        time: 'Besok',
        type: _NotifType.info,
      ));
    }

    // 3) Tugas deadline notifications
    for (final t in tugasProv.tugasAktif) {
      final diff = t.deadline.difference(now);

      if (diff.isNegative) {
        // Overdue
        items.add(_NotifItem(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.error,
          bgColor: AppColors.error,
          title: 'Tugas Terlambat!',
          subtitle: t.judul,
          detail: 'Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(t.deadline)}',
          time: '${-diff.inHours}j lewat',
          type: _NotifType.urgent,
        ));
      } else if (diff.inHours <= 1) {
        items.add(_NotifItem(
          icon: Icons.alarm_rounded,
          iconColor: AppColors.error,
          bgColor: AppColors.error,
          title: 'Deadline Kurang dari 1 Jam!',
          subtitle: t.judul,
          detail: 'Segera selesaikan tugasmu!',
          time: '${diff.inMinutes}m lagi',
          type: _NotifType.urgent,
        ));
      } else if (diff.inHours <= 3 && t.prioritas == Prioritas.tinggi) {
        items.add(_NotifItem(
          icon: Icons.priority_high_rounded,
          iconColor: AppColors.error,
          bgColor: AppColors.error,
          title: 'Tugas Prioritas Tinggi!',
          subtitle: t.judul,
          detail: 'Deadline dalam ${diff.inHours} jam',
          time: '${diff.inHours}j lagi',
          type: _NotifType.urgent,
        ));
      } else if (diff.inHours <= 24) {
        items.add(_NotifItem(
          icon: Icons.access_time_rounded,
          iconColor: AppColors.warning,
          bgColor: AppColors.warning,
          title: 'Deadline Hari Ini!',
          subtitle: t.judul,
          detail: 'Deadline: ${DateFormat('HH:mm').format(t.deadline)}',
          time: '${diff.inHours}j lagi',
          type: _NotifType.warning,
        ));
      } else if (diff.inDays <= 3) {
        items.add(_NotifItem(
          icon: Icons.event_note_rounded,
          iconColor: const Color(0xFFE8924F),
          bgColor: const Color(0xFFE8924F),
          title: 'Deadline ${diff.inDays} Hari Lagi',
          subtitle: t.judul,
          detail: 'Deadline: ${DateFormat('dd MMM yyyy').format(t.deadline)}',
          time: '${diff.inDays}h lagi',
          type: _NotifType.warning,
        ));
      } else if (diff.inDays <= 7) {
        items.add(_NotifItem(
          icon: Icons.event_rounded,
          iconColor: AppColors.primaryPurple,
          bgColor: AppColors.primaryPurple,
          title: 'Tugas Minggu Ini',
          subtitle: t.judul,
          detail: 'Deadline: ${DateFormat('EEEE, dd MMM').format(t.deadline)}',
          time: '${diff.inDays}h lagi',
          type: _NotifType.info,
        ));
      }
    }

    // Sort by urgency
    items.sort((a, b) => a.type.index.compareTo(b.type.index));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Semua notifikasi telah dibaca'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Tandai Dibaca', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.primaryPurpleVeryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_off_outlined, size: 40, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                  ),
                  const SizedBox(height: 16),
                  Text('Tidak ada notifikasi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'Notifikasi akan muncul saat jadwal\nkuliah atau deadline tugas mendekat',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1, // +1 for header
              separatorBuilder: (_, i) => i == 0 ? const SizedBox.shrink() : const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${items.length} Notifikasi', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('EEEE, dd MMM').format(now),
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                final item = items[index - 1];
                return _NotificationCard(item: item, isDark: isDark);
              },
            ),
    );
  }
}

enum _NotifType { urgent, warning, info }

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String detail;
  final String time;
  final _NotifType type;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.time,
    required this.type,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotifItem item;
  final bool isDark;

  const _NotificationCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUrgent = item.type == _NotifType.urgent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.divider),
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.bgColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isUrgent ? AppColors.error : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.bgColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.time,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item.iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                if (item.detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.7) : AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
