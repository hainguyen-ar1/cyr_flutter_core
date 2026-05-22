import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Logger có cấu trúc cho unit test — output dễ đọc khi chạy `flutter test`.
///
/// Tắt log: `flutter test --dart-define=SILENT_TESTS=true`
class TestLogger {
  TestLogger(this._testName, {this.group});

  static bool enabled = !const bool.fromEnvironment('SILENT_TESTS');

  static int _passed = 0;
  static int _failed = 0;

  final String _testName;
  final String? group;
  final Stopwatch _sw = Stopwatch();

  void start() {
    if (!enabled) return;
    _sw.start();
    final scope = group != null ? '$group › $_testName' : _testName;
    _print('┌─ TEST: $scope');
  }

  void step(String phase, String message) {
    if (!enabled) return;
    _print('│  [$phase] $message');
  }

  void kv(String key, Object? value) {
    if (!enabled) return;
    _print('│      $key → $value');
  }

  void done() {
    if (!enabled) return;
    _sw.stop();
    _passed++;
    _print('└─ ✓ PASS (${_sw.elapsedMilliseconds}ms)');
    _print('');
  }

  void failed(Object error) {
    if (!enabled) return;
    if (_sw.isRunning) _sw.stop();
    _failed++;
    _print('└─ ✗ FAIL (${_sw.elapsedMilliseconds}ms)');
    _print('│  error: $error');
    _print('');
  }

  static void suiteBanner(String packageName) {
    if (!enabled) return;
    _print('');
    _print('╔════════════════════════════════════════════════════════════╗');
    _print('║  TEST SUITE: $packageName');
    _print('║  Log: bật (tắt: --dart-define=SILENT_TESTS=true)');
    _print('╚════════════════════════════════════════════════════════════╝');
    _print('');
  }

  static void summary(Duration elapsed) {
    if (!enabled) return;
    final total = _passed + _failed;
    _print('╔════════════════════════════════════════════════════════════╗');
    _print('║  SUMMARY');
    _print('║  ✓ passed : $_passed');
    if (_failed > 0) _print('║  ✗ failed : $_failed');
    _print('║  Σ cases  : $total');
    _print('║  ⏱ wall   : ${elapsed.inMilliseconds}ms');
    _print('╚════════════════════════════════════════════════════════════╝');
    _print('');
  }

  static void resetCounters() {
    _passed = 0;
    _failed = 0;
  }

  /// Gọi đầu `main()` — banner file + summary cuối file.
  static void configureTestLogging({String? suiteLabel}) {
    suiteBanner(suiteLabel ?? 'cyr_flutter_core');
    tearDownAll(() => summary(Duration.zero));
  }

  static void _print(String line) {
    // ignore: avoid_print
    print(line);
  }
}

/// `group` có banner đầu/cuối.
void loggedGroup(String name, void Function() body) {
  group(name, () {
    if (TestLogger.enabled) {
      TestLogger._print('╭── GROUP: $name');
    }
    body();
    if (TestLogger.enabled) {
      TestLogger._print('╰── END: $name');
      TestLogger._print('');
    }
  });
}

/// Test case bọc logger — tự log PASS/FAIL.
void loggedTest(
  String description,
  FutureOr<void> Function(TestLogger log) body, {
  Object? skip,
  Timeout? timeout,
}) {
  test(
    description,
    () async {
      final log = TestLogger(description);
      log.start();
      try {
        await body(log);
        log.done();
      } catch (e, st) {
        log.failed(e);
        Error.throwWithStackTrace(e, st);
      }
    },
    skip: skip,
    timeout: timeout,
  );
}

/// Ghi assert + chạy [expect].
void expectLogged(
  TestLogger log,
  String label,
  dynamic actual,
  dynamic matcherOrExpected, {
  String? reason,
}) {
  log.step('Assert', label);
  if (matcherOrExpected is Matcher) {
    expect(actual, matcherOrExpected, reason: reason);
    log.kv(label, 'matcher OK');
  } else {
    expect(actual, matcherOrExpected, reason: reason);
    log.kv(label, actual);
  }
}
