library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/app_db.dart' as db;
import '../../core/utils/format.dart';
import '../../shared/providers/notif_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/round_back_button.dart';
import '../../shared/widgets/toast.dart';

/// Sub-layar Inbox Notifikasi — design-reference.html (191–202, 581–587):
/// header back + judul + chip "N baru", tombol "Tandai semua dibaca",
/// kartu item (dot merah bila belum dibaca, opacity .72 bila dibaca),
/// hapus per item, empty state "Inbox kosong".
class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotifProvider>();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: StreamBuilder<List<db.Notification>>(
              stream: notif.items,
              builder: (context, snapshot) {
                final list = snapshot.data ?? const [];
                final unread = list.where((n) => !n.read).length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(unread: unread, onBack: onBack),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: unread > 0 ? 1 : .4,
                        child: OutlinedButton.icon(
                          onPressed: unread > 0 ? notif.markAllRead : null,
                          icon: const Icon(Icons.done_all_rounded, size: 14),
                          label: const Text('Tandai semua dibaca'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.muted,
                            disabledForegroundColor: AppColors.muted.withValues(
                              alpha: 1,
                            ),
                            side: const BorderSide(
                              color: AppColors.borderSoft,
                              width: 2,
                            ),
                            minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (list.isEmpty)
                    const EmptyState(
                      icon: Icons.notifications_off_rounded,
                      title: 'Inbox kosong',
                      subtitle: 'Notifikasi reminder akan muncul di sini.',
                    )
                  else
                    ...List.generate(
                      list.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotifCard(
                          item: list[i],
                          now: now,
                          onRead: () => notif.markRead(list[i].id),
                          onDelete: () => notif.deleteItem(list[i].id),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  ),
);
}
}

class _Header extends StatelessWidget {
  const _Header({required this.unread, required this.onBack});

  final int unread;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundBackButton(onTap: onBack),
        const SizedBox(width: 12),
        const Text(
          'Notifikasi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: AppRadius.chip,
          ),
          child: Text(
            '$unread baru',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.item,
    required this.now,
    required this.onRead,
    required this.onDelete,
  });

  final db.Notification item;
  final DateTime now;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.read ? .72 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          onTap: item.read ? null : onRead,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.read)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 18,
                      color: AppColors.chevron,
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: _UnreadDot(),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmtNotifTime(item.createdAt, now),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.chevron,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                _DeleteButton(onTap: onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.danger,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          onTap();
          showAppToast(context, 'Notifikasi dihapus');
        },
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.delete_outline_rounded,
            size: 16,
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }
}
