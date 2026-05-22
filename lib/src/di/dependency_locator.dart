import 'package:get_it/get_it.dart';

/// Thin wrapper around [GetIt] for shared access patterns.
abstract final class DependencyLocator {
  static final GetIt _instance = GetIt.instance;

  static GetIt get instance => _instance;

  /// Clears all registrations — intended for tests.
  static Future<void> reset() => _instance.reset();
}
