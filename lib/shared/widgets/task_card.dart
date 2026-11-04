library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../core/utils/format.dart';
import '../theme/app_theme.dart';

/// Ikon per kategori — ekivalen Material dari FontAwesome prototype (DESIGN §7).
IconData categoryIcon(Category c) => switch (c) {
  Category.akademik => Icons.school_rounded,
  Category.personal => Icons.person_rounded,
  Category.organisasi => Icons.groups_rounded,
  Category.lainnya => Icons.more_horiz_rounded,
};

/// TaskCard — DESIGN.md §5: ikon kategori, judul, chip deadline, chip kategori,
/// badge Overdue/Selesai, chevron. Tap card = detail sheet (F2).
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.now,
    this.onTap,
  });

  final Task task;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final od = task.isOverdue(now);
    final (bg, ink) = categoryColorPairs[task.category]!;
    final chips = <Widget>[
      if (task.deadline != null)
        _Chip(
          icon: Icons.access_time,
          text: fmtDeadline(task.deadline!),
          bg: AppColors.primarySoft,
          fg: AppColors.primaryDark,
        ),
      _Chip(text: categoryLabels[task.category]!, bg: bg, fg: ink),
      if (od)
        const _Chip(
          text: 'Overdue',
          bg: AppColors.danger,
          fg: AppColors.surface,
        ),
      if (task.isDone)
        const _Chip(
          text: 'Selesai',
          bg: AppColors.success,
          fg: AppColors.surface,
        ),
    ];

    return Semantics(
      identifier: 'task_card_${task.id}',
      button: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (od) // state tidak hanya warna: strip kiri + badge teks (§6.4)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(color: AppColors.danger),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(od ? 20 : 16, 16, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        categoryIcon(task.category),
                        size: 17,
                        color: ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            identifier: 'task_title_${task.id}',
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: task.isDone
                                    ? AppColors.muted
                                    : AppColors.ink,
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.muted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(spacing: 8, runSpacing: 4, children: chips),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.chevron,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  final IconData? icon;
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
