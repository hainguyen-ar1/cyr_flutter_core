import 'package:cyr_flutter_core/src/config/network_config.dart';
import 'package:cyr_flutter_core/src/di/dependency_registry.dart';
import 'package:cyr_flutter_core/src/network/http_client_factory.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Registers a lazy singleton [Dio] built from [config].
///
/// Retrofit API đăng ký riêng qua [registerRestApi].
void registerHttpClient(
  NetworkConfig config, {
  GetIt? locator,
}) {
  final getIt = locator ?? GetIt.instance;
  registerLazySingletonOverride<Dio>(
    () => HttpClientFactory.create(config),
    locator: getIt,
  );
}
