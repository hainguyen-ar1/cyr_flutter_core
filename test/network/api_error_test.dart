import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/envelope_fixtures.dart';
import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/api_error_test');

  loggedGroup('ApiError', () {
    loggedTest('fromEnvelope copies all fields', (log) {
      log.step('Arrange', '409 AUTH_EMAIL_EXISTS envelope');
      final err = ApiError.fromEnvelope(
        ApiResponse<dynamic>.fromJson(
          errorEnvelope(
            statusCode: 409,
            code: 'AUTH_EMAIL_EXISTS',
            message: 'Email đã tồn tại',
            errors: [
              {'field': 'email', 'message': 'exists'},
            ],
            requestId: 'req_abc',
            path: '/api/auth/register',
          ),
        ),
      );
      expectLogged(log, 'statusCode', err.statusCode, 409);
      expectLogged(log, 'code', err.code, 'AUTH_EMAIL_EXISTS');
      expectLogged(log, 'apiCode', err.apiCode, ApiCode.authEmailExists);
      expectLogged(log, 'requestId', err.requestId, 'req_abc');
    });

    loggedTest('fromJson parses envelope body', (log) {
      final err = ApiError.fromJson(errorEnvelope());
      expectLogged(log, 'isValidationError', err.isValidationError, isTrue);
      expectLogged(log, 'statusCode', err.statusCode, 400);
    });

    loggedTest('fromJson supports legacy snake_case', (log) {
      final err = ApiError.fromJson({
        'status_code': 503,
        'message': 'Unavailable',
      });
      expectLogged(log, 'statusCode', err.statusCode, 503);
      expectLogged(log, 'code', err.code, ClientApiCode.networkError);
    });

    loggedTest('fromDioException parses envelope in response', (log) {
      log.step('Arrange', 'DioException + 403 FORBIDDEN body');
      final exception = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 403,
          data: errorEnvelope(
            statusCode: 403,
            code: 'FORBIDDEN',
            message: 'Không có quyền',
          ),
        ),
      );
      final err = ApiError.fromDioException(exception);
      expectLogged(log, 'code', err.code, 'FORBIDDEN');
      expectLogged(log, 'apiCode', err.apiCode, ApiCode.forbidden);
    });

    loggedTest('fromDioException returns network error without body', (log) {
      final err = ApiError.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          message: 'Connection failed',
        ),
      );
      expectLogged(log, 'isNetworkError', err.isNetworkError, isTrue);
      expectLogged(log, 'statusCode', err.statusCode, 0);
    });

    loggedTest('fieldMessages maps errors by field', (log) {
      const err = ApiError(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Invalid',
        errors: [
          FieldError(field: 'email', message: 'bad email'),
          FieldError(field: 'password', message: 'bad password'),
        ],
      );
      expectLogged(log, 'fieldMessages', err.fieldMessages.length, 2);
      log.kv('email', err.fieldMessages['email']);
    });

    loggedTest('fieldMessages is empty when errors is null', (log) {
      const err = ApiError(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Server error',
      );
      expectLogged(log, 'fieldMessages', err.fieldMessages, isEmpty);
    });

    loggedTest('toString includes statusCode and code', (log) {
      const err = ApiError(
        statusCode: 401,
        code: 'AUTH_UNAUTHORIZED',
        message: 'Unauthorized',
      );
      expectLogged(
        log,
        'toString',
        err.toString(),
        'ApiError(401, AUTH_UNAUTHORIZED): Unauthorized',
      );
    });
  });
}
