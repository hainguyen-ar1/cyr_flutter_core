import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';

import 'test_logger.dart';

/// Envelope success mẫu (TransformInterceptor).
Map<String, dynamic> successEnvelope({
  Object? data,
  int statusCode = 200,
  String code = 'OK',
  String message = 'Thành công',
  Map<String, dynamic>? meta,
  String requestId = 'req_test001',
  String path = '/api/test',
}) {
  return {
    'success': true,
    'statusCode': statusCode,
    'code': code,
    'message': message,
    'data': data,
    'errors': null,
    'meta': meta,
    'requestId': requestId,
    'path': path,
    'timestamp': '2026-05-22T16:21:01.289Z',
  };
}

/// Envelope lỗi mẫu (HttpExceptionFilter).
Map<String, dynamic> errorEnvelope({
  int statusCode = 400,
  String code = 'VALIDATION_ERROR',
  String message = 'Dữ liệu không hợp lệ',
  List<Map<String, String>>? errors,
  String requestId = 'req_err001',
  String path = '/api/test',
}) {
  return {
    'success': false,
    'statusCode': statusCode,
    'code': code,
    'message': message,
    'data': null,
    'errors': errors,
    'meta': null,
    'requestId': requestId,
    'path': path,
    'timestamp': '2026-05-22T16:21:01.289Z',
  };
}

/// [Dio] mock trả envelope — dùng `handler.resolve(..., true)` (Dio 5.9+).
Dio createMockDio({
  required Map<String, dynamic> body,
  int statusCode = 200,
  NetworkConfig? config,
  TestLogger? log,
}) {
  log?.step('Mock', 'Dio mock → HTTP $statusCode, code=${body['code']}');
  final networkConfig = config ??
      const NetworkConfig(
        baseUrl: 'https://api.test/',
        enableLogging: false,
        enableRequestId: false,
      );

  return HttpClientFactory.create(
    NetworkConfig(
      baseUrl: networkConfig.baseUrl,
      connectTimeout: networkConfig.connectTimeout,
      receiveTimeout: networkConfig.receiveTimeout,
      sendTimeout: networkConfig.sendTimeout,
      defaultHeaders: networkConfig.defaultHeaders,
      headerProvider: networkConfig.headerProvider,
      requestIdProvider: networkConfig.requestIdProvider,
      enableLogging: networkConfig.enableLogging,
      enableRequestId: networkConfig.enableRequestId,
      unwrapEnvelope: networkConfig.unwrapEnvelope,
      extraInterceptors: [
        ...networkConfig.extraInterceptors,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: statusCode,
                data: body,
              ),
              true,
            );
          },
        ),
      ],
    ),
  );
}
