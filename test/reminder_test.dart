/// Unit test ReminderScheduler.generate jadwal H-N — RULES §7:
/// deadline → snapshot momen notif benar; deadline hari-H → tidak buat
/// reminder minus; selesai/deadline kosong → null.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/core/notifications/reminder_scheduler.dart';

DateTime _d(int y, int m, int day) => DateTime(y, m, day, 10, 30);

void main() {
  group('computeSchedule — RULES §7 & SCHEMA §8', () {
    final now = _d(2026, 11, 3); // SELASA 3 NOV 10:30

    test('deadline H-2 jam 08:00 → mundur 2 hari jam 08:00', () {
      final at = computeSchedule(
        deadline: _d(2026, 11, 10),
        isDone: false,
        leadDays: 2,
        hour: 8,
        now: now,
      );
      expect(at, DateTime(2026, 11, 8, 8));
    });

    test('deadline hari-H → tidak ada reminder minus (null)', () {
      final at = computeSchedule(
        deadline: _d(2026, 11, 4),
        isDone: false,
        leadDays: 2,
        hour: 8,
        now: now,
      );
      expect(at, isNull);
    });

    test('momen jadwal sudah lewat (deadline dekat) → null', () {
      final at = computeSchedule(
        deadline: _d(2026, 11, 4), // H-1 jam 08 = 2 NOV 08:00 < now
        isDone: false,
        leadDays: 1,
        hour: 8,
        now: now,
      );
      expect(at, isNull);
    });

    test('tugas selesai → null (tidak pernah diberi alarm)', () {
      final at = computeSchedule(
        deadline: _d(2026, 12, 24),
        isDone: true,
        leadDays: 2,
        hour: 8,
        now: now,
      );
      expect(at, isNull);
    });

    test('deadline kosong → null', () {
      final at = computeSchedule(
        deadline: null,
        isDone: false,
        leadDays: 2,
        hour: 8,
        now: now,
      );
      expect(at, isNull);
    });

    test(
      'jam 22:00 diikuti agar memotong hari yang sama pas deadline hari',
      () {
        final at = computeSchedule(
          deadline: DateTime(2026, 12, 1, 0, 5), // dead date beda jam
          isDone: false,
          leadDays: 3,
          hour: 22,
          now: now,
        );
        expect(at, DateTime(2026, 11, 28, 22));
      },
    );
  });
}
