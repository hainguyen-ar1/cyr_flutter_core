/// Structured API error model for repositories and UI layers.
class ApiError implements Exception {
  const ApiError({
    required this.message,
    this.statusCode,
    this.detail,
    this.raw,
  });

  final int? statusCode;
  final String message;
  final String? detail;
  final Object? raw;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['status_code'] as int? ?? json['statusCode'] as int?,
      message: (json['message'] ?? json['error'] ?? 'Unknown error').toString(),
      detail: json['detail'] as String?,
      raw: json,
    );
  }

  @override
  String toString() => 'ApiError($statusCode): $message';
}
