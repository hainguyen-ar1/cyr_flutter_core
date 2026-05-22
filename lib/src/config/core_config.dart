import 'package:cyr_flutter_core/src/config/network_config.dart';
import 'package:cyr_flutter_core/src/config/presentation_config.dart';

/// Root configuration for [AppCore.initialize].
class CoreConfig {
  const CoreConfig({
    required this.network,
    this.presentation = const PresentationConfig(),
  });

  final NetworkConfig network;
  final PresentationConfig presentation;
}
