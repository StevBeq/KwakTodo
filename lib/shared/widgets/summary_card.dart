library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../core/utils/format.dart';

/// SummaryCard Beranda — DESIGN.md §5: overline tanggal, H2 jumlah,
/// progress bar putih, tombol Manual (Tanya AI cukup lewat FAB bottom nav,
/// jangan dobel di header kartu).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.total,
    required this.done,
    required this.onManual,
  });

  final int total;
  final int done;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fmtHeaderDate(DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              color: AppColors.surface.withValues(alpha: .8),
            ),
          ),
          Text(
            '$total tugas · $done selesai',
            style: const TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadius.chip,
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: AppColors.surface.withValues(alpha: .25)),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.chip,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            identifier: 'summary_manual_btn',
            button: true,
            child: _SummaryButton(
              label: 'Tulis Manual',
              icon: Icons.add,
              onTap: onManual,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryButton extends StatelessWidget {
  const _SummaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: AppColors.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
