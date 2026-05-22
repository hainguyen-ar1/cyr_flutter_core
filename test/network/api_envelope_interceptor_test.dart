import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/envelope_fixtures.dart';
import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/api_envelope_interceptor_test');

  loggedGroup('ApiEnvelopeInterceptor', () {
    loggedTest('unwraps data on success', (log) async {
      final dio = createMockDio(
        body: successEnvelope(data: {'token': 'abc'}),
        log: log,
      );
      log.step('Act', 'GET /auth/me');
      final response = await dio.get<Map<String, dynamic>>('/auth/me');
      expectLogged(log, 'token', response.data?['token'], 'abc');
    });

    loggedTest('stores envelope in response.extra', (log) async {
      final dio = createMockDio(
        body: successEnvelope(
          data: {'id': 1},
          meta: {'total': 10},
          requestId: 'req_meta',
        ),
        log: log,
      );
      final response = await dio.get('/items');
      final envelope = ApiClient.envelopeFrom(response);
      expectLogged(log, 'meta.total', envelope?.meta?['total'], 10);
      expectLogged(log, 'requestId', envelope?.requestId, 'req_meta');
    });

    loggedTest('rejects when success is false', (log) async {
      final dio = createMockDio(
        statusCode: 401,
        body: errorEnvelope(
          statusCode: 401,
          code: 'AUTH_INVALID_CREDENTIALS',
          message: 'Sai mật khẩu',
        ),
        log: log,
      );
      log.step('Act', 'POST /auth/login (expect reject)');
      await expectLater(
        dio.post('/auth/login'),
        throwsA(
          predicate<DioException>((e) {
            final err = e.error;
            return err is ApiError &&
                err.code == 'AUTH_INVALID_CREDENTIALS';
          }),
        ),
      );
      log.kv('result', 'ApiError attached to DioException');
    });

    loggedTest('rejects validation error with field errors', (log) async {
      final dio = createMockDio(
        statusCode: 400,
        body: errorEnvelope(
          errors: [
            {'field': 'email', 'message': 'invalid'},
          ],
        ),
        log: log,
      );
      try {
        await dio.post('/register');
        fail('expected DioException');
      } on DioException catch (e) {
        final err = e.error! as ApiError;
        expectLogged(log, 'isValidationError', err.isValidationError, isTrue);
        expectLogged(log, 'field', err.errors?.single.field, 'email');
      }
    });

    loggedTest('passes through non-envelope response', (log) async {
      final dio = createMockDio(body: {'legacy': true}, log: log);
      final response = await dio.get('/legacy');
      expectLogged(log, 'body', response.data, {'legacy': true});
      expectLogged(log, 'envelope', ApiClient.envelopeFrom(response), isNull);
    });

    loggedTest('keeps full envelope when unwrapData is false', (log) async {
      final body = successEnvelope(data: {'x': 1});
      log.step('Arrange', 'ApiEnvelopeInterceptor(unwrapData: false)');
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'));
      dio.interceptors.add(const ApiEnvelopeInterceptor(unwrapData: false));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.resolve(
            Response(requestOptions: o, data: body),
            true,
          ),
        ),
      );
      final response = await dio.get('/x');
      expectLogged(
        log,
        'isEnvelope',
        ApiResponse.isEnvelope(response.data),
        isTrue,
      );
    });

    loggedTest('onError wraps envelope from failed HTTP response', (log) async {
      log.step('Arrange', 'reject with 500 INTERNAL_ERROR envelope');
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'));
      dio.interceptors.add(const ApiEnvelopeInterceptor());
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.reject(
            DioException(
              requestOptions: o,
              response: Response(
                requestOptions: o,
                statusCode: 500,
                data: errorEnvelope(
                  statusCode: 500,
                  code: 'INTERNAL_ERROR',
                  message: 'Lỗi máy chủ',
                ),
              ),
              type: DioExceptionType.badResponse,
            ),
            true,
          ),
        ),
      );
      try {
        await dio.get('/boom');
        fail('expected DioException');
      } on DioException catch (e) {
        expectLogged(log, 'code', (e.error as ApiError).code, 'INTERNAL_ERROR');
      }
    });
  });
}
