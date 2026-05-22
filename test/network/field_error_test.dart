import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/field_error_test');

  loggedGroup('FieldError', () {
    loggedTest('fromJson parses field and message', (log) {
      log.step('Act', 'FieldError.fromJson');
      final err = FieldError.fromJson({
        'field': 'email',
        'message': 'email must be an email',
      });
      expectLogged(log, 'field', err.field, 'email');
      expectLogged(log, 'message', err.message, 'email must be an email');
    });

    loggedTest('fromJson defaults missing keys', (log) {
      final err = FieldError.fromJson({});
      expectLogged(log, 'field default', err.field, '_');
      expectLogged(log, 'message default', err.message, '');
    });

    loggedTest('toJson round-trips', (log) {
      const original = FieldError(field: 'password', message: 'too short');
      log.step('Act', 'toJson → fromJson');
      final restored = FieldError.fromJson(original.toJson());
      expectLogged(log, 'equality', restored, original);
    });

    loggedTest('equality compares field and message', (log) {
      const a = FieldError(field: 'x', message: 'm');
      const b = FieldError(field: 'x', message: 'm');
      const c = FieldError(field: 'y', message: 'm');
      expectLogged(log, 'a == b', a, b);
      expectLogged(log, 'a != c', a == c, isFalse);
    });
  });
}
