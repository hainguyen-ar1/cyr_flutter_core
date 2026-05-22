import 'package:cyr_flutter_core/src/config/network_config.dart';
import 'package:cyr_flutter_core/src/di/dependency_registry.dart';
import 'package:cyr_flutter_core/src/network/api_client.dart';
import 'package:cyr_flutter_core/src/network/http_client_factory.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Registers a lazy singleton [Dio] built from [config].
void registerHttpClient(
  NetworkConfig config, {
  GetIt? locator,
  bool registerApiClient = true,
}) {
  final getIt = locator ?? GetIt.instance;
  registerLazySingletonOverride<Dio>(
    () => HttpClientFactory.create(config),
    locator: getIt,
  );
  if (registerApiClient) {
    registerLazySingletonOverride<ApiClient>(
      () => ApiClient(getIt<Dio>()),
      locator: getIt,
    );
  }
}
