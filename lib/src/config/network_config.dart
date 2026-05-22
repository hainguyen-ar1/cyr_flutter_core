import 'package:dio/dio.dart';

/// HTTP client configuration supplied by the host application.
class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout,
    this.defaultHeaders = const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    this.headerProvider,
    this.extraInterceptors = const [],
    this.enableLogging = true,
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration? sendTimeout;
  final Map<String, String> defaultHeaders;

  /// Called before each request to merge dynamic headers (e.g. auth token).
  final Future<Map<String, String>> Function()? headerProvider;

  final List<Interceptor> extraInterceptors;
  final bool enableLogging;
}
