/// Mã lỗi/trạng thái API chuẩn — đồng bộ 1:1 với backend `api-code.enum.ts`.
///
/// Quy ước: SCREAMING_SNAKE_CASE. Không đổi tên mã đã release.
enum ApiCode {
  ok('OK'),
  created('CREATED'),
  validationError('VALIDATION_ERROR'),
  internalError('INTERNAL_ERROR'),
  rateLimited('RATE_LIMITED'),
  notFound('NOT_FOUND'),
  forbidden('FORBIDDEN'),
  authUnauthorized('AUTH_UNAUTHORIZED'),
  authInvalidCredentials('AUTH_INVALID_CREDENTIALS'),
  authEmailExists('AUTH_EMAIL_EXISTS'),
  authInvalidOtp('AUTH_INVALID_OTP'),
  authOtpExpired('AUTH_OTP_EXPIRED'),
  authEmailNotVerified('AUTH_EMAIL_NOT_VERIFIED'),
  authRefreshFailed('AUTH_REFRESH_FAILED'),
  authUserBanned('AUTH_USER_BANNED'),
  userNotFound('USER_NOT_FOUND'),
  profileNotFound('PROFILE_NOT_FOUND'),
  profileAlreadyExists('PROFILE_ALREADY_EXISTS'),
  profileIncomplete('PROFILE_INCOMPLETE'),
  matchmakingAlreadyInQueue('MATCHMAKING_ALREADY_IN_QUEUE'),
  matchmakingTimeout('MATCHMAKING_TIMEOUT'),
  roomNotFound('ROOM_NOT_FOUND'),
  roomForbidden('ROOM_FORBIDDEN'),
  chatModerationBlocked('CHAT_MODERATION_BLOCKED'),
  chatSpamDetected('CHAT_SPAM_DETECTED'),
  chatBlockedByUser('CHAT_BLOCKED_BY_USER'),
  uploadInvalidFile('UPLOAD_INVALID_FILE'),
  uploadTooLarge('UPLOAD_TOO_LARGE');

  const ApiCode(this.value);

  final String value;

  /// Parse server `code` string; returns null if unknown.
  static ApiCode? tryParse(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final item in ApiCode.values) {
      if (item.value == code) return item;
    }
    return null;
  }
}

/// Mã chỉ dùng phía client (không có trong backend enum).
abstract final class ClientApiCode {
  static const networkError = 'NETWORK_ERROR';
}
