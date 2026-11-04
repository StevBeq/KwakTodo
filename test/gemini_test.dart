import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/core/ai/ai_result.dart';
import 'package:todo_list/core/ai/key_rotator.dart';
import 'package:todo_list/core/ai/task_draft_json.dart';
import 'package:todo_list/core/domain/models.dart';

void main() {
  group('tasksFromJson — SCHEMA.md §8 (declining enum, title wajib)', () {
    test('normal full', () {
      final t = tasksFromJson(const {
        'tasks': [
          {
            'title': 'Kumpulin Laporan',
            'deadline': '2026-10-30T10:00:00',
            'priority': 'high',
            'category': 'akademik',
            'notes': 'chapter 3',
          },
        ],
      });
      expect(t, hasLength(1));
      expect(t.single.title, 'Kumpulin Laporan');
      expect(t.single.deadline, DateTime(2026, 10, 30, 10).toLocal());
      expect(t.single.priority, Priority.high);
      expect(t.single.category, Category.akademik);
      expect(t.single.notes, 'chapter 3');
    });

    test('value di luar enum → null (jangan crash; fallback di form)', () {
      final t = tasksFromJson(const {
        'tasks': [
          {'title': 'Rapat', 'priority': 'sedang-bgt', 'category': 'sekolah'},
        ],
      });
      expect(t.single.priority, isNull);
      expect(t.single.category, isNull);
      expect(t.single.deadline, isNull);
      expect(t.single.notes, isNull);
    });

    test('title kosong di-skip — tidak pernah draft null-title', () {
      final t = tasksFromJson(const {
        'tasks': [
          {'title': '  '},
          {'title': 'Asli', 'priority': 'low'},
        ],
      });
      expect(t, hasLength(1));
      expect(t.single.title, 'Asli');
      expect(t.single.priority, Priority.low);
    });

    test('deadline tak valid → null; tasks bukan list → kosong', () {
      expect(tasksFromJson(const {'tasks': []}), isEmpty);
      final t = tasksFromJson(const {
        'tasks': [
          {'title': 'X', 'deadline': 'besok-sore'},
        ],
      });
      expect(t.single.deadline, isNull);
      expect([
        tasksFromJson({}),
        tasksFromJson(const {'tasks': 'buang'}),
      ], everyElement(isEmpty));
    });
  });

  group('KeyRotator — FR-10 (429 → key berikutnya, semua habis → quota)', () {
    final perm = const AppError(kind: AppErrorKind.permission, message: 'x');

    test('tanpa key → permission (suruh isi key di Pengaturan)', () async {
      final r = await KeyRotator(() => const []).run((_) async => Result.ok(1));
      expect(
        r,
        isA<ErrResult<int>>().having(
          (e) => e.error.kind,
          'kind',
          AppErrorKind.permission,
        ),
      );
    });

    test('429 di key 1 → lanjut key 2, sukses', () async {
      final dipakai = <String>[];
      final r = await KeyRotator(() => ['a', 'b']).run((k) async {
        dipakai.add(k);
        if (k == 'a') {
          return Result<String>.err(
            const AppError(kind: AppErrorKind.quota, message: 'limit'),
          );
        }
        return Result.ok('hasil:$k');
      });
      expect(dipakai, ['a', 'b']);
      expect((r as OkResult<String>).value, 'hasil:b');
    });

    test('semua key habis → quota + pesan sarankan manual', () async {
      Future<Result<String>> habis(String k) async => Result<String>.err(
        const AppError(kind: AppErrorKind.quota, message: 'limit'),
      );
      final r = await KeyRotator(() => ['a', 'b']).run(habis);
      final err = (r as ErrResult<String>).error;
      expect(err.kind, AppErrorKind.quota);
      expect(err.message, contains('isi manual'));
    });

    test('error selain quota → tidak rotasi (langsung kembali)', () async {
      final dipakai = <String>[];
      Future<Result<String>> gagal(String k) async {
        dipakai.add(k);
        return Result<String>.err(perm);
      }

      final r = await KeyRotator(() => ['a', 'b']).run(gagal);
      expect(dipakai, ['a']);
      expect(r, isA<ErrResult<String>>());
    });
  });
}
