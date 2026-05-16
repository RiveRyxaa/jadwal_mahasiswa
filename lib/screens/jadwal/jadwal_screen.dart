import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/jadwal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jadwal_provider.dart';
import 'tambah_jadwal_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late int _selectedDayIndex;
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // weekday: 1=Monday .. 7=Sunday
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _selectedDayIndex = now.weekday - 1; // 0=Mon
    if (_selectedDayIndex > 5) _selectedDayIndex = 0; // Sunday → Mon
  }

  String get _weekRangeText {
    final end = _weekStart.add(const Duration(days: 6));
    final startStr = DateFormat('MMMM d').format(_weekStart);
    final endStr = DateFormat('d, yyyy').format(end);
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final jadwalProv = context.watch<JadwalProvider>();
    final days = JadwalModel.hariList; // Senin..Sabtu
    final selectedDay = days[_selectedDayIndex];
    final dayJadwal = jadwalProv.getJadwalByHari(selectedDay);

    // Check "happening now" — current time between start and end
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final todayName = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][now.weekday - 1];

    // Find last class end time for empty state
    String? lastClassEnd;
    if (dayJadwal.isNotEmpty) {
      lastClassEnd = dayJadwal.last.jamSelesai;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        auth.currentUser?.nama.isNotEmpty == true
                            ? auth.currentUser!.nama[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CampusFlow',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  // Notification bell
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notifications coming soon!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Weekly Schedule header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Schedule',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _weekRangeText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // + Add Class button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TambahJadwalScreen(defaultHari: selectedDay)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Add Class',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Day Selector (horizontal scroll) ──
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6, // Mon-Sat
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;
                  final dayDate = _weekStart.add(Duration(days: index));
                  final dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index];
                  final dateNum = dayDate.day.toString();

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : (isDark ? AppColors.darkCard : AppColors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : (isDark ? AppColors.darkBorder : AppColors.divider),
                          width: isSelected ? 0 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateNum,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── "Today's Lectures" section header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Today's Lectures",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Lecture List ──
            Expanded(
              child: dayJadwal.isEmpty
                  ? _buildEmptyState(context, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dayJadwal.length + 1, // +1 for empty tail
                      itemBuilder: (context, index) {
                        if (index == dayJadwal.length) {
                          // Empty state after last class
                          return _buildNoMoreClasses(context, isDark, lastClassEnd);
                        }
                        final jadwal = dayJadwal[index];

                        // Determine if "happening now"
                        bool isHappeningNow = false;
                        if (selectedDay == todayName) {
                          final startParts = jadwal.jamMulai.split(':');
                          final endParts = jadwal.jamSelesai.split(':');
                          final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
                          final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
                          isHappeningNow = currentMinutes >= startMin && currentMinutes < endMin;
                        }

                        // Calculate duration
                        final startParts = jadwal.jamMulai.split(':');
                        final endParts = jadwal.jamSelesai.split(':');
                        final durationMin = (int.parse(endParts[0]) * 60 + int.parse(endParts[1])) -
                            (int.parse(startParts[0]) * 60 + int.parse(startParts[1]));

                        // Generate a course code from matkul name
                        final codeWords = jadwal.namaMatkul.split(' ');
                        final codePrefix = codeWords.length >= 2
                            ? codeWords[0].substring(0, (codeWords[0].length).clamp(0, 4)).toUpperCase()
                            : jadwal.namaMatkul.substring(0, jadwal.namaMatkul.length.clamp(0, 4)).toUpperCase();
                        final codeNum = (jadwal.id.hashCode % 900 + 100).abs().toString();

                        return _LectureCard(
                          jadwal: jadwal,
                          durationMin: durationMin,
                          courseCode: codePrefix,
                          courseNum: codeNum,
                          isHappeningNow: isHappeningNow,
                          isDark: isDark,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => TambahJadwalScreen(jadwal: jadwal)),
                            );
                          },
                          onDelete: () => _confirmDelete(auth.currentUser!.id, jadwal),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.primaryPurpleVeryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 40,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "+ Add Class" to add a lecture',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textHint,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreClasses(BuildContext context, bool isDark, String? lastTime) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.divider,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 36,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textHint,
          ),
          const SizedBox(height: 10),
          Text(
            lastTime != null ? 'No classes after $lastTime' : 'No more classes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String userId, JadwalModel jadwal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Hapus jadwal ${jadwal.namaMatkul}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<JadwalProvider>().deleteJadwal(userId, jadwal.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Lecture Card (Timeline-style, matching design)
// ─────────────────────────────────────────────────────────
class _LectureCard extends StatelessWidget {
  final JadwalModel jadwal;
  final int durationMin;
  final String courseCode;
  final String courseNum;
  final bool isHappeningNow;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _LectureCard({
    required this.jadwal,
    required this.durationMin,
    required this.courseCode,
    required this.courseNum,
    required this.isHappeningNow,
    required this.isDark,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isHappeningNow
                ? AppColors.primaryPurple
                : (isDark ? AppColors.darkCard : AppColors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHappeningNow
                  ? AppColors.primaryPurple
                  : (isDark ? AppColors.darkBorder : AppColors.divider),
            ),
            boxShadow: isHappeningNow
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: Time & Duration ──
                SizedBox(
                  width: 52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.jamMulai,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isHappeningNow
                              ? Colors.white
                              : AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$durationMin MINS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isHappeningNow
                              ? Colors.white.withValues(alpha: 0.7)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ── Vertical divider line ──
                Container(
                  width: 2,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isHappeningNow
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),

                const SizedBox(width: 14),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HAPPENING NOW badge
                      if (isHappeningNow) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'HAPPENING NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Course name
                      Text(
                        jadwal.namaMatkul,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isHappeningNow
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Professor
                      if (jadwal.namaDosen.isNotEmpty)
                        Text(
                          jadwal.namaDosen,
                          style: TextStyle(
                            fontSize: 13,
                            color: isHappeningNow
                                ? Colors.white.withValues(alpha: 0.8)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Room & info row
                      Row(
                        children: [
                          if (jadwal.ruangan.isNotEmpty) ...[
                            Icon(
                              Icons.door_front_door_outlined,
                              size: 14,
                              color: isHappeningNow
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              jadwal.ruangan,
                              style: TextStyle(
                                fontSize: 12,
                                color: isHappeningNow
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          if (isHappeningNow) ...[
                            Icon(
                              Icons.sensors_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Live',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ] else if (jadwal.catatan.isNotEmpty) ...[
                            Icon(
                              Icons.note_outlined,
                              size: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                jadwal.catatan,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Course Code Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHappeningNow
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isDark
                            ? AppColors.darkSurface
                            : AppColors.primaryPurpleVeryLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        courseCode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isHappeningNow
                              ? Colors.white
                              : AppColors.primaryPurple,
                        ),
                      ),
                      Text(
                        courseNum,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isHappeningNow
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.primaryPurple.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
