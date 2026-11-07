library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/notifications/notifier.dart';
import '../../shared/providers/notif_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/round_back_button.dart';
import '../../shared/widgets/toast.dart';
import '../notifikasi/notifikasi_screen.dart';

/// Sub-layar Notifikasi (halaman baru di Pengaturan): izin runtime,
/// kirim notifikasi tes, dan masuk ke inbox notifikasi.
class NotifikasiSettingsScreen extends StatelessWidget {
  const NotifikasiSettingsScreen({super.key, required this.onBack});

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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      RoundBackButton(onTap: onBack),
                      const SizedBox(width: 12),
                      const Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _RowButton(
                    icon: Icons.shield_rounded,
                    label: 'Izin notifikasi HP (Android / iOS)',
                    onTap: () async {
                      // Runtime Android 13+ (ARCHITECTURE §6); ditolak →
                      // buka Settings HP.
                      final ok = await Notifier.requestDisplayPermission();
                      if (!context.mounted) return;
                      showAppToast(
                        context,
                        ok
                            ? 'Izin notifikasi: aktif ✅'
                            : 'Belum diberi izin — atur di Settings HP',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _RowButton(
                    icon: Icons.send_outlined,
                    label: 'Kirim notifikasi tes',
                    onTap: () => _tesNotif(context),
                  ),
                  const SizedBox(height: 8),
                  _RowButton(
                    icon: Icons.inbox_outlined,
                    label: 'Lihat semua notifikasi masuk',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (pageCtx) => NotifikasiScreen(
                          onBack: () => Navigator.pop(pageCtx),
                        ),
                      ),
                    ),
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

/// Baris aksi bergaya list Pengaturan lama (fieldFill + chevron).
class _RowButton extends StatelessWidget {
  const _RowButton({required this.icon, required this.label, this.onTap});

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
