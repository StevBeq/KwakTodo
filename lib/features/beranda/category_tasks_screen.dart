library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../shared/providers/task_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/round_back_button.dart';
import '../../shared/widgets/task_card.dart';
import '../task_detail/task_detail_sheet.dart';
import '../task_form/task_form_sheet.dart';

/// Halaman Khusus Kategori — Menampilkan seluruh tugas dalam satu kategori,
/// ringkasan progres kategori, dan tombol cepat untuk menambahkan tugas
/// langsung ke kategori yang sedang dibuka.
class CategoryTasksScreen extends StatelessWidget {
  const CategoryTasksScreen({super.key, required this.category});

  final Category category;

  void _openAddForm(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: TaskFormSheet(initialCategory: category),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final allCategoryTasks = provider.tasks
        .where((t) => t.category == category)
        .toList();
    final activeTasks = allCategoryTasks.where((t) => !t.isDone).toList();
    final doneTasks = allCategoryTasks.where((t) => t.isDone).toList();

    final (bg, ink) = categoryColorPairs[category]!;
    final label = categoryLabels[category]!;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    category: category,
                    label: label,
                    bg: bg,
                    ink: ink,
                    total: allCategoryTasks.length,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                  _CategoryBanner(
                    category: category,
                    label: label,
                    bg: bg,
                    ink: ink,
                    activeCount: activeTasks.length,
                    doneCount: doneTasks.length,
                    onAdd: () => _openAddForm(context),
                  ),
                  const SizedBox(height: 20),
                  if (allCategoryTasks.isEmpty)
                    EmptyState(
                      icon: categoryIcon(category),
                      title: 'Belum ada tugas $label',
                      subtitle:
                          'Tugas yang berkategori $label akan terkumpul di sini. '
                          'Ketuk tombol "+ Tambah" untuk memulai.',
                    )
                  else ...[
                    if (activeTasks.isNotEmpty) ...[
                      Text(
                        'AKTIF (${activeTasks.length})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final task in activeTasks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TaskCard(
                            task: task,
                            now: now,
                            onTap: () =>
                                showTaskDetailSheet(context, task, now),
                          ),
                        ),
                      const SizedBox(height: 14),
                    ],
                    if (doneTasks.isNotEmpty) ...[
                      Text(
                        'SELESAI (${doneTasks.length})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final task in doneTasks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TaskCard(
                            task: task,
                            now: now,
                            onTap: () =>
                                showTaskDetailSheet(context, task, now),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.category,
    required this.label,
    required this.bg,
    required this.ink,
    required this.total,
    required this.onBack,
  });

  final Category category;
  final String label;
  final Color bg;
  final Color ink;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundBackButton(onTap: onBack),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(categoryIcon(category), size: 18, color: ink),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chip),
          child: Text(
            '$total tugas',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner({
    required this.category,
    required this.label,
    required this.bg,
    required this.ink,
    required this.activeCount,
    required this.doneCount,
    required this.onAdd,
  });

  final Category category;
  final String label;
  final Color bg;
  final Color ink;
  final int activeCount;
  final int doneCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$activeCount belum selesai • $doneCount selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ink.withValues(alpha: .85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fokus menyelesaikan tugas $label kamu hari ini.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Tambah'),
            style: FilledButton.styleFrom(
              backgroundColor: ink,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
