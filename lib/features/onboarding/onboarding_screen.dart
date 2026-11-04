library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_shell.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/toast.dart';

/// Onboarding — DESIGN.md §5 #1: full primary, brand, headline, dual CTA.
/// Flag `onboarded` di settings — tampil sekali (MASTER_SPEC onboarding).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Text('🦆', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KwakTodo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: .2),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Text(
                      'CATAT · AI · SELESAI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.2,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Atur Tugasmu,\nLebih Pintar\nSetiap Hari',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'Catat jadwal lewat suara, teks, atau cukup foto '
                      'screenshot tugas — AI merapikannya, kamu tinggal '
                      'acc. Bisa juga input manual kayak biasa.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.surface.withValues(alpha: .85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    identifier: 'onboarding_skip_btn',
                    button: true,
                    label: 'Lewati onboarding',
                    child: GestureDetector(
                      onTap: () => _finish(context),
                      child: Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface.withValues(alpha: .8),
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    identifier: 'onboarding_start_btn',
                    button: true,
                    label: 'Mulai sekarang',
                    child: Material(
                      color: AppColors.surface,
                      clipBehavior: Clip.antiAlias,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        onTap: () => _finish(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Mulai Sekarang',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_right,
                                size: 16,
                                color: AppColors.primaryDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish(BuildContext context) {
    context.read<SettingsProvider>().markOnboarded();
    showAppToast(context, 'Selamat datang! 👋');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, anim, secAnim) => const MainShell(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
