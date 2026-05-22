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
      const error = ApiError(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Invalid input',
      );
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
    test('fromJson parses full envelope', () {
      final err = ApiError.fromJson({
        'success': false,
        'statusCode': 400,
        'code': 'VALIDATION_ERROR',
        'message': 'Dữ liệu không hợp lệ',
        'data': null,
        'errors': [
          {'field': 'email', 'message': 'invalid'},
        ],
        'meta': null,
        'requestId': 'req_x',
        'path': '/api/x',
        'timestamp': '2026-05-22T16:21:01.289Z',
      });
      expect(err.statusCode, 400);
      expect(err.code, 'VALIDATION_ERROR');
      expect(err.errors?.single.field, 'email');
    });

    test('fromJson supports legacy shapes', () {
      final legacy = ApiError.fromJson({
        'status_code': 400,
        'message': 'Bad',
      });
      expect(legacy.statusCode, 400);
      expect(legacy.message, 'Bad');
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
      final failure = AppFailure<int>(
        const ApiError(statusCode: 500, code: 'INTERNAL_ERROR', message: 'fail'),
      );

      expect(success.valueOrNull, 42);
      expect(success.isSuccess, isTrue);
      expect(failure.errorOrNull?.message, 'fail');
      expect(failure.isFailure, isTrue);
    });
  });
}
