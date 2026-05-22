import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/envelope_fixtures.dart';
import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/api_response_test');

  loggedGroup('ApiResponse', () {
    loggedTest('fromJson parses success with typed data', (log) {
      log.step('Arrange', 'success envelope + fromJsonT');
      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        successEnvelope(data: {'id': '42'}, meta: {'page': 1}),
        (d) => Map<String, dynamic>.from(d! as Map),
      );
      expectLogged(log, 'success', envelope.success, isTrue);
      expectLogged(log, 'data.id', envelope.data?['id'], '42');
      expectLogged(log, 'meta.page', envelope.meta?['page'], 1);
    });

    loggedTest('fromJson parses error with field errors', (log) {
      final envelope = ApiResponse<dynamic>.fromJson(
        errorEnvelope(
          errors: [
            {'field': 'email', 'message': 'invalid email'},
            {'field': 'password', 'message': 'too short'},
          ],
        ),
      );
      expectLogged(log, 'success', envelope.success, isFalse);
      expectLogged(log, 'errors.length', envelope.errors?.length, 2);
    });

    loggedTest('fromJson keeps raw data when fromJsonT is omitted', (log) {
      final envelope = ApiResponse<dynamic>.fromJson(
        successEnvelope(data: {'raw': true}),
      );
      expectLogged(log, 'data', envelope.data, {'raw': true});
    });

    loggedTest('fromJson handles null data', (log) {
      final envelope = ApiResponse<String>.fromJson(
        successEnvelope(data: null),
      );
      expectLogged(log, 'data', envelope.data, isNull);
    });

    loggedTest('fromJson defaults missing optional fields', (log) {
      final envelope = ApiResponse<dynamic>.fromJson({
        'success': true,
        'code': 'OK',
        'message': 'ok',
      });
      expectLogged(log, 'statusCode', envelope.statusCode, 0);
      expectLogged(log, 'requestId', envelope.requestId, '');
    });
  });

  loggedGroup('ApiResponse.isEnvelope', () {
    loggedTest('returns true for standard envelope', (log) {
      expectLogged(log, 'success', ApiResponse.isEnvelope(successEnvelope()), isTrue);
      expectLogged(log, 'error', ApiResponse.isEnvelope(errorEnvelope()), isTrue);
    });

    loggedTest('returns false for non-envelope shapes', (log) {
      log.step('Act', 'check invalid bodies');
      expectLogged(log, 'null', ApiResponse.isEnvelope(null), isFalse);
      expectLogged(log, 'string', ApiResponse.isEnvelope('string'), isFalse);
      expectLogged(log, 'partial', ApiResponse.isEnvelope({'message': 'only'}), isFalse);
      expectLogged(log, 'plain map', ApiResponse.isEnvelope({'foo': 'bar'}), isFalse);
    });
  });
}
