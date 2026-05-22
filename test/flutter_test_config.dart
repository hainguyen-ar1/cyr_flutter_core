import 'dart:async';

import 'helpers/test_logger.dart';

/// Reset bộ đếm trước mỗi file test.
/// Banner/summary: gọi [configureTestLogging] trong `main()`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestLogger.resetCounters();
  await testMain();
}
