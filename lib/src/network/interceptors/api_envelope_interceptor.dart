import 'package:cyr_flutter_core/src/network/api_error.dart';
import 'package:cyr_flutter_core/src/network/api_response.dart';
import 'package:dio/dio.dart';

/// Unwrap envelope StrangerConfide: `response.data` → `data`, lỗi → [ApiError].
///
/// Envelope đầy đủ lưu tại [envelopeExtraKey] trên [Response.extra] để đọc
/// `meta`, `requestId`, v.v. khi cần.
class ApiEnvelopeInterceptor extends Interceptor {
  const ApiEnvelopeInterceptor({this.unwrapData = true});

  final bool unwrapData;

  static const envelopeExtraKey = 'api_envelope';

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final body = response.data;
    if (!ApiResponse.isEnvelope(body)) {
      handler.next(response);
      return;
    }

    final map = Map<String, dynamic>.from(body as Map);
    final envelope = ApiResponse<dynamic>.fromJson(map);

    response.extra[envelopeExtraKey] = envelope;

    if (!envelope.success) {
      handler.reject(_reject(response, envelope));
      return;
    }

    if (unwrapData) {
      response.data = envelope.data;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data is Map<String, dynamic> && ApiResponse.isEnvelope(data)) {
      final envelope = ApiResponse<dynamic>.fromJson(data);
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiError.fromEnvelope(envelope),
          message: envelope.message,
        ),
      );
      return;
    }
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiError.fromDioException(err),
        message: err.message,
      ),
    );
  }

  DioException _reject(Response<dynamic> response, ApiResponse<dynamic> envelope) {
    final apiError = ApiError.fromEnvelope(envelope);
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: apiError,
      message: envelope.message,
    );
  }
}
