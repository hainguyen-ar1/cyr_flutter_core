import 'package:cyr_flutter_core/src/config/core_config.dart';
import 'package:cyr_flutter_core/src/di/dependency_locator.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

/// Entry point for host apps to bootstrap shared core behavior.
abstract final class AppCore {
  static CoreConfig? _config;

  /// Active configuration. Throws if [initialize] was not called.
  static CoreConfig get config {
    final value = _config;
    if (value == null) {
      throw StateError(
        'AppCore.initialize() must be called before accessing config.',
      );
    }
    return value;
  }

  /// Whether [initialize] has been called.
  static bool get isInitialized => _config != null;

  /// Shared service locator instance.
  static GetIt get locator => DependencyLocator.instance;

  /// Initializes core with [config] and optional [setup] hook for app DI.
  static void initialize(
    CoreConfig config, {
    void Function(GetIt locator)? setup,
  }) {
    _config = config;
    setup?.call(locator);
  }

  /// Resets state — intended for tests.
  @visibleForTesting
  static Future<void> reset() async {
    _config = null;
    await DependencyLocator.reset();
  }
}
