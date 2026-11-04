library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tombol lingkaran putih kembali — dipakai semua layar non-beranda
/// (prototype: `w-10 h-10 rounded-full bg-white shadow-sm` + arrow-left).
class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.ink.withValues(alpha: .1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, size: 18),
        ),
      ),
    );
  }
}
