import 'package:cyr_flutter_core/src/app_core.dart';
import 'package:cyr_flutter_core/src/config/presentation_config.dart';
import 'package:cyr_flutter_core/src/network/api_error.dart';
import 'package:dio/dio.dart';

/// Maps arbitrary errors into user-facing messages.
abstract interface class NetworkErrorMapper {
  String map(Object error);
}

/// Default mapper that understands [DioException] and [ApiError].
class DefaultNetworkErrorMapper implements NetworkErrorMapper {
  DefaultNetworkErrorMapper({PresentationConfig? presentation})
      : _presentation = presentation ??
            (AppCore.isInitialized
                ? AppCore.config.presentation
                : const PresentationConfig());

  final PresentationConfig _presentation;

  @override
  String map(Object error) {
    if (error is ApiError) {
      return error.message;
    }
    if (error is DioException) {
      return _mapDio(error);
    }
    return error.toString().isNotEmpty
        ? error.toString()
        : _presentation.unknownErrorMessage;
  }

  String _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
    }
    return error.message ?? _presentation.connectionErrorMessage;
  }
}
