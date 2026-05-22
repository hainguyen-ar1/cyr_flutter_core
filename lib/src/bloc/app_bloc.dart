import 'dart:async';

import 'package:cyr_flutter_core/src/bloc/bloc_event.dart';
import 'package:cyr_flutter_core/src/bloc/bloc_guard.dart';
import 'package:cyr_flutter_core/src/network/network_error_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base [Bloc] with [guard] error handling and [errorStream] for UI layers.
abstract class AppBloc<E extends BlocEvent, S> extends Bloc<E, S>
    with BlocGuard {
  AppBloc(
    super.initialState, {
    NetworkErrorMapper? errorMapper,
  }) : _errorMapper = errorMapper ?? DefaultNetworkErrorMapper() {
    _errorController = StreamController<String>.broadcast();
  }

  late final StreamController<String> _errorController;
  late final NetworkErrorMapper _errorMapper;

  @override
  NetworkErrorMapper get errorMapper => _errorMapper;

  @override
  StreamController<String> get errorController => _errorController;

  /// User-facing error messages for dialogs or snackbars.
  Stream<String> get errorStream => _errorController.stream;

  @override
  Future<void> close() {
    _errorController.close();
    return super.close();
  }
}
