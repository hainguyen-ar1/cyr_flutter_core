import 'package:dio/dio.dart';

/// Merges headers from [headerProvider] into each outgoing request.
class DynamicHeaderInterceptor extends Interceptor {
  DynamicHeaderInterceptor({required this.headerProvider});

  final Future<Map<String, String>> Function() headerProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final headers = await headerProvider();
    options.headers.addAll(headers);
    handler.next(options);
  }
}
