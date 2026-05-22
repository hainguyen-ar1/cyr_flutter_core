import 'package:get_it/get_it.dart';

/// Hook for host apps to register manual DI overrides after code generation.
abstract interface class DependencyOverrideModule {
  void register(GetIt locator);
}
