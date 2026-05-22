import 'package:flutter/material.dart';

/// UI strings and styling used by shared presentation helpers.
class PresentationConfig {
  const PresentationConfig({
    this.errorDialogTitle = 'Error',
    this.errorDialogCloseLabel = 'Close',
    this.primaryColor,
    this.connectionErrorMessage = 'Connection error. Please try again.',
    this.unknownErrorMessage = 'An unknown error occurred.',
  });

  final String errorDialogTitle;
  final String errorDialogCloseLabel;
  final Color? primaryColor;
  final String connectionErrorMessage;
  final String unknownErrorMessage;
}
