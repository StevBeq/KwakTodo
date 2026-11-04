import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/core/domain/models.dart';
import 'package:todo_list/core/utils/filters.dart';
import 'package:todo_list/core/utils/format.dart';

DateTime _utc(int y, int m, int d, [int h = 12, int min = 0]) =>
    DateTime(y, m, d, h, min);

Task _t(
  int id, {
  DateTime? deadline,
  bool done = false,
  Priority priority = Priority.medium,
  Category category = Category.akademik,
}) {
  final now = DateTime(2026, 10, 26, 9);
  return Task(
    id: id,
    title: 'T$id',
    deadline: deadline,
    priority: priority,
    category: category,
    notes: null,
    isDone: done,
    source: TaskSource.manual,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final now = DateTime(2026, 10, 26, 9);

  group('isOverdue — SCHEMA.md §2 (dihitung saat baca)', () {
    test('deadline lewat + belum selesai = true', () {
      final t = _t(1, deadline: _utc(2026, 10, 24, 20));
      expect(t.isOverdue(now), isTrue);
    });
    test('deadline lewat tapi selesai = false (late-done, PRD EC-9)', () {
      final t = _t(2, deadline: _utc(2026, 10, 24), done: true);
      expect(t.isOverdue(now), isFalse);
    });
    test('deadline masa depan = false', () {
      final t = _t(3, deadline: _utc(2026, 10, 30));
      expect(t.isOverdue(now), isFalse);
    });
    test('tanpa deadline = false', () {
      expect(_t(4).isOverdue(now), isFalse);
    });
    test('deadline hari ini yang sudah lewat jam nya = true', () {
      final t = _t(5, deadline: _utc(2026, 10, 26, 7));
      expect(t.isOverdue(now), isTrue);
    });
  });

  group('isToday', () {
    test('deadline hari ini = true termasuk yang sudah lewat', () {
      expect(_t(1, deadline: _utc(2026, 10, 26, 7)).isToday(now), isTrue);
      expect(_t(2, deadline: _utc(2026, 10, 26, 23)).isToday(now), isTrue);
    });
    test('besok/kemarin = false', () {
      expect(_t(3, deadline: _utc(2026, 10, 27)).isToday(now), isFalse);
      expect(_t(4, deadline: _utc(2026, 10, 25)).isToday(now), isFalse);
    });
  });

  group('sameDay — separator kalendernya (Jadwal F2)', () {
    test('tanggal mentah sama & beda', () {
      expect(
        sameDay(DateTime(2026, 10, 26, 23, 59), DateTime(2026, 10, 26, 0)),
        isTrue,
      );
      expect(sameDay(DateTime(2026, 10, 26), DateTime(2026, 10, 27)), isFalse);
    });
    test('pindah bulan & tz', () {
      expect(sameDay(DateTime(2026, 1, 31), DateTime(2026, 2, 1)), isFalse);
      expect(sameDay(DateTime(2026, 12, 30), DateTime(2027, 1, 1)), isFalse);
    });
  });

  group('TaskFilters.forTab — PRD FR-5', () {
    final overdue = _t(1, deadline: _utc(2026, 10, 24));
    final today = _t(2, deadline: _utc(2026, 10, 26, 14));
    final upcoming = _t(3, deadline: _utc(2026, 10, 30));
    final noDl = _t(4);
    final done = _t(5, deadline: _utc(2026, 10, 26, 8), done: true);
    final list = [overdue, today, upcoming, noDl, done];

    test('all → semua task', () {
      expect(TaskFilters.forTab(list, TaskTab.all, now).length, 5);
    });

    test('today → deadline hari ini + overdue (bukan done)', () {
      final res = TaskFilters.forTab(list, TaskTab.today, now);
      expect(res.map((t) => t.id), containsAll([1, 2]));
      expect(res.map((t) => t.id), isNot(contains(5)));
    });

    test('upcoming → deadline masa depan saja', () {
      final res = TaskFilters.forTab(list, TaskTab.upcoming, now);
      expect(res.map((t) => t.id), [3]);
    });

    test('done → hanya selesai', () {
      final res = TaskFilters.forTab(list, TaskTab.done, now);
      expect(res.map((t) => t.id), [5]);
    });
  });

  group('TaskFilters.sortByDeadline — nulls last', () {
    test('dengan deadline dulu, urut naik; tanpa deadline di akhir', () {
      final a = _t(1, deadline: _utc(2026, 10, 30));
      final b = _t(2, deadline: _utc(2026, 10, 26));
      final c = _t(3);
      final sorted = TaskFilters.sortByDeadline([a, c, b]);
      expect(sorted.map((t) => t.id), [2, 1, 3]);
    });
  });

  group('fmtDeadline — DESIGN.md §2 format `30 OKT · 10:00 AM`', () {
    test('pagi AM', () {
      expect(fmtDeadline(_utc(2026, 10, 30, 10, 0)), '30 OKT · 10:00 AM');
    });
    test('malam PM', () {
      expect(fmtDeadline(_utc(2026, 10, 26, 14, 30)), '26 OKT · 02:30 PM');
    });
    test('pukul 12 siang = PM, tidak jadi 00', () {
      expect(fmtDeadline(_utc(2026, 11, 2, 12, 0)), '2 NOV · 12:00 PM');
    });
  });

  group('fmtNotifTime — stempel waktu inbox (prototype renderNotifs)', () {
    final now = DateTime(2026, 10, 28, 9, 15);

    test('hari ini', () {
      expect(
        fmtNotifTime(DateTime(2026, 10, 28, 8, 0), now),
        'Hari ini · 08:00',
      );
    });
    test('kemarin', () {
      expect(
        fmtNotifTime(DateTime(2026, 10, 27, 14, 5), now),
        'Kemarin · 14:05',
      );
    });
    test('silam — tanggal murni, tahun ikut bila beda', () {
      expect(fmtNotifTime(DateTime(2026, 10, 26, 14, 30), now), '26 OKT');
      expect(fmtNotifTime(DateTime(2025, 3, 5, 9, 0), now), '5 MAR 2025');
    });
  });
}
