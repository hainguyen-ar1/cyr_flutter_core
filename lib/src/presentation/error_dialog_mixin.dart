import 'dart:async';

import 'package:cyr_flutter_core/src/app_core.dart';
import 'package:cyr_flutter_core/src/config/presentation_config.dart';
import 'package:flutter/material.dart';

/// Subscribes to an error [Stream] and shows a configurable dialog.
mixin ErrorDialogMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<String>? _errorSubscription;

  PresentationConfig get presentationConfig => AppCore.isInitialized
      ? AppCore.config.presentation
      : const PresentationConfig();

  void listenErrors(Stream<String> stream) {
    _errorSubscription?.cancel();
    _errorSubscription = stream.listen(_showErrorDialog);
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    final config = presentationConfig;
    final primary =
        config.primaryColor ?? Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                config.errorDialogTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(config.errorDialogCloseLabel),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }
}
