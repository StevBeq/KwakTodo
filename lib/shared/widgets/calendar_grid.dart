library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../theme/app_theme.dart';

/// CalendarGrid — DESIGN.md §5: 7 kolom mulai Sab (Sab Min Sen Sel Rab Kam
/// Jum), angka + dot, hari ini ring outline, terpilih bulatan primary penuh,
/// legend 3 state. Dot: overdue strip > deadline ungu > task cream (proto).
class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.tasks,
    required this.now,
    required this.onPickDay,
  });

  final DateTime month;
  final int selectedDay;
  final List<Task> tasks;
  final DateTime now;
  final ValueChanged<int> onPickDay;

  static const _dowLabels = ['Sab', 'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    // kolom pertama = Sabtu: offset = (weekday+1) % 7 dengan weekday 1=Sen.
    final startOffset = (first.weekday + 1) % 7;
    final dayCount = DateTime(month.year, month.month + 1, 0).day;

    final cells = <Widget>[
      // SEL KOSONG kalender: pakai SizedBox (Spacer=Expanded → illegal di
      // dalam sel GridView: Incorrect use of ParentDataWidget).
      for (var i = 0; i < startOffset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= dayCount; d++)
        _DayCell(
          day: d,
          dayTasks: tasks
              .where(
                (t) =>
                    t.deadline != null &&
                    sameDay(t.deadline!, DateTime(month.year, month.month, d)),
              )
              .toList(),
          isSelected: d == selectedDay,
          isToday: sameDay(DateTime(month.year, month.month, d), now),
          now: now,
          onTap: () => onPickDay(d),
        ),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final l in _dowLabels) ...[
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
            // trailing Spacer agar jumlah sel-spal sama (offset ganjil).
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          childAspectRatio: 26 / 36,
          children: cells,
        ),
        const Divider(height: 24, thickness: 1, color: AppColors.trackCream),
        const _Legend(),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dayTasks,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    required this.now,
  });

  final int day;
  final List<Task> dayTasks;
  final bool isSelected;
  final bool isToday;
  final DateTime now;
  final VoidCallback onTap;

  /// Dot state hari (proto renderCal): strip merah > ungu > cream;
  /// tanpa dot bila tak ada tugas.
  Widget? get _dot {
    if (dayTasks.isEmpty) return null;
    // perilaku proto: overdue di-hari KEMARIN ke bawah → strip.
    final hasPast = dayTasks.any(
      (t) => t.isOverdue(now) && !sameDay(t.deadline!, now),
    );
    if (hasPast) return const _StripedDot();
    final hasOpen = dayTasks.any((t) => !t.isDone);
    if (hasOpen) return const _SolidDot(color: AppColors.accent);
    return const _SolidDot(color: AppColors.dotTask);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : null,
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.surface : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(width: 7, height: 7, child: _dot),
        ],
      ),
    );
  }
}

/// Dot merah-muda bergaris 45° (CSS repeating-linear-gradient prototype).
class _StripedDot extends StatelessWidget {
  const _StripedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: [
            AppColors.danger,
            AppColors.danger,
            AppColors.overdueStripe,
            AppColors.overdueStripe,
          ],
          stops: [0, .5, .5, 1],
          tileMode: TileMode.repeated,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget dotItem(String label, Widget dot) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 7, height: 7, child: dot),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        dotItem('Ada tugas', _SolidDot(color: AppColors.dotTask)),
        dotItem('Deadline / kumpul', _SolidDot(color: AppColors.accent)),
        dotItem('Overdue', const _StripedDot()),
      ],
    );
  }
}

class _SolidDot extends StatelessWidget {
  const _SolidDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
