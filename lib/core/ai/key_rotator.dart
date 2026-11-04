library;

import 'ai_result.dart';

/// KeyRotator — FR-10 PRD: pakai key berurutan; kena 429 → lanjut key
/// berikutnya; semua habis → Err(quota). Sumber list = provider (fresh
/// tiap call, supaya perubahan key di Pengaturan langsung terpakai).
class KeyRotator {
  const KeyRotator(this._keys);

  final List<String> Function() _keys;

  /// Jalankan [action] dengan key aktif; 429/RESOURCE_EXHAUSTED dari key
  /// bersangkutan → coba key berikutnya.
  Future<Result<T>> run<T>(
    Future<Result<T>> Function(String key) action,
  ) async {
    final keys = _keys().where((k) => k.trim().isNotEmpty).toList();
    if (keys.isEmpty) {
      return Result.err(
        const AppError(
          kind: AppErrorKind.permission,
          message: 'Isi API Key Gemini dulu di Pengaturan.',
        ),
      );
    }
    for (final key in keys) {
      final r = await action(key);
      if (r is! ErrResult<T>) return r;
      if (r.error.kind != AppErrorKind.quota) return r;
    }
    return Result.err(
      const AppError(
        kind: AppErrorKind.quota,
        message:
            'Kuota semua API key habis — tambah key lain, atau isi manual.',
      ),
    );
  }
}
