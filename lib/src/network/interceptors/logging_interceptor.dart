import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// Logs HTTP responses and errors for debugging.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this.logRequestBody = false});

  final bool logRequestBody;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequestBody && options.data != null) {
      log('→ ${options.method} ${options.uri}\n  Body: ${options.data}', name: 'HTTP');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      '  DATA: ${jsonEncode(response.data)}',
      name: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      '✗ ${err.response?.statusCode ?? 'NO_CODE'} ${err.requestOptions.uri}',
      name: 'HTTP',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
