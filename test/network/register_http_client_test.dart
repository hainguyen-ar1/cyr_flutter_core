import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/register_http_client_test');

  late GetIt locator;

  setUp(() {
    locator = GetIt.asNewInstance();
  });

  tearDown(() async {
    await locator.reset();
  });

  loggedGroup('registerHttpClient', () {
    const config = NetworkConfig(
      baseUrl: 'https://api.test/',
      enableLogging: false,
    );

    loggedTest('registers Dio lazy singleton', (log) {
      log.step('Act', 'registerHttpClient');
      registerHttpClient(config, locator: locator);
      expectLogged(log, 'isRegistered<Dio>', locator.isRegistered<Dio>(), isTrue);
      expectLogged(
        log,
        'baseUrl',
        locator<Dio>().options.baseUrl,
        'https://api.test/',
      );
    });

    loggedTest('registers ApiClient by default', (log) {
      registerHttpClient(config, locator: locator);
      expectLogged(
        log,
        'isRegistered<ApiClient>',
        locator.isRegistered<ApiClient>(),
        isTrue,
      );
      expectLogged(
        log,
        'same Dio instance',
        locator<ApiClient>().dio,
        same(locator<Dio>()),
      );
    });

    loggedTest('skips ApiClient when registerApiClient is false', (log) {
      registerHttpClient(
        config,
        locator: locator,
        registerApiClient: false,
      );
      expectLogged(log, 'Dio', locator.isRegistered<Dio>(), isTrue);
      expectLogged(log, 'ApiClient', locator.isRegistered<ApiClient>(), isFalse);
    });

    loggedTest('override replaces Dio registration', (log) {
      registerHttpClient(config, locator: locator);
      log.step('Act', 'registerLazySingletonOverride<Dio>');
      registerLazySingletonOverride<Dio>(
        () => Dio(BaseOptions(baseUrl: 'https://override.test/')),
        locator: locator,
      );
      expectLogged(
        log,
        'baseUrl',
        locator<Dio>().options.baseUrl,
        'https://override.test/',
      );
    });
  });
}
