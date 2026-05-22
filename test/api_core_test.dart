import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Dio dioWithMockEnvelope({
    required Map<String, dynamic> body,
    int statusCode = 200,
  }) {
    return HttpClientFactory.create(
      NetworkConfig(
        baseUrl: 'https://api.test/',
        enableLogging: false,
        enableRequestId: false,
        extraInterceptors: [
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: statusCode,
                  data: body,
                ),
                true,
              );
            },
          ),
        ],
      ),
    );
  }

  group('ApiCode', () {
    test('syncs all backend codes', () {
      expect(ApiCode.authInvalidCredentials.value, 'AUTH_INVALID_CREDENTIALS');
      expect(ApiCode.values.length, 28);
      expect(ApiCode.tryParse('ROOM_NOT_FOUND'), ApiCode.roomNotFound);
      expect(ApiCode.tryParse('UNKNOWN'), isNull);
    });
  });

  group('ApiResponse', () {
    test('parses success envelope', () {
      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        {
          'success': true,
          'statusCode': 200,
          'code': 'OK',
          'message': 'Thành công',
          'data': {'id': '1'},
          'errors': null,
          'meta': {'page': 1},
          'requestId': 'req_abc',
          'path': '/api/users',
          'timestamp': '2026-05-22T16:21:01.289Z',
        },
        (d) => Map<String, dynamic>.from(d! as Map),
      );
      expect(envelope.success, isTrue);
      expect(envelope.data?['id'], '1');
      expect(envelope.meta?['page'], 1);
    });

    test('parses validation error envelope', () {
      final envelope = ApiResponse<dynamic>.fromJson({
        'success': false,
        'statusCode': 400,
        'code': 'VALIDATION_ERROR',
        'message': 'Dữ liệu không hợp lệ',
        'data': null,
        'errors': [
          {'field': 'email', 'message': 'email must be an email'},
        ],
        'meta': null,
        'requestId': 'req_8af2',
        'path': '/api/auth/register',
        'timestamp': '2026-05-22T16:21:01.289Z',
      });
      expect(envelope.success, isFalse);
      expect(envelope.errors?.single.field, 'email');
    });
  });

  group('ApiError', () {
    test('fromEnvelope maps fields', () {
      final err = ApiError.fromEnvelope(
        ApiResponse<dynamic>.fromJson({
          'success': false,
          'statusCode': 401,
          'code': 'AUTH_INVALID_CREDENTIALS',
          'message': 'Email hoặc mật khẩu không đúng',
          'data': null,
          'errors': null,
          'meta': null,
          'requestId': 'req_f1',
          'path': '/api/auth/login',
          'timestamp': '2026-05-22T16:21:01.289Z',
        }),
      );
      expect(err.statusCode, 401);
      expect(err.code, 'AUTH_INVALID_CREDENTIALS');
      expect(err.apiCode, ApiCode.authInvalidCredentials);
      expect(err.requestId, 'req_f1');
    });
  });

  group('ApiEnvelopeInterceptor', () {
    test('unwraps success data', () async {
      final dio = dioWithMockEnvelope(
        body: {
          'success': true,
          'statusCode': 200,
          'code': 'OK',
          'message': 'Thành công',
          'data': {'name': 'An'},
          'errors': null,
          'meta': null,
          'requestId': 'req_1',
          'path': '/ok',
          'timestamp': '2026-05-22T16:21:01.289Z',
        },
      );

      final response = await dio.get<Map<String, dynamic>>('/ok');
      expect(response.data?['name'], 'An');
      final envelope = ApiClient.envelopeFrom(response);
      expect(envelope?.code, 'OK');
    });

    test('rejects with ApiError on success false', () async {
      final dio = dioWithMockEnvelope(
        statusCode: 401,
        body: {
          'success': false,
          'statusCode': 401,
          'code': 'AUTH_INVALID_CREDENTIALS',
          'message': 'Sai mật khẩu',
          'data': null,
          'errors': null,
          'meta': null,
          'requestId': 'req_2',
          'path': '/fail',
          'timestamp': '2026-05-22T16:21:01.289Z',
        },
      );

      try {
        await dio.post('/fail');
        fail('expected DioException');
      } on DioException catch (e) {
        expect(e.error, isA<ApiError>());
        expect((e.error! as ApiError).code, 'AUTH_INVALID_CREDENTIALS');
      }
    });
  });

  group('RequestIdInterceptor', () {
    test('adds X-Request-Id header', () async {
      final dio = Dio();
      String? capturedId;
      dio.interceptors.add(
        RequestIdInterceptor(requestIdProvider: () => 'my-trace-id'),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedId = options.headers['X-Request-Id'] as String?;
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: null),
              true,
            );
          },
        ),
      );

      await dio.get('https://api.test/ping');
      expect(capturedId, 'my-trace-id');
    });

    test('generateRequestId matches req_ prefix', () {
      final id = RequestIdInterceptor.generateRequestId();
      expect(id.startsWith('req_'), isTrue);
      expect(id.length, 'req_'.length + 16);
    });
  });

  group('ApiClient', () {
    test('get returns unwrapped payload', () async {
      final dio = dioWithMockEnvelope(
        body: {
          'success': true,
          'statusCode': 200,
          'code': 'OK',
          'message': 'Thành công',
          'data': {'userId': 'u1'},
          'errors': null,
          'meta': null,
          'requestId': 'req_3',
          'path': '/profile',
          'timestamp': '2026-05-22T16:21:01.289Z',
        },
      );

      final client = ApiClient(dio);
      final data = await client.get<Map<String, dynamic>>(
        '/profile',
        fromJson: (json) => Map<String, dynamic>.from(json! as Map),
      );
      expect(data['userId'], 'u1');
    });
  });

  group('HttpClientFactory', () {
    test('includes envelope and request-id interceptors by default', () {
      const config = NetworkConfig(
        baseUrl: 'https://api.test/',
        enableLogging: false,
      );
      final dio = HttpClientFactory.create(config);
      final types = dio.interceptors.map((i) => i.runtimeType).toList();
      expect(types, contains(RequestIdInterceptor));
      expect(types, contains(ApiEnvelopeInterceptor));
    });
  });
}
