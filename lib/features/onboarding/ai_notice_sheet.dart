library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';

/// One-time AI notice — kontrak prototype v2 (sheetNotice): tampil SEBELUM
/// layar AI dibuka pertama kali; flag `ai_notice_seen` di settings.
/// Returns true jika user menekan tombol lanjut (dismiss lain = false).
Future<bool> showAiNoticeSheet(BuildContext context) {
  final settings = context.read<SettingsProvider>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.ink.withValues(alpha: .6),
    builder: (sheetCtx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grabber,
                  borderRadius: AppRadius.chip,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shield_outlined,
                  size: 22,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sebelum pakai AI…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.muted,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Teks, transkrip suara, dan foto yang kamu '
                          'proses akan ',
                    ),
                    TextSpan(
                      text: 'dikirim ke Google Gemini',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' untuk di-parsing. Semua tugas '
                          'tersimpan ',
                    ),
                    TextSpan(
                      text: 'lokal di HP-mu',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' — bukan di server kami.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(true),
                  child: const Text('Paham, Lanjut 🚀'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ).then((value) async {
    if (value == true) {
      await settings.markAiNoticeSeen();
    }
    return value == true;
  });
}
