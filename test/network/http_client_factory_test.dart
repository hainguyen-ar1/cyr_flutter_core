import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/http_client_factory_test');

  loggedGroup('HttpClientFactory', () {
    loggedTest('creates Dio with baseUrl and default headers', (log) {
      log.step('Arrange', 'NetworkConfig + X-App header');
      const config = NetworkConfig(
        baseUrl: 'https://api.test/',
        defaultHeaders: {'X-App': 'flutter'},
        enableLogging: false,
      );
      final dio = HttpClientFactory.create(config);
      expectLogged(log, 'baseUrl', dio.options.baseUrl, 'https://api.test/');
      expectLogged(log, 'X-App', dio.options.headers['X-App'], 'flutter');
    });

    loggedTest('includes RequestIdInterceptor by default', (log) {
      final dio = HttpClientFactory.create(
        const NetworkConfig(
          baseUrl: 'https://api.test/',
          enableLogging: false,
        ),
      );
      expectLogged(
        log,
        'RequestIdInterceptor',
        dio.interceptors.whereType<RequestIdInterceptor>().isNotEmpty,
        isTrue,
      );
    });

    loggedTest('includes ApiEnvelopeInterceptor by default', (log) {
      final dio = HttpClientFactory.create(
        const NetworkConfig(
          baseUrl: 'https://api.test/',
          enableLogging: false,
        ),
      );
      expectLogged(
        log,
        'ApiEnvelopeInterceptor',
        dio.interceptors.whereType<ApiEnvelopeInterceptor>().isNotEmpty,
        isTrue,
      );
    });

    loggedTest('omits RequestIdInterceptor when disabled', (log) {
      final dio = HttpClientFactory.create(
        const NetworkConfig(
          baseUrl: 'https://api.test/',
          enableLogging: false,
          enableRequestId: false,
        ),
      );
      expectLogged(
        log,
        'count',
        dio.interceptors.whereType<RequestIdInterceptor>().length,
        0,
      );
    });

    loggedTest('omits ApiEnvelopeInterceptor when unwrapEnvelope is false', (log) {
      final dio = HttpClientFactory.create(
        const NetworkConfig(
          baseUrl: 'https://api.test/',
          enableLogging: false,
          unwrapEnvelope: false,
        ),
      );
      expectLogged(
        log,
        'count',
        dio.interceptors.whereType<ApiEnvelopeInterceptor>().length,
        0,
      );
    });

    loggedTest('adds LoggingInterceptor when enabled', (log) {
      final dio = HttpClientFactory.create(
        const NetworkConfig(
          baseUrl: 'https://api.test/',
          enableLogging: true,
        ),
      );
      expectLogged(
        log,
        'LoggingInterceptor',
        dio.interceptors.any(
          (i) => i.runtimeType.toString().contains('Logging'),
        ),
        isTrue,
      );
    });
  });
}
