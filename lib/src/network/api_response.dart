import 'package:cyr_flutter_core/src/network/field_error.dart';

/// Shape response chuẩn từ StrangerConfide backend (success + error).
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
    required this.errors,
    required this.meta,
    required this.requestId,
    required this.path,
    required this.timestamp,
  });

  final bool success;
  final int statusCode;
  final String code;
  final String message;
  final T? data;
  final List<FieldError>? errors;
  final Map<String, dynamic>? meta;
  final String requestId;
  final String path;
  final String timestamp;

  /// Parses envelope JSON. [fromJsonT] deserializes `data` when present.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(Object? json)? fromJsonT,
  ]) {
    final rawData = json['data'];
    T? data;
    if (fromJsonT != null && rawData != null) {
      data = fromJsonT(rawData);
    } else if (rawData == null) {
      data = null;
    } else {
      data = rawData as T?;
    }

    final rawErrors = json['errors'];
    List<FieldError>? errors;
    if (rawErrors is List) {
      errors = rawErrors
          .whereType<Map>()
          .map((e) => FieldError.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final rawMeta = json['meta'];
    Map<String, dynamic>? meta;
    if (rawMeta is Map) {
      meta = Map<String, dynamic>.from(rawMeta);
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: data,
      errors: errors,
      meta: meta,
      requestId: json['requestId'] as String? ?? '',
      path: json['path'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  /// `true` when body matches StrangerConfide envelope.
  static bool isEnvelope(Object? body) {
    if (body is! Map) return false;
    return body.containsKey('success') &&
        body.containsKey('code') &&
        body.containsKey('message');
  }
}
