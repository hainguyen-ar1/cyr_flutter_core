import 'dart:async';

import 'package:cyr_flutter_core/src/di/dependency_locator.dart';
import 'package:cyr_flutter_core/src/di/dependency_override_module.dart';
import 'package:get_it/get_it.dart';

typedef ManualDependencyRegistration = void Function(GetIt locator);

/// Registers app dependencies via [manualRegistration] and [overrideModules].
///
/// Code-generated DI (e.g. injectable) should be invoked inside
/// [manualRegistration] by the host application.
void configureDependencies({
  ManualDependencyRegistration? manualRegistration,
  List<DependencyOverrideModule> overrideModules = const [],
  GetIt? locator,
}) {
  final target = locator ?? DependencyLocator.instance;
  manualRegistration?.call(target);
  for (final module in overrideModules) {
    module.register(target);
  }
}

/// Registers or replaces a factory registration.
void registerFactoryOverride<T extends Object>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  GetIt? locator,
}) {
  final target = locator ?? DependencyLocator.instance;
  if (target.isRegistered<T>(instanceName: instanceName)) {
    target.unregister<T>(instanceName: instanceName);
  }
  target.registerFactory<T>(factoryFunc, instanceName: instanceName);
}

/// Registers or replaces a lazy singleton registration.
void registerLazySingletonOverride<T extends Object>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  GetIt? locator,
}) {
  final target = locator ?? DependencyLocator.instance;
  if (target.isRegistered<T>(instanceName: instanceName)) {
    target.unregister<T>(instanceName: instanceName);
  }
  target.registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
}

/// Registers or replaces a singleton instance.
void registerSingletonOverride<T extends Object>(
  T instance, {
  String? instanceName,
  FutureOr<void> Function(T)? dispose,
  GetIt? locator,
}) {
  final target = locator ?? DependencyLocator.instance;
  if (target.isRegistered<T>(instanceName: instanceName)) {
    target.unregister<T>(instanceName: instanceName);
  }
  target.registerSingleton<T>(
    instance,
    instanceName: instanceName,
    dispose: dispose,
  );
}
