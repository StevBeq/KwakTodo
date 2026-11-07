library;

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Tile maskot Kwak (brand tetap, kini berbahasa "di atas air") —
/// dipisah dari waktu splash agar file ≤ 300 baris (RULES).
class MaskotTile extends StatelessWidget {
  const MaskotTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow.withValues(alpha: .35),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Image.asset(
          'assets/images/logo.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.primarySoft,
            alignment: Alignment.center,
            child: const Text('🦆', style: TextStyle(fontSize: 60)),
          ),
        ),
      ),
    );
  }
}

/// Wordmark KwakTodo + chip AI (warna token, tanpa hardcode).
class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Kwak',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const Text(
          'Todo',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'AI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
