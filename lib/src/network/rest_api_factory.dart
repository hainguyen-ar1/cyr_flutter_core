import 'package:cyr_flutter_core/src/di/dependency_registry.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Tạo và đăng ký Retrofit service trên [Dio] đã cấu hình envelope.
abstract final class RestApiFactory {
  /// `AuthApi(dio)` — payload đã unwrap bởi [ApiEnvelopeInterceptor].
  static T create<T extends Object>(Dio dio, T Function(Dio dio) builder) =>
      builder(dio);
}

/// Đăng ký lazy singleton Retrofit API (`AuthApi`, `ProfileApi`, …).
void registerRestApi<T extends Object>(
  T Function(Dio dio) factory, {
  GetIt? locator,
}) {
  final getIt = locator ?? GetIt.instance;
  registerLazySingletonOverride<T>(
    () => factory(getIt<Dio>()),
    locator: getIt,
  );
}
