import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';

import '../helpers/envelope_fixtures.dart';
import '../helpers/test_logger.dart';

class _SilentException implements Exception {
  @override
  String toString() => '';
}

void main() {
  TestLogger.configureTestLogging(
      suiteLabel: 'network/network_error_mapper_test');

  loggedGroup('DefaultNetworkErrorMapper', () {
    const presentation = PresentationConfig(
      connectionErrorMessage: 'No connection',
      unknownErrorMessage: 'Unknown',
    );
    final mapper = DefaultNetworkErrorMapper(presentation: presentation);

    loggedTest('maps ApiError message', (log) {
      const error = ApiError(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Dữ liệu không hợp lệ',
      );
      expectLogged(log, 'message', mapper.map(error), 'Dữ liệu không hợp lệ');
    });

    loggedTest('maps DioException with ApiError in error field', (log) {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/x'),
        error: const ApiError(
          statusCode: 401,
          code: 'AUTH_UNAUTHORIZED',
          message: 'Cần đăng nhập',
        ),
      );
      expectLogged(log, 'message', mapper.map(dioError), 'Cần đăng nhập');
    });

    loggedTest('maps DioException with envelope message in body', (log) {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          data: errorEnvelope(message: 'Not found resource'),
          statusCode: 404,
        ),
      );
      expectLogged(log, 'message', mapper.map(dioError), 'Not found resource');
    });

    loggedTest('maps DioException with legacy error key', (log) {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          data: {'error': 'Legacy error'},
        ),
      );
      expectLogged(log, 'message', mapper.map(dioError), 'Legacy error');
    });

    loggedTest('uses connectionErrorMessage when Dio has no message', (log) {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      expectLogged(log, 'message', mapper.map(dioError), 'No connection');
    });

    loggedTest('uses unknownErrorMessage when exception has empty toString',
        (log) {
      expectLogged(log, 'message', mapper.map(_SilentException()), 'Unknown');
    });
  });
}
