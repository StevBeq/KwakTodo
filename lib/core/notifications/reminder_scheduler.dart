/// ReminderScheduler — banyak aturan per tugas: "H-N hari pada jam NN"
/// atau "H-N jam sebelum deadline" (ARCHITECTURE.md §6, SCHEMA §8).
library;

import '../domain/models.dart';
import '../utils/format.dart';
import 'notifier.dart';

/// Satuan jeda aturan reminder: hitung mundur dari tanggal deadline
/// ke pukul tetap, atau mundur dari momen deadline itu sendiri.
enum RemUnit { day, hour }

/// Satu aturan reminder yang bisa user tambah/hapus sendiri:
/// `day`  → (tanggal deadline − [n] hari) pukul [hour]:00,
/// `hour` → ([deadline] − [n] jam; [hour] diabaikan).
class RemRule {
  const RemRule({required this.unit, required this.n, this.hour = 8});

  factory RemRule.fromJson(Map<String, dynamic> j) => RemRule(
    unit: j['mode'] == 'hour' ? RemUnit.hour : RemUnit.day,
    n: j['n'] as int,
    hour: j['hour'] as int? ?? 8,
  );

  final RemUnit unit;
  final int n;
  final int hour;

  Map<String, Object?> toJson() => unit == RemUnit.day
      ? {'mode': 'day', 'n': n, 'hour': hour}
      : {'mode': 'hour', 'n': n};

  /// Label ringkas untuk UI: "H-2 · 08:00" atau "H-7 jam".
  String get label => unit == RemUnit.day
      ? 'H-$n · ${hour.toString().padLeft(2, '0')}:00'
      : 'H-$n jam';

  /// Penjelasan satu baris (preview di daftar aturan).
  String get description => unit == RemUnit.day
      ? '$n hari sebelum deadline, pukul ${hour.toString().padLeft(2, '0')}:00'
      : '$n jam sebelum momen deadline';
}

/// Konfigurasi reminder global (dari SettingsProvider).
class RemCfg {
  const RemCfg({required this.enabled, required this.rules});

  final bool enabled;
  final List<RemRule> rules;
}

/// MURNI (unit test reminder_test): satu aturan + deadline → momen notif.
/// Tidak ada deadline / selesai / momen sudah lewat (termasuk aturan
/// memundurkan sampai ke masa lalu) → null.
DateTime? computeSchedule({
  required DateTime? deadline,
  required bool isDone,
  required RemRule rule,
  required DateTime now,
}) {
  if (deadline == null || isDone) return null;
  final DateTime at;
  if (rule.unit == RemUnit.day) {
    final day = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    ).subtract(Duration(days: rule.n));
    at = DateTime(day.year, day.month, day.day, rule.hour);
  } else {
    at = deadline.subtract(Duration(hours: rule.n));
  }
  if (!at.isAfter(now)) return null;
  return at;
}

/// Pengatur jadwal & pembatalan notifikasi reminder.
/// id notif = id task × 10 + indeks aturan (karena satu tugas kini bisa
/// punya beberapa alarm; SCHEMA §8). Slot lama ikut di-cancel supaya
/// aturan yang dihapus tidak meninggalkan alarm basi.
class ReminderScheduler {
  ReminderScheduler();

  /// Jumlah slot cadangan per tugas (≥ batas aturan di UI).
  static const slotsPerTask = 12;

  DateTime _now() => DateTime.now();

  /// Pasang/perbarui SEMUA alarm satu tugas sesuai konfigurasi sekarang.
  /// Dipanggil dari add/edit/undo/(un-)done (RULES §4).
  Future<void> schedule(Task t, RemCfg cfg) async {
    await cancelTask(t);
    if (!cfg.enabled) return;
    for (var i = 0; i < cfg.rules.length && i < slotsPerTask; i++) {
      final at = computeSchedule(
        deadline: t.deadline,
        isDone: t.isDone,
        rule: cfg.rules[i],
        now: _now(),
      );
      if (at == null) continue;
      await Notifier.zonedSchedule(
        id: t.id * slotsPerTask + i,
        title: '⏰ Pengingat: ${t.title}',
        body:
            'Deadline ${fmtDeadline(t.deadline!)} · jangan sampai '
            'ketinggalan!',
        at: at,
        payload: t.title,
      );
    }
  }

  /// Rekonstruksi semua jadwal (startup + perubahan konfigurasi).
  /// Tugas tanpa jadwal valid ikut di-cancel — tidak ada alarm basi.
  Future<void> rescheduleAll(List<Task> tasks, RemCfg cfg) async {
    for (final t in tasks) {
      await schedule(t, cfg);
    }
  }

  /// Hapus tugas → batal semua slot (id task × 10 + indeks, SCHEMA §8).
  Future<void> cancelTask(Task t) async {
    for (var i = 0; i < slotsPerTask; i++) {
      await Notifier.cancel(t.id * slotsPerTask + i);
    }
  }
}
