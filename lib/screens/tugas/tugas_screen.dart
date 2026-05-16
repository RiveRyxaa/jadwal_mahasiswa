import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../models/tugas_model.dart';
import 'tambah_tugas_screen.dart';

class TugasScreen extends StatelessWidget {
  const TugasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final tugasProv = context.watch<TugasProvider>();
    final userId = auth.currentUser?.id ?? '';

    final urgent = tugasProv.tugasAktif.where((t) => t.prioritas == Prioritas.tinggi || t.isOverdue).length;
    final inProgress = tugasProv.tugasAktif.length;
    final completed = tugasProv.tugasSelesai.length;

    final highTasks = tugasProv.tugasAktif.where((t) => t.prioritas == Prioritas.tinggi).toList();
    final medTasks = tugasProv.tugasAktif.where((t) => t.prioritas == Prioritas.sedang).toList();
    final lowTasks = tugasProv.tugasAktif.where((t) => t.prioritas == Prioritas.rendah).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(
                    auth.currentUser?.nama.isNotEmpty == true ? auth.currentUser!.nama[0].toUpperCase() : 'M',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  )),
                ),
                const SizedBox(width: 10),
                Text('CampusFlow', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                const Spacer(),
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
                    ),
                    child: Icon(Icons.notifications_none_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, size: 22),
                  ),
                ),
              ]),

              const SizedBox(height: 28),

              // ── Header ──
              Text('My Tasks', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Stay organized and track your academic progress.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),

              const SizedBox(height: 24),

              // ── Summary Cards ──
              _SummaryCard(label: 'URGENT', count: urgent, color: const Color(0xFFEF4444), bgColor: const Color(0xFFFEE2E2), isDark: isDark),
              const SizedBox(height: 10),
              _SummaryCard(label: 'IN PROGRESS', count: inProgress, color: AppColors.primaryPurple, bgColor: const Color(0xFFF3EEFA), isDark: isDark),
              const SizedBox(height: 10),
              _SummaryCard(label: 'COMPLETED', count: completed, color: const Color(0xFF10B981), bgColor: const Color(0xFFD1FAE5), isDark: isDark),

              const SizedBox(height: 32),

              // ── High Priority ──
              if (highTasks.isNotEmpty) ...[
                _PriorityHeader(label: 'High Priority', color: AppColors.priorityHigh),
                const SizedBox(height: 12),
                ...highTasks.map((t) => _TaskTile(
                  tugas: t, isDark: isDark, badgeColor: AppColors.priorityHigh, badgeText: 'HIGH',
                  onToggle: () => tugasProv.toggleStatus(userId, t.id),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TambahTugasScreen(tugas: t))),
                  onDelete: () => _confirmDelete(context, userId, t, tugasProv),
                )),
                const SizedBox(height: 20),
              ],

              // ── Medium Priority ──
              if (medTasks.isNotEmpty) ...[
                _PriorityHeader(label: 'Medium Priority', color: AppColors.priorityMedium),
                const SizedBox(height: 12),
                ...medTasks.map((t) => _TaskTile(
                  tugas: t, isDark: isDark, badgeColor: AppColors.priorityMedium, badgeText: 'MEDIUM',
                  onToggle: () => tugasProv.toggleStatus(userId, t.id),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TambahTugasScreen(tugas: t))),
                  onDelete: () => _confirmDelete(context, userId, t, tugasProv),
                )),
                const SizedBox(height: 20),
              ],

              // ── Low Priority ──
              if (lowTasks.isNotEmpty) ...[
                _PriorityHeader(label: 'Low Priority', color: AppColors.priorityLow),
                const SizedBox(height: 12),
                ...lowTasks.map((t) => _TaskTile(
                  tugas: t, isDark: isDark, badgeColor: AppColors.priorityLow, badgeText: 'LOW',
                  onToggle: () => tugasProv.toggleStatus(userId, t.id),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TambahTugasScreen(tugas: t))),
                  onDelete: () => _confirmDelete(context, userId, t, tugasProv),
                )),
                const SizedBox(height: 20),
              ],

              // ── Completed section ──
              if (tugasProv.tugasSelesai.isNotEmpty) ...[
                _PriorityHeader(label: 'Completed', color: AppColors.success),
                const SizedBox(height: 12),
                ...tugasProv.tugasSelesai.take(3).map((t) => _TaskTile(
                  tugas: t, isDark: isDark, badgeColor: AppColors.success, badgeText: 'DONE',
                  onToggle: () => tugasProv.toggleStatus(userId, t.id),
                  onTap: () {},
                  onDelete: () => _confirmDelete(context, userId, t, tugasProv),
                )),
              ],

              // Empty state
              if (tugasProv.tugasList.isEmpty) ...[
                const SizedBox(height: 40),
                Center(child: Column(children: [
                  Icon(Icons.task_alt, size: 64, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('No tasks yet', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
                  const SizedBox(height: 4),
                  Text('Tap + to add your first task', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
                ])),
              ],

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TambahTugasScreen())),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId, TugasModel t, TugasProvider prov) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hapus Tugas'),
      content: Text('Hapus tugas "${t.judul}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        TextButton(onPressed: () { prov.deleteTugas(userId, t.id); Navigator.pop(ctx); }, child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}

// ── Summary Card ──
class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;
  final bool isDark;
  const _SummaryCard({required this.label, required this.count, required this.color, required this.bgColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      ]),
    );
  }
}

// ── Priority Header ──
class _PriorityHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _PriorityHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}

// ── Task Tile ──
class _TaskTile extends StatelessWidget {
  final TugasModel tugas;
  final bool isDark;
  final Color badgeColor;
  final String badgeText;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _TaskTile({required this.tugas, required this.isDark, required this.badgeColor, required this.badgeText, required this.onToggle, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCompleted = tugas.status == StatusTugas.selesai;
    final deadlineStr = DateFormat('MMM d, yyyy').format(tugas.deadline);
    final isOverdue = tugas.isOverdue;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24, height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryPurple : Colors.transparent,
                border: Border.all(color: isCompleted ? AppColors.primaryPurple : (isDark ? AppColors.darkBorder : AppColors.border), width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(tugas.judul, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, decoration: isCompleted ? TextDecoration.lineThrough : null, color: isCompleted ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary) : null))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: badgeColor)),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.calendar_today, size: 12, color: isOverdue ? AppColors.error : (isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
              const SizedBox(width: 4),
              Text(isOverdue ? 'Overdue • $deadlineStr' : deadlineStr, style: TextStyle(fontSize: 11, color: isOverdue ? AppColors.error : (isDark ? AppColors.darkTextSecondary : AppColors.textHint), fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal)),
            ]),
          ])),
        ]),
      ),
    );
  }
}
