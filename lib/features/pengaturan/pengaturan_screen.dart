library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifikasi/notifikasi_screen.dart';
import '../../core/notifications/notifier.dart';
import '../../shared/providers/notif_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/round_back_button.dart';
import '../../shared/widgets/toast.dart';
import 'api_keys_card.dart';
import 'reminder_card.dart';

/// Layar Pengaturan — design-reference.html (204–260): kartu API Key Gemini,
/// Reminder Deadline (H-N + jam), Notifikasi (izin / kirim tes / inbox),
/// kartu privasi, versi app.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _tesNotif(BuildContext context) async {
    final notifProvider = context.read<NotifProvider>();
    // Tampil sekarang (ARCHITECTURE §6) + tulis baris inbox.
    await Notifier.showNow(
      id: 9000001,
      title: '🔔 Tes notifikasi',
      body: 'Kalau ini muncul di inbox, jalur reminder kamu aman.',
    );
    await notifProvider.add(
      title: '🔔 Tes notifikasi',
      body: 'Kalau ini muncul di inbox, jalur reminder kamu aman.',
    );
    if (!context.mounted) return;
    showAppToast(context, 'Notifikasi tes terkirim — cek inbox!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundBackButton(onTap: onBack),
                  const SizedBox(width: 12),
                  const Text(
                    'Pengaturan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const ApiKeysCard(),
              const SizedBox(height: 16),
              const ReminderCard(),
              const SizedBox(height: 16),
              _NotifRowCard(
                onPermission: () async {
                  // Runtime Android 13+ (ARCHITECTURE §6); ditolak → buka
                  // Settings HP.
                  final ok = await Notifier.requestDisplayPermission();
                  if (!context.mounted) return;
                  showAppToast(
                    context,
                    ok
                        ? 'Izin notifikasi: aktif ✅'
                        : 'Belum diberi izin '
                              '— atur di Settings HP',
                  );
                },
                onTest: () => _tesNotif(context),
                onInbox: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (pageCtx) =>
                        NotifikasiScreen(onBack: () => Navigator.pop(pageCtx)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PrivacyCard(),
              const SizedBox(height: 24),
              const Text(
                'KwakTodo v1.0 · AI Task Assistant',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifRowCard extends StatelessWidget {
  const _NotifRowCard({
    required this.onPermission,
    required this.onTest,
    required this.onInbox,
  });

  final VoidCallback onPermission;
  final VoidCallback onTest;
  final VoidCallback onInbox;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.sms_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Notifikasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _NotifButton(
            icon: Icons.shield_rounded,
            label: 'Izin notifikasi HP (Android / iOS)',
            onTap: onPermission,
          ),
          const SizedBox(height: 8),
          _NotifButton(
            icon: Icons.send_outlined,
            label: 'Kirim notifikasi tes',
            onTap: onTest,
          ),
          const SizedBox(height: 8),
          _NotifButton(
            icon: Icons.inbox_outlined,
            label: 'Lihat semua notifikasi masuk',
            onTap: onInbox,
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  const _NotifButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldFill,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
