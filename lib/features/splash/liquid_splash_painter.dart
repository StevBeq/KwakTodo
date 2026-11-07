library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Pelukis gelombang "liquid" splash: dua lapis gelombang air hangat
/// (gerak sinus bergeser terus), tetesan jatuh + ripple memudar saat
/// menyentuh air — satu ide material (cairan), bukan tumpukan efek.
class LiquidSplashPainter extends CustomPainter {
  const LiquidSplashPainter({required this.t});

  /// Progres global controller 0..1 — phase gelombang terus gerak, bukan
  /// berhenti di 1 (loop sin).
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final baseline = size.height * .82;

    _ripple(canvas, w, baseline, t);
    _droplet(canvas, w, baseline, t);
    _waveLayer(
      canvas,
      w,
      baseline + 10,
      size.height,
      phase: t * math.pi * 2.4,
      amp: 10,
      color: AppColors.primary.withValues(alpha: .30),
    );
    _waveLayer(
      canvas,
      w,
      baseline + 22,
      size.height,
      phase: t * math.pi * 3.6 + 1.4,
      amp: 14,
      color: AppColors.primary.withValues(alpha: .65),
    );
  }

  /// Dua lingkaran stroke memudar tepat setelah tetesan menyentuh air
  /// (window progress .28–.58), pusatnya sama dengan posisi tetesan.
  void _ripple(Canvas canvas, double w, double cy, double t) {
    final win = Interval(.28, .58);
    final p = win.transform(t.clamp(0.0, 1.0));
    if (p <= 0 || p >= 1) return;
    final cx = w / 2 + 30;
    final landY = cy - 8;
    for (final (lag, gain) in [(0.0, .7), (.18, .45)]) {
      final p2 = (p - lag / .3).clamp(0.0, 1.0);
      if (p2 <= 0) continue;
      final r = Tween<double>(begin: 10, end: 110).transform(p2);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * (1 - p2) + .6
        ..color = AppColors.primary.withValues(alpha: gain * (1 - p2));
      canvas.drawCircle(Offset(cx, landY), r, paint);
    }
  }

  /// Tetesan oranye jatuh dari atas ke permukaan air (window .02–.28),
  /// squash kecil di momen impact.
  void _droplet(Canvas canvas, double w, double baseline, double t) {
    final win = Interval(.02, .28);
    final p = win.transform(t.clamp(0.0, 1.0));
    if (p <= 0 || p >= 1) return;
    final cx = w / 2 + 30;
    final startY = sizeTop(baseline);
    final y = Tween<double>(
      begin: startY,
      end: baseline - 8,
    ).chain(CurveTween(curve: Curves.easeInCubic)).transform(p);
    final squash = 1 + (1 - p) * .25;
    final paint = Paint()..color = AppColors.primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, y), width: 11, height: 13 * squash),
      paint,
    );
  }

  double sizeTop(double baseline) => baseline - 200;

  /// Satu lapis gelombang: kurva sinus 2 panjang gelombang + warna fill
  /// sampai bawah.
  void _waveLayer(
    Canvas canvas,
    double w,
    double top,
    double bottom, {
    required double phase,
    required double amp,
    required Color color,
  }) {
    // Sampel melewati tepi (−2 .. w+2) supaya tidak ada jahitan vertikal
    // di pinggir layar akibat kurva yang belum mencapai batas.
    final path = Path()..moveTo(-2, bottom);
    for (var x = -2.0; x <= w + 2; x += 4) {
      final y = top + amp * math.sin(phase + x / w * math.pi * 4);
      path.lineTo(x, y);
    }
    path
      ..lineTo(w + 2, bottom)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(LiquidSplashPainter oldDelegate) => oldDelegate.t != t;
}
