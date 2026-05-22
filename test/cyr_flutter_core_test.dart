import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'cyr_flutter_core_test');

  tearDown(() async {
    await AppCore.reset();
  });

  loggedGroup('AppCore', () {
    loggedTest('throws when config accessed before initialize', (log) {
      log.step('Act', 'AppCore.config before initialize');
      expectLogged(log, 'throws', () => AppCore.config, throwsStateError);
    });

    loggedTest('initialize exposes config', (log) {
      log.step('Act', 'AppCore.initialize');
      const config = CoreConfig(
        network: NetworkConfig(baseUrl: 'https://example.com/'),
      );
      AppCore.initialize(config);
      expectLogged(
        log,
        'baseUrl',
        AppCore.config.network.baseUrl,
        'https://example.com/',
      );
    });
  });

  loggedGroup('HttpClientFactory', () {
    loggedTest('creates Dio with baseUrl and headers', (log) {
      const networkConfig = NetworkConfig(
        baseUrl: 'https://api.test/',
        defaultHeaders: {'X-Custom': '1'},
        enableLogging: false,
      );
      final dio = HttpClientFactory.create(networkConfig);
      expectLogged(log, 'baseUrl', dio.options.baseUrl, 'https://api.test/');
      expectLogged(log, 'X-Custom', dio.options.headers['X-Custom'], '1');
      expectLogged(
        log,
        'no LoggingInterceptor',
        dio.interceptors.any(
          (i) => i.runtimeType.toString().contains('Logging'),
        ),
        isFalse,
      );
    });
  });

  loggedGroup('dependency registry', () {
    loggedTest('registerFactoryOverride replaces registration', (log) {
      final locator = GetIt.asNewInstance();
      log.step('Act', 'registerFactoryOverride twice');
      registerFactoryOverride<String>(() => 'first', locator: locator);
      expectLogged(log, 'first', locator<String>(), 'first');
      registerFactoryOverride<String>(() => 'second', locator: locator);
      expectLogged(log, 'second', locator<String>(), 'second');
      locator.reset();
    });
  });

  loggedGroup('AppResult', () {
    loggedTest('extensions expose value and error', (log) {
      const success = AppSuccess<int>(42);
      final failure = AppFailure<int>(
        const ApiError(statusCode: 500, code: 'INTERNAL_ERROR', message: 'fail'),
      );
      expectLogged(log, 'valueOrNull', success.valueOrNull, 42);
      expectLogged(log, 'isSuccess', success.isSuccess, isTrue);
      expectLogged(log, 'error message', failure.errorOrNull?.message, 'fail');
      expectLogged(log, 'isFailure', failure.isFailure, isTrue);
    });
  });
}
