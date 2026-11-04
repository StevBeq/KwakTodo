/// `Result<T>` + taksonomi error — kontrak ARCHITECTURE.md §5.
/// Semua service publik mengembalikan `Ok`/`Err`, tidak ada throw bocor ke UI.
library;

enum AppErrorKind { network, quota, parse, permission, notFound }

class AppError {
  const AppError(this.kind, this.message, [this.cause]);

  /// PesanBahasa Indonesia siap ditampilkan ke user.
  final String message;
  final AppErrorKind kind;
  final Object? cause;
}

sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}
