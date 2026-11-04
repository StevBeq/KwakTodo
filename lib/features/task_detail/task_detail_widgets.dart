library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../shared/theme/app_theme.dart';

/// Widget pendukung TaskDetailSheet — dipisah agar file induk ≤300 baris
/// (RULES §1.5).

/// Label asal input task (prototype srcLabel).
String sourceLabel(TaskSource s) => switch (s) {
  TaskSource.manual => 'Diinput manual',
  TaskSource.aiVoice => 'Dari Voice AI',
  TaskSource.aiText => 'Dari Teks AI',
  TaskSource.aiPhoto => 'Dari Foto AI',
};

/// Tombol pil aksi detail (Selesai/Buka Lagi/Edit/Hapus).
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.filled = false,
    this.tint,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final bool filled;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint == null && filled ? AppColors.success : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: tint ?? AppColors.borderSoft, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color:
                    tint ??
                    (filled ? AppColors.surface : AppColors.primaryDark),
              ),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        tint ??
                        (filled ? AppColors.surface : AppColors.primaryDark),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip informasi detail (kategori/prioritas/deadline/badge).
class DetailChip extends StatelessWidget {
  const DetailChip({
    super.key,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
