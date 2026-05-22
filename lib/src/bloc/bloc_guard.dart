import 'dart:async';
import 'dart:developer';

import 'package:cyr_flutter_core/src/network/network_error_mapper.dart';

/// Shared async guard with unified error handling for Bloc and Cubit.
mixin BlocGuard {
  NetworkErrorMapper get errorMapper;

  StreamController<String> get errorController;

  /// Executes [action] safely. Emits a user-facing message on failure when
  /// [reportError] is true.
  Future<void> guard(
    Future<void> Function() action, {
    void Function(Object error)? onError,
    bool reportError = true,
  }) async {
    try {
      await action();
    } catch (error, stackTrace) {
      log(
        'Error in $runtimeType: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'BlocGuard',
      );
      onError?.call(error);
      if (reportError && !errorController.isClosed) {
        errorController.add(errorMapper.map(error));
      }
    }
  }
}
