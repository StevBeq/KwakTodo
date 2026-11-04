library;

/// Kontrak Result internal — ARCHITECTURE.md §5: semua service memakai
/// bentuk sama `Ok(T)` | `Err(AppError)`; message siap tampil di UI (id-ID).
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) => OkResult(value);

  factory Result.err(AppError error) => ErrResult(error);

  /// Ekstra: value bila Ok, null bila Err (dipakai UI yang hanya salah
  /// tampilkan toast).
  T? get okOrNull;
}

class OkResult<T> extends Result<T> {
  const OkResult(this.value);

  final T value;

  @override
  T? get okOrNull => value;

  @override
  String toString() => 'Ok($value)';
}

class ErrResult<T> extends Result<T> {
  const ErrResult(this.error);

  final AppError error;

  @override
  T? get okOrNull => null;

  @override
  String toString() => 'Err($error)';
}

enum AppErrorKind { network, quota, parse, permission, notFound }

class AppError {
  const AppError({required this.kind, required this.message, this.cause});

  final AppErrorKind kind;
  final String message; // id-ID utk UI
  final Object? cause;
}
