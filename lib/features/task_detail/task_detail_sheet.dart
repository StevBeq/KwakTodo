library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../core/utils/format.dart';
import '../../shared/providers/task_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/toast.dart';
import '../task_form/task_form_sheet.dart';
import '../../shared/widgets/task_card.dart' show categoryIcon;
import 'task_detail_widgets.dart' show ActionButton, DetailChip, sourceLabel;

/// TaskDetailSheet — DESIGN.md §5: ikon besar kategori, judul penuh,
/// chip kategori/prioritas/deadline, deskripsi, tombol Selesai/Buka Lagi ·
/// Edit · Hapus (Hapus = window UNDO 4 detik via TaskProvider).
void showTaskDetailSheet(BuildContext context, Task task, DateTime now) {
  final fresh = context
      .read<TaskProvider>()
      .tasks
      .where((t) => t.id == task.id)
      .firstOrNull;
  if (fresh == null) return; // sedang di jendela UNDO / sudah tidak ada
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.ink.withValues(alpha: .6),
    builder: (_) => _DetailBody(task: fresh),
  );
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.task});

  final Task task;

  void _toggle(BuildContext context) {
    Navigator.of(context).pop();
    final provider = context.read<TaskProvider>();
    provider.toggleDone(task);
    showAppToast(context, task.isDone ? 'Dibuka lagi' : 'Mantap, selesai! ✅');
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        // Scrollable agar keyboard tidak membuat RenderFlex overflow tipis.
        child: SingleChildScrollView(child: TaskFormSheet(initial: task)),
      ),
    );
  }

  void _delete(BuildContext context) {
    final title = task.title;
    Navigator.of(context).pop();
    final provider = context.read<TaskProvider>();
    provider.startDelete(task);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"$title" dihapus',
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          shape: const StadiumBorder(),
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.primary,
            onPressed: () => provider.cancelDelete(task.id),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final od = task.isOverdue(DateTime.now());
    final (bg, ink) = categoryColorPairs[task.category]!;
    final priorityInk = switch (task.priority) {
      Priority.high => AppColors.danger,
      Priority.medium => AppColors.primaryDark,
      Priority.low => AppColors.success,
    };

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sheet,
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.grabber,
                borderRadius: AppRadius.chip,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(categoryIcon(task.category), size: 24, color: ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone ? AppColors.muted : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sourceLabel(task.source),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DetailChip(text: categoryLabels[task.category]!, bg: bg, fg: ink),
              DetailChip(
                icon: Icons.flag_rounded,
                text: 'Prioritas ${priorityLabels[task.priority]!}',
                bg: AppColors.dangerSoft,
                fg: priorityInk,
              ),
              if (task.deadline != null)
                DetailChip(
                  icon: Icons.access_time,
                  text: fmtDeadline(task.deadline!),
                  bg: AppColors.primarySoft,
                  fg: AppColors.primaryDark,
                )
              else
                const DetailChip(
                  text: 'Tanpa deadline',
                  bg: AppColors.trackCream,
                  fg: AppColors.muted,
                ),
              if (od)
                const DetailChip(
                  text: 'Overdue',
                  bg: AppColors.danger,
                  fg: AppColors.surface,
                ),
            ],
          ),
          if (task.notes != null && task.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'DESKRIPSI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                task.notes!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  identifier: 'task_detail_toggle_btn',
                  button: true,
                  child: ActionButton(
                    label: task.isDone ? 'Buka Lagi' : 'Tandai Selesai',
                    filled: !task.isDone,
                    icon: task.isDone
                        ? Icons.rotate_left_rounded
                        : Icons.check_circle_outline,
                    onTap: () => _toggle(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  identifier: 'task_detail_edit_btn',
                  button: true,
                  child: ActionButton(
                    label: 'Edit',
                    filled: false,
                    icon: Icons.edit,
                    onTap: () => _openEdit(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                identifier: 'task_detail_delete_btn',
                button: true,
                child: ActionButton(
                  icon: Icons.delete_outline,
                  tint: AppColors.danger,
                  onTap: () => _delete(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
