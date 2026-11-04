library;

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import '../task_form/task_form_sheet.dart';
import 'ai_capture_sheet.dart';
import 'ai_mode.dart';

/// Alur Tanya AI (PRD FR-2/FR-3): sheet capture → (drafts, mode) →
/// form review per draf (semua field editable) — "Acc & Tambahkan" membuat
/// task ber-source mode; "Buang" melewati draf itu; parse gagal tidak
/// pernah sampai sini (toast di sheet, input dipertahankan).
Future<void> showAiCaptureFlow(BuildContext context) async {
  final picked = await showAiCaptureSheet(context);
  if (picked == null) return;
  final (drafts, mode) = picked;
  // context = layar pemanggil — tetap hidup di bawah route sheet.
  for (final d in drafts) {
    if (!context.mounted) return;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: TaskFormSheet.review(draft: d, source: mode.source),
        ),
      ),
    );
    // acc != true (Buang) → draf dilewati, lanjut draf berikutnya.
  }
}
