import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../helpers/sample_rest_api.dart';
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

    loggedTest('registerRestApi registers lazy singleton', (log) {
      registerHttpClient(config, locator: locator);
      registerRestApi<SampleRestApi>(SampleRestApi.new, locator: locator);
      expectLogged(
        log,
        'isRegistered<SampleRestApi>',
        locator.isRegistered<SampleRestApi>(),
        isTrue,
      );
      expectLogged(
        log,
        'same instance on second resolve',
        locator<SampleRestApi>(),
        same(locator<SampleRestApi>()),
      );
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
