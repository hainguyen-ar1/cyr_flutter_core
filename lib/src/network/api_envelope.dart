import 'package:cyr_flutter_core/src/network/api_response.dart';
import 'package:cyr_flutter_core/src/network/interceptors/api_envelope_interceptor.dart';
import 'package:dio/dio.dart';

/// Đọc envelope đầy đủ từ [Response] sau [ApiEnvelopeInterceptor].
abstract final class ApiEnvelope {
  /// Envelope đầy đủ (meta, requestId, …) khi cần sau khi payload đã unwrap.
  static ApiResponse<T>? fromResponse<T>(Response<dynamic> response) {
    final raw = response.extra[ApiEnvelopeInterceptor.envelopeExtraKey];
    if (raw is ApiResponse<T>) return raw;
    if (raw is ApiResponse) return raw as ApiResponse<T>;
    return null;
  }
}
