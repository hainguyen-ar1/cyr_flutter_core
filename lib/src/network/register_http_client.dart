import 'package:cyr_flutter_core/src/config/network_config.dart';
import 'package:cyr_flutter_core/src/di/dependency_registry.dart';
import 'package:cyr_flutter_core/src/network/http_client_factory.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Registers a lazy singleton [Dio] built from [config].
void registerHttpClient(
  NetworkConfig config, {
  GetIt? locator,
}) {
  registerLazySingletonOverride<Dio>(
    () => HttpClientFactory.create(config),
    locator: locator,
  );
}
