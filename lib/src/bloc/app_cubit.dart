import 'dart:async';

import 'package:cyr_flutter_core/src/bloc/bloc_guard.dart';
import 'package:cyr_flutter_core/src/network/network_error_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base [Cubit] with the same [guard] contract as [AppBloc].
abstract class AppCubit<S> extends Cubit<S> with BlocGuard {
  AppCubit(
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

  Stream<String> get errorStream => _errorController.stream;

  @override
  Future<void> close() {
    _errorController.close();
    return super.close();
  }
}
