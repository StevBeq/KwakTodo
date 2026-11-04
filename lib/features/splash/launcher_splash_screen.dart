library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../main_shell.dart';
import '../onboarding/onboarding_screen.dart';

/// LauncherSplashScreen — Animasi pembuka KwakTodo yang kreatif & lucu.
/// Menampilkan maskot bebek cengo dengan animasi bounce elastis, waddle/goyang,
/// nama aplikasi "KwakTodo", dan tagline jenaka yang tidak alay.
class LauncherSplashScreen extends StatefulWidget {
  const LauncherSplashScreen({super.key});

  @override
  State<LauncherSplashScreen> createState() => _LauncherSplashScreenState();
}

class _LauncherSplashScreenState extends State<LauncherSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Animasi maskot: pop/scale up elastis
  late final Animation<double> _scaleAnim;

  // Animasi waddle/goyang kepala bebek
  late final Animation<double> _tiltAnim;

  // Animasi teks judul & tagline: slide up + fade in
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Animasi fade out akhir
  late final Animation<double> _exitFadeAnim;

  bool _navigated = false;

  // Pilihan tagline lucu tapi cerdas & tidak cringe
  static const _taglines = [
    'Biar bebek yang pusing, kamu santai aja.',
    'Otak boleh cengo, tugas tetap beres.',
    'Tugas numpuk? Kwak-in aja dulu.',
  ];

  late final String _tagline;

  @override
  void initState() {
    super.initState();

    // Pilih tagline secara acak setiap aplikasi dibuka
    _tagline = _taglines[math.Random().nextInt(_taglines.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 0ms - 900ms: Maskot pop up elastis
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    // 400ms - 1100ms: Bebek waddle/goyang gemoy
    _tiltAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.08), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.08), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.04), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.70, curve: Curves.easeInOut),
      ),
    );

    // 650ms - 1400ms: Judul & tagline muncul
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.75, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 1900ms - 2200ms: Fade out lembut ke aplikasi
    _exitFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToApp();
      }
    });
  }

  void _goToApp() {
    if (_navigated || !mounted) return;
    _navigated = true;

    final onboarded = context.read<SettingsProvider>().onboarded;
    final target = onboarded ? const MainShell() : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, anim, secAnim) => target,
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Ketuk layar di mana saja untuk lewati animasi langsung
      onTap: _goToApp,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _exitFadeAnim.value,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // === MASKOT BEBEK CENGO ===
                        Transform.scale(
                          scale: _scaleAnim.value,
                          child: Transform.rotate(
                            angle: _tiltAnim.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryShadow.withValues(
                                      alpha: .35,
                                    ),
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
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback jika asset belum dimuat
                                    return Container(
                                      color: AppColors.primarySoft,
                                      child: const Center(
                                        child: Text(
                                          '🦆',
                                          style: TextStyle(fontSize: 64),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // === NAMA APLIKASI: KwakTodo ===
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    Text(
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
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
                                ),

                                const SizedBox(height: 10),

                                // === TAGLINE LUCU & RELEVAN ===
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(
                                      alpha: .8,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.ink.withValues(
                                          alpha: .03,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _tagline,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 4),

                        // Sub-caption bawah / indikator
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Voice · Vision · Offline AI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted.withValues(
                                      alpha: .75,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

