/// Unit test ReminderScheduler — RULES §7: aturan day (tanggal − N hari
/// pada jam NN), aturan hour (deadline − N jam), dan semua jalur "null"
/// (hapus seminar tidak membuat reminder minus / alarm basi).
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/core/notifications/reminder_scheduler.dart';

DateTime _d(int y, int m, int day) => DateTime(y, m, day, 10, 30);

void main() {
  group('computeSchedule — aturan mode HARI', () {
    final now = _d(2026, 11, 3); // Selasa 3 Nov 10:30

    test('deadline H-2 jam 08:00 → mundur 2 hari jam 08:00', () {
      final at = computeSchedule(
        deadline: _d(2026, 11, 10),
        isDone: false,
        rule: const RemRule(unit: RemUnit.day, n: 2, hour: 8),
        now: now,
      );
      expect(at, DateTime(2026, 11, 8, 8));
    });

    test('deadline hari-H → tidak ada reminder minus (null)', () {
      final at = computeSchedule(
        deadline: _d(2026, 11, 3),
        isDone: false,
        rule: const RemRule(unit: RemUnit.day, n: 1, hour: 8),
        now: now,
      );
      expect(at, isNull);
    });

    test('momen jadwal sudah lewat (deadline dekat) → null', () {
      final at = computeSchedule(
        deadline: _d(2026, 11, 4), // H-1 jam 08 = 3 Nov 08:00 < now 10:30
        isDone: false,
        rule: const RemRule(unit: RemUnit.day, n: 1, hour: 8),
        now: now,
      );
      expect(at, isNull);
    });

    test('tugas selesai → null (tidak pernah diberi alarm)', () {
      final at = computeSchedule(
        deadline: _d(2026, 12, 24),
        isDone: true,
        rule: const RemRule(unit: RemUnit.day, n: 2, hour: 20),
        now: now,
      );
      expect(at, isNull);
    });

    test('deadline kosong → null', () {
      final at = computeSchedule(
        deadline: null,
        isDone: false,
        rule: const RemRule(unit: RemUnit.day, n: 2, hour: 8),
        now: now,
      );
      expect(at, isNull);
    });

    test('langit-rel kecil menempel perubahan jadwal sederhana', () {
      final at = computeSchedule(
        deadline: DateTime(2026, 12, 1, 0, 5), // deadline beda jam
        isDone: false,
        rule: const RemRule(unit: RemUnit.day, n: 3, hour: 22),
        now: now,
      );
      expect(at, DateTime(2026, 11, 28, 22));
    });
  });

  group('computeSchedule — aturan mode JAM (custom user)', () {
    final now = _d(2026, 11, 3); // Selasa 3 Nov 10:30

    test('H-7 jam → deadline 4 Nov 12:00 → 4 Nov 05:00', () {
      final at = computeSchedule(
        deadline: DateTime(2026, 11, 4, 12),
        isDone: false,
        rule: const RemRule(unit: RemUnit.hour, n: 7),
        now: now,
      );
      expect(at, DateTime(2026, 11, 4, 5)); // masih future → jadwal
    });

    test('H-1 jam tapi momen sudah lewat → null', () {
      final at = computeSchedule(
        deadline: DateTime(2026, 11, 3, 11, 30), // −1 jam = 10:30 == now
        isDone: false,
        rule: const RemRule(unit: RemUnit.hour, n: 1),
        now: now,
      );
      expect(at, isNull);
    });

    test('H-24 jam dari deadline Minggu 20:00 → Sabtu 20:00', () {
      final at = computeSchedule(
        deadline: DateTime(2026, 11, 8, 20),
        isDone: false,
        rule: const RemRule(unit: RemUnit.hour, n: 24),
        now: now,
      );
      expect(at, DateTime(2026, 11, 7, 20));
    });

    test('selesai / deadline kosong di mode jam → null', () {
      expect(
        computeSchedule(
          deadline: DateTime(2026, 12, 1, 9),
          isDone: true,
          rule: const RemRule(unit: RemUnit.hour, n: 2),
          now: now,
        ),
        isNull,
      );
      expect(
        computeSchedule(
          deadline: null,
          isDone: false,
          rule: const RemRule(unit: RemUnit.hour, n: 2),
          now: now,
        ),
        isNull,
      );
    });
  });

  group('RemRule serialisasi & label', () {
    test('day mode: round-trip JSON + label H-2 · 08:00', () {
      const r = RemRule(unit: RemUnit.day, n: 2, hour: 8);
      final back = RemRule.fromJson(r.toJson());
      expect(back.unit, RemUnit.day);
      expect(back.n, 2);
      expect(back.hour, 8);
      expect(r.label, 'H-2 · 08:00');
    });

    test('hour mode: round-trip JSON + label H-7 jam', () {
      const r = RemRule(unit: RemUnit.hour, n: 7);
      final back = RemRule.fromJson(r.toJson());
      expect(back.unit, RemUnit.hour);
      expect(back.n, 7);
      expect(back.hour, const RemRule(unit: RemUnit.hour, n: 7).hour);
      expect(r.label, 'H-7 jam');
    });
  });
}
