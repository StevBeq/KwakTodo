library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../shared/providers/task_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/round_back_button.dart';

/// Layar Statistik — DESIGN.md §5.4: card ring + 3 StatCards, card
/// Per Kategori (CategoryBar), card Deadline Minggu Ini (WeekBars).
class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final now = DateTime.now();

    final total = tasks.length;
    final done = tasks.where((t) => t.isDone).length;
    final over = tasks.where((t) => t.isOverdue(now)).length;
    final pct = total == 0 ? 0 : (done / total * 100).round();
    final statLine = total == 0
        ? 'Belum ada data tugas.'
        : '$done dari $total tugas selesai'
              '${over > 0 ? ', $over nyangkut overdue' : ''}';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                RoundBackButton(onTap: onBack),
                const SizedBox(width: 12),
                const Text(
                  'Statistik',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressRing(
                    progress: total == 0 ? 0 : done / total,
                    label: '$pct%',
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progres Selesai',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statLine,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            StatCard(
                              value: total,
                              label: 'Total',
                              bg: AppColors.primarySoft,
                              ink: AppColors.primaryDark,
                            ),
                            const SizedBox(width: 8),
                            StatCard(
                              value: done,
                              label: 'Selesai',
                              bg: AppColors.successSoft,
                              ink: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            StatCard(
                              value: over,
                              label: 'Overdue',
                              bg: AppColors.dangerSoft,
                              ink: AppColors.danger,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CategoryCardView(tasks: tasks),
            const SizedBox(height: 16),
            _WeekCard(tasks: tasks, now: now),
          ],
        ),
      ),
    );
  }
}

/// CategoryBar — label + jumlah, track cream radius pill, fill pastel (§5).
class _CategoryCardView extends StatelessWidget {
  const _CategoryCardView({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final counts = {for (final c in Category.values) c: 0};
    for (final t in tasks) {
      counts[t.category] = counts[t.category]! + 1;
    }
    final maxC = counts.values.fold(1, math.max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Per Kategori',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          for (final c in Category.values) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryLabels[c]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: categoryColorPairs[c]!.$2,
                    ),
                  ),
                ),
                Text(
                  '${counts[c]}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: SizedBox(
                height: 10,
                child: Stack(
                  children: [
                    Container(color: AppColors.trackCream),
                    FractionallySizedBox(
                      widthFactor: counts[c]! / maxC,
                      child: Container(color: categoryColorPairs[c]!.$1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// WeekBars — 7 kolom mulai Sabtu, hari ini primary, label hari di bawah (§5).
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.tasks, required this.now});

  final List<Task> tasks;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    const labels = ['Sab', 'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
    // start minggu = Sabtu terdekat ke bawah ((weekday+1)%7 = offset hingga Sab)
    final sat = now.subtract(Duration(days: (now.weekday + 1) % 7));
    final days = [
      for (var i = 0; i < 7; i++) DateTime(sat.year, sat.month, sat.day + i),
    ];
    final counts = [
      for (final d in days)
        tasks
            .where((t) => t.deadline != null && sameDay(t.deadline!, d))
            .length,
    ];
    final maxC = counts.fold(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deadline Minggu Ini',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Jumlah tugas dengan deadline per hari',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: counts[i] / maxC,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: sameDay(days[i], now)
                                ? AppColors.primary
                                : AppColors.trackCream,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final l in labels)
                Expanded(
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
