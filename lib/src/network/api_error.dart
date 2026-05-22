import 'package:cyr_flutter_core/src/network/api_code.dart';
import 'package:cyr_flutter_core/src/network/api_response.dart';
import 'package:cyr_flutter_core/src/network/field_error.dart';
import 'package:dio/dio.dart';

/// Lỗi API đã normalize — tương đương `ApiError` trên Next.js client.
class ApiError implements Exception {
  const ApiError({
    required this.statusCode,
    required this.code,
    required this.message,
    this.errors,
    this.requestId = '',
    this.path = '',
    this.raw,
  });

  final int statusCode;
  final String code;
  final String message;
  final List<FieldError>? errors;
  final String requestId;
  final String path;

  /// JSON envelope gốc (debug).
  final Object? raw;

  ApiCode? get apiCode => ApiCode.tryParse(code);

  bool get isValidationError => code == ApiCode.validationError.value;

  bool get isNetworkError => code == ClientApiCode.networkError;

  factory ApiError.fromEnvelope(ApiResponse<dynamic> envelope) {
    return ApiError(
      statusCode: envelope.statusCode,
      code: envelope.code,
      message: envelope.message,
      errors: envelope.errors,
      requestId: envelope.requestId,
      path: envelope.path,
      raw: envelope,
    );
  }

  factory ApiError.fromJson(Map<String, dynamic> json) {
    if (ApiResponse.isEnvelope(json)) {
      return ApiError.fromEnvelope(ApiResponse<dynamic>.fromJson(json));
    }
    return ApiError(
      statusCode: json['status_code'] as int? ?? json['statusCode'] as int? ?? 0,
      code: json['code'] as String? ??
          json['error'] as String? ??
          ClientApiCode.networkError,
      message: (json['message'] ?? json['error'] ?? 'Unknown error').toString(),
      raw: json,
    );
  }

  factory ApiError.fromDioException(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic> && ApiResponse.isEnvelope(data)) {
      return ApiError.fromEnvelope(ApiResponse<dynamic>.fromJson(data));
    }
    if (data is Map<String, dynamic>) {
      return ApiError.fromJson(data);
    }
    return ApiError(
      statusCode: exception.response?.statusCode ?? 0,
      code: ClientApiCode.networkError,
      message: exception.message ?? 'Có lỗi xảy ra',
    );
  }

  /// Lỗi map theo field (validation). Key `_` = lỗi không gắn field cụ thể.
  Map<String, String> get fieldMessages {
    final map = <String, String>{};
    for (final e in errors ?? const []) {
      map[e.field] = e.message;
    }
    return map;
  }

  @override
  String toString() => 'ApiError($statusCode, $code): $message';
}
