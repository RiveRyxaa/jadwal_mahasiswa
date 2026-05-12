import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/tugas_model.dart';

class TugasCard extends StatelessWidget {
  final TugasModel tugas;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TugasCard({
    super.key,
    required this.tugas,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  Color _getPriorityColor() {
    switch (tugas.prioritas) {
      case Prioritas.tinggi:
        return AppColors.priorityHigh;
      case Prioritas.sedang:
        return AppColors.priorityMedium;
      case Prioritas.rendah:
        return AppColors.priorityLow;
    }
  }

  IconData _getPriorityIcon() {
    switch (tugas.prioritas) {
      case Prioritas.tinggi:
        return Icons.keyboard_double_arrow_up;
      case Prioritas.sedang:
        return Icons.drag_handle;
      case Prioritas.rendah:
        return Icons.keyboard_arrow_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = tugas.status == StatusTugas.selesai;
    final deadlineStr = DateFormat('dd MMM yyyy, HH:mm').format(tugas.deadline);
    final isOverdue = tugas.isOverdue;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primaryPurple
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primaryPurple
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.border),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tugas.judul,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)
                                : null,
                          ),
                    ),
                    if (tugas.deskripsi.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tugas.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Priority badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getPriorityIcon(),
                                size: 12,
                                color: _getPriorityColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tugas.prioritasLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getPriorityColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Deadline
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: isOverdue
                              ? AppColors.error
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deadlineStr,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: isOverdue
                                        ? AppColors.error
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
