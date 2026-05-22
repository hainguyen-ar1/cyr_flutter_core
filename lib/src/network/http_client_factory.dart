import 'package:cyr_flutter_core/src/config/network_config.dart';
import 'package:cyr_flutter_core/src/network/interceptors/api_envelope_interceptor.dart';
import 'package:cyr_flutter_core/src/network/interceptors/dynamic_header_interceptor.dart';
import 'package:cyr_flutter_core/src/network/interceptors/logging_interceptor.dart';
import 'package:cyr_flutter_core/src/network/interceptors/request_id_interceptor.dart';
import 'package:dio/dio.dart';

/// Creates a pre-configured [Dio] instance from [NetworkConfig].
abstract final class HttpClientFactory {
  static Dio create(NetworkConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: Map<String, String>.from(config.defaultHeaders),
      ),
    );

    final interceptors = <Interceptor>[];

    if (config.enableRequestId) {
      interceptors.add(
        RequestIdInterceptor(requestIdProvider: config.requestIdProvider),
      );
    }

    if (config.headerProvider != null) {
      interceptors.add(
        DynamicHeaderInterceptor(headerProvider: config.headerProvider!),
      );
    }

    if (config.unwrapEnvelope) {
      interceptors.add(const ApiEnvelopeInterceptor());
    }

    if (config.enableLogging) {
      interceptors.add(const LoggingInterceptor());
    }

    interceptors.addAll(config.extraInterceptors);
    dio.interceptors.addAll(interceptors);

    return dio;
  }
}
