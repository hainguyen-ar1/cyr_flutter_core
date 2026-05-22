import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/api_code_test');

  loggedGroup('ApiCode', () {
    loggedTest('has 28 codes synced with backend', (log) {
      log.step('Assert', 'enum length');
      expectLogged(log, 'ApiCode.values.length', ApiCode.values.length, 28);
    });

    loggedTest('every enum value matches backend string', (log) {
      log.step('Arrange', 'build expected map from backend contract');
      final expected = <String, ApiCode>{
        'OK': ApiCode.ok,
        'CREATED': ApiCode.created,
        'VALIDATION_ERROR': ApiCode.validationError,
        'INTERNAL_ERROR': ApiCode.internalError,
        'RATE_LIMITED': ApiCode.rateLimited,
        'NOT_FOUND': ApiCode.notFound,
        'FORBIDDEN': ApiCode.forbidden,
        'AUTH_UNAUTHORIZED': ApiCode.authUnauthorized,
        'AUTH_INVALID_CREDENTIALS': ApiCode.authInvalidCredentials,
        'AUTH_EMAIL_EXISTS': ApiCode.authEmailExists,
        'AUTH_INVALID_OTP': ApiCode.authInvalidOtp,
        'AUTH_OTP_EXPIRED': ApiCode.authOtpExpired,
        'AUTH_EMAIL_NOT_VERIFIED': ApiCode.authEmailNotVerified,
        'AUTH_REFRESH_FAILED': ApiCode.authRefreshFailed,
        'AUTH_USER_BANNED': ApiCode.authUserBanned,
        'USER_NOT_FOUND': ApiCode.userNotFound,
        'PROFILE_NOT_FOUND': ApiCode.profileNotFound,
        'PROFILE_ALREADY_EXISTS': ApiCode.profileAlreadyExists,
        'PROFILE_INCOMPLETE': ApiCode.profileIncomplete,
        'MATCHMAKING_ALREADY_IN_QUEUE': ApiCode.matchmakingAlreadyInQueue,
        'MATCHMAKING_TIMEOUT': ApiCode.matchmakingTimeout,
        'ROOM_NOT_FOUND': ApiCode.roomNotFound,
        'ROOM_FORBIDDEN': ApiCode.roomForbidden,
        'CHAT_MODERATION_BLOCKED': ApiCode.chatModerationBlocked,
        'CHAT_SPAM_DETECTED': ApiCode.chatSpamDetected,
        'CHAT_BLOCKED_BY_USER': ApiCode.chatBlockedByUser,
        'UPLOAD_INVALID_FILE': ApiCode.uploadInvalidFile,
        'UPLOAD_TOO_LARGE': ApiCode.uploadTooLarge,
      };

      log.step('Act', 'verify each ApiCode.value');
      for (final code in ApiCode.values) {
        expect(expected[code.value], code);
      }
      expectLogged(log, 'expected.length', expected.length, 28);
    });

    loggedTest('tryParse returns null for unknown or empty', (log) {
      log.step('Act', 'tryParse edge inputs');
      expectLogged(log, 'null', ApiCode.tryParse(null), isNull);
      expectLogged(log, 'empty', ApiCode.tryParse(''), isNull);
      expectLogged(log, 'unknown', ApiCode.tryParse('UNKNOWN_CODE'), isNull);
    });

    loggedTest('tryParse round-trips all values', (log) {
      log.step('Act', 'round-trip 28 codes');
      for (final code in ApiCode.values) {
        expect(ApiCode.tryParse(code.value), code);
      }
      log.kv('round-trip', '${ApiCode.values.length} codes OK');
    });
  });

  loggedGroup('ClientApiCode', () {
    loggedTest('networkError is client-only constant', (log) {
      expectLogged(
        log,
        'networkError',
        ClientApiCode.networkError,
        'NETWORK_ERROR',
      );
      expectLogged(
        log,
        'not in ApiCode',
        ApiCode.tryParse(ClientApiCode.networkError),
        isNull,
      );
    });
  });
}
