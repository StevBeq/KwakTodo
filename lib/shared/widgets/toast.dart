library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Toast pill ink bottom-center di atas nav, 2.4s — DESIGN.md §5 & §5 (Toast).
/// SATU pintu (RULES: tidak ada SnackBar ad-hoc di widget lain).
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.surface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const StadiumBorder(),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        duration: const Duration(milliseconds: 2400),
      ),
    );
}
