library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../core/utils/format.dart';
import '../../shared/providers/task_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/calendar_grid.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/task_card.dart';
import '../task_detail/task_detail_sheet.dart';

/// Layar Jadwal — CalendarGrid card (paper: white r24 p4, label bulan +
/// chevron), legend, label hari terpilih, list task hari itu (proto).
class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late int _selectedDay = DateTime.now().day;

  void _shift(int delta) {
    final m = DateTime(_month.year, _month.month + delta);
    setState(() => _month = m);
  }

  void _pick(int d) => setState(() => _selectedDay = d);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final now = DateTime.now();
    final selDate = DateTime(_month.year, _month.month, _selectedDay);
    final dayTasks =
        tasks
            .where((t) => t.deadline != null && sameDay(t.deadline!, selDate))
            .toList()
          ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    final isToday = sameDay(selDate, now);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Jadwal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            _CalendarCard(
              month: _month,
              selectedDay: _selectedDay,
              tasks: tasks,
              now: now,
              onShift: _shift,
              onPickDay: _pick,
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                text: fmtShortDay(selDate) + (isToday ? ' · Hari Ini' : ''),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (dayTasks.isEmpty)
              const EmptyState(
                icon: Icons.coffee_rounded,
                title: 'Tidak ada tugas di tanggal ini',
                subtitle: 'Kosong, enjoy ☕',
              )
            else
              ...List.generate(
                dayTasks.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    task: dayTasks[i],
                    now: now,
                    onTap: () => showTaskDetailSheet(context, dayTasks[i], now),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.selectedDay,
    required this.tasks,
    required this.now,
    required this.onShift,
    required this.onPickDay,
  });

  final DateTime month;
  final int selectedDay;
  final List<Task> tasks;
  final DateTime now;
  final ValueChanged<int> onShift;
  final ValueChanged<int> onPickDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => onShift(-1),
                iconSize: 14,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.muted,
                ),
              ),
              Expanded(
                child: Text(
                  fmtMonthYear(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onShift(1),
                iconSize: 14,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CalendarGrid(
            month: month,
            selectedDay: selectedDay,
            tasks: tasks,
            now: now,
            onPickDay: onPickDay,
          ),
        ],
      ),
    );
  }
}
