import 'package:cyr_flutter_core/src/network/api_response.dart';
import 'package:cyr_flutter_core/src/network/interceptors/api_envelope_interceptor.dart';
import 'package:dio/dio.dart';

/// Thin REST client trên [Dio] — `data` đã unwrap khỏi envelope.
///
/// Cần `meta` / `requestId` từ response gốc → [envelopeFrom].
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parse(response.data, fromJson);
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.post<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parse(response.data, fromJson);
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.put<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parse(response.data, fromJson);
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.patch<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parse(response.data, fromJson);
  }

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.delete<Object?>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parse(response.data, fromJson);
  }

  /// Raw [Dio] (refresh token, upload, v.v.).
  Dio get dio => _dio;

  /// Envelope đầy đủ sau khi [ApiEnvelopeInterceptor] xử lý.
  static ApiResponse<T>? envelopeFrom<T>(Response<dynamic> response) {
    final raw = response.extra[ApiEnvelopeInterceptor.envelopeExtraKey];
    if (raw is ApiResponse<T>) return raw;
    if (raw is ApiResponse) return raw as ApiResponse<T>;
    return null;
  }

  T _parse<T>(Object? data, T Function(Object? json)? fromJson) {
    if (fromJson != null) {
      return fromJson(data);
    }
    return data as T;
  }
}
