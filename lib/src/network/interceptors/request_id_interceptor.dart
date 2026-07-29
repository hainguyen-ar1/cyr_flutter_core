import 'dart:math';

import 'package:dio/dio.dart';

/// Gắn `X-Request-Id` cho mọi request — khớp `RequestIdMiddleware` backend.
class RequestIdInterceptor extends Interceptor {
  const RequestIdInterceptor({this.requestIdProvider});

  /// Trả ID tùy chỉnh; mặc định sinh `req_<16 hex>`.
  final String Function()? requestIdProvider;

  static const headerName = 'X-Request-Id';
  static const extraKey = 'request_id';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = requestIdProvider?.call() ?? generateRequestId();
    options.headers[headerName] = id;
    options.extra[extraKey] = id;
    handler.next(options);
  }

  /// Format: `req_` + 16 ký tự hex (giống backend `randomUUID` rút gọn).
  static String generateRequestId() {
    final random = Random.secure();
    final buffer = StringBuffer('req_');
    for (var i = 0; i < 8; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
