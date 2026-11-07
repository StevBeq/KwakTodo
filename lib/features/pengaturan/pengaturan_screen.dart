library;

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'api_keys_screen.dart';
import 'notifikasi_settings_screen.dart';
import 'reminder_screen.dart';

/// Layar Pengaturan — halaman ringkas: baris menu yang menyelam ke
/// sub-layar masing-masing (Reminder / API Key / Notifikasi), lalu
/// informasi privasi + versi. Konfigurasi detail tidak "terpampang"
/// di depan — aman dan tumpukan kartunya pendek.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  void _open(BuildContext context, WidgetBuilder page) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (pageCtx) => page(pageCtx)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pengaturan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  _MenuCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Reminder Deadline',
                    subtitle: s.remEnabled ? s.remRulesLabel : 'Tidak aktif',
                    badge: _Badge(
                      label: s.remEnabled ? 'ON' : 'OFF',
                      on: s.remEnabled,
                    ),
                    onTap: () => _open(
                      context,
                      (_) =>
                          ReminderScreen(onBack: () => Navigator.pop(context)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.key_rounded,
                    title: 'API Key Gemini',
                    subtitle: 'Digeser ke halaman tersendiri biar aman',
                    badge: const _SudahBadge(),
                    onTap: () => _open(
                      context,
                      (_) =>
                          ApiKeysScreen(onBack: () => Navigator.pop(context)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.sms_outlined,
                    title: 'Notifikasi',
                    subtitle: 'Izin HP · tes · inbox notifikasi',
                    badge: const _Badge(label: '3 opsi', on: false),
                    onTap: () => _open(
                      context,
                      (_) => NotifikasiSettingsScreen(
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PrivacyCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'KwakTodo v1.1 · AI Task Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Baris menu utama Pengaturan: ikon + judul + ringkasan + chevron.
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        badge,
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip status kecil utk baris menu (ON hijau / OFF abu / info neutral).
class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.on = false});

  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: on
            ? AppColors.success.withValues(alpha: .12)
            : AppColors.fieldFill,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: on ? AppColors.success : AppColors.muted,
        ),
      ),
    );
  }
}

/// Penanda "tersamar / di halaman khusus" — primary-soft.
class _SudahBadge extends StatelessWidget {
  const _SudahBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.chip,
      ),
      child: const Text(
        'aman 🔒',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

/// Kartu kebijakan privasi (informasi penyimpanan lokal).
class _PrivacyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🛡 Data & Privasi',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seluruh tugas tersimpan di HP-mu (SQLite lokal, tanpa server). '
            'Saat pakai AI, teks/voice/foto dikirim ke Google Gemini untuk '
            'diproses.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted.withValues(alpha: 1),
            ),
          ),
        ],
      ),
    );
  }
}
