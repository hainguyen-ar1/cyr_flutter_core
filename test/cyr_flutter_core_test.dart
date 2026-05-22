import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  tearDown(() async {
    await AppCore.reset();
  });

  group('AppCore', () {
    test('throws when config accessed before initialize', () {
      expect(() => AppCore.config, throwsStateError);
    });

    test('initialize exposes config', () {
      const config = CoreConfig(
        network: NetworkConfig(baseUrl: 'https://example.com/'),
      );
      AppCore.initialize(config);
      expect(AppCore.config.network.baseUrl, 'https://example.com/');
    });
  });

  group('HttpClientFactory', () {
    test('creates Dio with baseUrl and headers', () {
      const networkConfig = NetworkConfig(
        baseUrl: 'https://api.test/',
        defaultHeaders: {'X-Custom': '1'},
        enableLogging: false,
      );
      final dio = HttpClientFactory.create(networkConfig);
      expect(dio.options.baseUrl, 'https://api.test/');
      expect(dio.options.headers['X-Custom'], '1');
      expect(
        dio.interceptors.any((i) => i.runtimeType.toString().contains('Logging')),
        isFalse,
      );
    });
  });

  group('DefaultNetworkErrorMapper', () {
    test('maps ApiError message', () {
      final mapper = DefaultNetworkErrorMapper();
      const error = ApiError(message: 'Invalid input');
      expect(mapper.map(error), 'Invalid input');
    });

    test('maps DioException with response body', () {
      final mapper = DefaultNetworkErrorMapper(
        presentation: const PresentationConfig(),
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {'message': 'Not found'},
          statusCode: 404,
        ),
      );
      expect(mapper.map(error), 'Not found');
    });
  });

  group('ApiError', () {
    test('fromJson supports snake_case and camelCase', () {
      final fromSnake = ApiError.fromJson({
        'status_code': 400,
        'message': 'Bad',
      });
      expect(fromSnake.statusCode, 400);
      expect(fromSnake.message, 'Bad');

      final fromCamel = ApiError.fromJson({
        'statusCode': 401,
        'error': 'Unauthorized',
      });
      expect(fromCamel.statusCode, 401);
      expect(fromCamel.message, 'Unauthorized');
    });
  });

  group('dependency registry', () {
    test('registerFactoryOverride replaces registration', () {
      final locator = GetIt.asNewInstance();
      registerFactoryOverride<String>(() => 'first', locator: locator);
      expect(locator<String>(), 'first');
      registerFactoryOverride<String>(() => 'second', locator: locator);
      expect(locator<String>(), 'second');
      locator.reset();
    });
  });

  group('AppResult', () {
    test('extensions expose value and error', () {
      const success = AppSuccess<int>(42);
      final failure = AppFailure<int>(const ApiError(message: 'fail'));

      expect(success.valueOrNull, 42);
      expect(success.isSuccess, isTrue);
      expect(failure.errorOrNull?.message, 'fail');
      expect(failure.isFailure, isTrue);
    });
  });
}
