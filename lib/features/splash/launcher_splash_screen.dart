library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../main_shell.dart';
import '../onboarding/onboarding_screen.dart';
import 'liquid_splash_painter.dart';
import 'splash_mark.dart';

/// LauncherSplashScreen — momen masuk "liquid hangat": tetesan oranye
/// jatuh ke permukaan air, ripple memudar, maskot Kwak terapung di atas
/// gelombang berturut. Ketuk untuk lewati; Reduce Motion → tanpa gelombang.
class LauncherSplashScreen extends StatefulWidget {
  const LauncherSplashScreen({super.key});

  @override
  State<LauncherSplashScreen> createState() => _LauncherSplashScreenState();
}

class _LauncherSplashScreenState extends State<LauncherSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  static const _taglines = [
    'Biar bebek yang pusing, kamu santai aja.',
    'Otak boleh cengo, tugas tetap beres.',
    'Tugas numpuk? Kwak-in aja dulu.',
  ];

  late final String _tagline;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _tagline = _taglines[math.Random().nextInt(_taglines.length)];
    // Baca sebelum build (tidak boleh MediaQuery.of di initState).
    final reduced = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).disableAnimations;
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: reduced ? 500 : 1700),
    );
    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) _goToApp();
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
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: _goToApp,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              _SplashBody(c: _c, tagline: _tagline, reduced: reduced),
        ),
      ),
    );
  }
}

/// Isi splash harian: gelombang di belakang, maskot terapung, teks naik.
class _SplashBody extends StatelessWidget {
  const _SplashBody({
    required this.c,
    required this.tagline,
    required this.reduced,
  });

  final AnimationController c;
  final String tagline;
  final bool reduced;

  double _win(double t, double start, double end) => Interval(
    start,
    end,
    curve: Curves.easeOutCubic,
  ).transform(t.clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final t = c.value;
    final fadeOut = reduced
        ? 1.0
        : 1.0 - Interval(.88, 1.0, curve: Curves.easeIn).transform(t);

    // Maskot terapung: naik masuk + naik-turun sinus pelan kecil.
    final entry = _win(t, .06, .30);
    final bob = reduced ? 0.0 : math.sin(t * math.pi * 3) * 6;
    final duckShift = reduced ? 0.0 : 46 * (1 - entry) + bob;

    return Opacity(
      opacity: fadeOut.clamp(0.0, 1.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(painter: LiquidSplashPainter(t: t)),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                Transform.translate(
                  offset: Offset(0, duckShift),
                  child: Opacity(
                    opacity: entry,
                    child: Center(child: const MaskotTile()),
                  ),
                ),
                const SizedBox(height: 28),
                _TitleBlock(
                  tagline: tagline,
                  p: _win(t, .32, .64),
                  reduced: reduced,
                ),
                const Spacer(flex: 4),
                Opacity(
                  opacity: _win(t, .5, .8),
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 22),
                    child: Center(
                      child: Text(
                        'Voice · Vision · Offline AI',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          // Teks di atas permukaan gelombang primary →
                          // pakai foreground hangat, bukan abu (kontras).
                          color: AppColors.background,
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
    );
  }
}

/// Tile maskot Kwak (brand tetap, kini berbahasa "di atas air").
/// Judul + tagline: geser naik dari bawah dengan deceleration, bukan
/// bounce acak (animate.md: kurva natural, bukan elastic).
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.tagline,
    required this.p,
    required this.reduced,
  });

  final String tagline;
  final double p;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final shift = reduced ? 0.0 : 34 * (1 - p);

    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, shift),
        child: Column(
          children: [
            const Wordmark(),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: .85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tagline,
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
    );
  }
}
