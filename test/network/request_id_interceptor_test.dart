import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(
      suiteLabel: 'network/request_id_interceptor_test');

  loggedGroup('RequestIdInterceptor', () {
    loggedTest('sets custom X-Request-Id from provider', (log) async {
      log.step('Arrange', 'provider → client-trace-99');
      final dio = Dio();
      String? headerValue;

      dio.interceptors.add(
        RequestIdInterceptor(requestIdProvider: () => 'client-trace-99'),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            headerValue =
                options.headers[RequestIdInterceptor.headerName] as String?;
            expectLogged(
              log,
              'extra request_id',
              options.extra[RequestIdInterceptor.extraKey],
              'client-trace-99',
            );
            handler.resolve(
              Response(requestOptions: options, statusCode: 200),
              true,
            );
          },
        ),
      );

      log.step('Act', 'GET /ping');
      await dio.get('https://api.test/ping');
      expectLogged(log, 'X-Request-Id', headerValue, 'client-trace-99');
    });

    loggedTest('generateRequestId uses req_ prefix and 16 hex chars', (log) {
      final id = RequestIdInterceptor.generateRequestId();
      expectLogged(log, 'prefix', id.startsWith('req_'), isTrue);
      expectLogged(log, 'length', id.length, 20);
      expectLogged(
        log,
        'format',
        RegExp(r'^req_[0-9a-f]{16}$').hasMatch(id),
        isTrue,
      );
    });

    loggedTest('generated ids are unique', (log) {
      log.step('Act', 'generate 50 ids');
      final ids =
          List.generate(50, (_) => RequestIdInterceptor.generateRequestId());
      expectLogged(log, 'unique count', ids.toSet().length, 50);
    });
  });
}
