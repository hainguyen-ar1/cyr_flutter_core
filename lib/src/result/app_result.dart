import 'package:cyr_flutter_core/src/network/api_error.dart';

/// Discriminated result for repository and use-case layers.
sealed class AppResult<T> {
  const AppResult();
}

final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.value);

  final T value;
}

final class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.error);

  final ApiError error;
}

extension AppResultX<T> on AppResult<T> {
  bool get isSuccess => this is AppSuccess<T>;
  bool get isFailure => this is AppFailure<T>;

  T? get valueOrNull => switch (this) {
        AppSuccess(:final value) => value,
        _ => null,
      };

  ApiError? get errorOrNull => switch (this) {
        AppFailure(:final error) => error,
        _ => null,
      };

  /// Unwrap thành công → trả `T`.
  /// Thất bại → gọi [onFailure] (nếu có) rồi tự động throw [ApiError].
  ///
  /// Dùng trong `guard()` của Bloc: lỗi bị bắt tự động → `errorStream` → dialog.
  ///
  /// ```dart
  /// // Tự động hoàn toàn — không cần viết thêm gì:
  /// final data = (await _repo.fetch()).orThrow();
  ///
  /// // Emit failure state trước khi throw:
  /// final data = (await _repo.fetch())
  ///     .orThrow((_) => emit(state.copyWith(status: Status.failure)));
  ///
  /// // Xử lý theo loại lỗi (không throw = không dialog):
  /// final data = (await _repo.login(...)).orThrow((err) {
  ///   if (err.isValidationError) {
  ///     emit(state.copyWith(emailError: err.fieldMessages['email']));
  ///   } else {
  ///     emit(state.copyWith(status: Status.failure));
  ///     throw err;
  ///   }
  /// });
  /// ```
  T orThrow([void Function(ApiError error)? onFailure]) => switch (this) {
        AppSuccess(:final value) => value,
        AppFailure(:final error) => _throwWith(error, onFailure),
      };
}

Never _throwWith<T>(ApiError error, void Function(ApiError)? onFailure) {
  onFailure?.call(error);
  throw error;
}
