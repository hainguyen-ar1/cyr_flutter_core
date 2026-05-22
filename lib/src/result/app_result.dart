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
}
