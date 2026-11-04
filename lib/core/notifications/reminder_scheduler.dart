/// ReminderScheduler — jadwal H-N jam NN, reschedule/cancel.
/// (ARCHITECTURE.md §6, SCHEMA.md §8, RULES §4).
library;

import '../domain/models.dart';
import '../utils/format.dart';
import 'notifier.dart';

/// Konfigurasi reminder global (dari SettingsProvider).
class RemCfg {
  const RemCfg({
    required this.enabled,
    required this.leadDays,
    required this.hour,
  });

  final bool enabled;
  final int leadDays;
  final int hour;
}

/// MURNI (unit test reminder_test): deadline + yad H-N jam 00..NN →
/// momen notif; kalau tidak ada deadline, selesai, atau momennya sudah
/// lewat (termasuk deadline hari-H → tidak buat reminder minus) → null.
DateTime? computeSchedule({
  required DateTime? deadline,
  required bool isDone,
  required int leadDays,
  required int hour,
  required DateTime now,
}) {
  if (deadline == null || isDone) return null;
  // Ambil tanggal deadline, lalu mundur N hari pada jam NN.
  final day = DateTime(
    deadline.year,
    deadline.month,
    deadline.day,
  ).subtract(Duration(days: leadDays));
  final at = DateTime(day.year, day.month, day.day, hour);
  if (!at.isAfter(now)) return null;
  return at;
}

/// Pengatur jadwal & pembatalan notifikasi reminder.
/// id notif = id task (SCHEMA §8: satu task satu reminder aktif).
class ReminderScheduler {
  ReminderScheduler();

  DateTime _now() => DateTime.now();

  /// Pasang/perbarui reminder satu tugas sesuai konfigurasi sekarang.
  /// Dipanggil dari add/edit/undo/(un-)done (RULES §4).
  Future<void> schedule(Task t, RemCfg cfg) async {
    await Notifier.cancel(t.id);
    final at = computeSchedule(
      deadline: t.deadline,
      isDone: t.isDone,
      leadDays: cfg.leadDays,
      hour: cfg.hour,
      now: _now(),
    );
    if (at == null) return;
    await Notifier.zonedSchedule(
      id: t.id,
      title: '⏰ Pengingat: ${t.title}',
      body:
          'Deadline ${fmtDeadline(t.deadline!)} · jangan sampai '
          'ketinggalan!',
      at: at,
      payload: t.title,
    );
  }

  /// Rekonstruksi semua jadwal (startup + perubahan konfigurasi).
  /// Tugas tanpa jadwal valid ikut di-cancel — tidak ada alarm basi.
  Future<void> rescheduleAll(List<Task> tasks, RemCfg cfg) async {
    for (final t in tasks) {
      await schedule(t, cfg);
    }
  }

  /// Hapus tugas → batal (SCHEMA §8) + hentikan window UNDO aktifnya.
  Future<void> cancelTask(Task t) => Notifier.cancel(t.id);
}
