library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/utils/format.dart';
import '../../shared/theme/app_theme.dart';

/// Kartu preview hasil parse (prototype mockParse line 632): bg pastel
/// kategori draft, label DITEMUKAN N TUGAS, title, meta deadline/prioritas.
class DraftPreviewCard extends StatelessWidget {
  const DraftPreviewCard({super.key, required this.draft});

  final TaskDraft draft;

  @override
  Widget build(BuildContext context) {
    final category = draft.category ?? Category.akademik;
    final (bg, ink) = categoryColorPairs[category]!;
    final deadline = draft.deadline == null ? '' : fmtDeadline(draft.deadline!);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 DITEMUKAN TUGAS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            draft.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          if (deadline.isNotEmpty || draft.priority != null) ...[
            const SizedBox(height: 2),
            Text(
              [
                if (deadline.isNotEmpty) 'Deadline: $deadline',
                if (draft.priority != null)
                  'Prioritas: ${_prioLabel(draft.priority!)}',
              ].join(' · '),
              style: TextStyle(fontSize: 11, color: ink),
            ),
          ],
        ],
      ),
    );
  }

  String _prioLabel(Priority p) => switch (p) {
    Priority.high => 'Tinggi',
    Priority.medium => 'Sedang',
    Priority.low => 'Santai',
  };
}

/// Daftar preview draf hasil parsing di atas tombol Parse (state selesai).
class DraftPreviewList extends StatelessWidget {
  const DraftPreviewList({super.key, required this.drafts});

  final List<TaskDraft> drafts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          '${drafts.length} tugas ditemukan — cek sekilas:',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        for (final d in drafts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DraftPreviewCard(draft: d),
          ),
      ],
    );
  }
}
