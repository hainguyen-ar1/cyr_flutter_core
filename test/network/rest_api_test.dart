import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/envelope_fixtures.dart';
import '../helpers/sample_rest_api.dart';
import '../helpers/test_logger.dart';

void main() {
  TestLogger.configureTestLogging(suiteLabel: 'network/rest_api_test');

  loggedGroup('RestApi (Retrofit)', () {
    loggedTest('get returns unwrapped data', (log) async {
      log.step('Arrange', 'mock GET /profile → userId=u1');
      final dio = createMockDio(
        body: successEnvelope(data: {'userId': 'u1'}, path: '/profile'),
        log: log,
      );
      final api = RestApiFactory.create(dio, SampleRestApi.new);

      log.step('Act', 'GET /profile');
      final data = await api.getProfile();

      expectLogged(log, 'userId', data['userId'], 'u1');
    });

    loggedTest('post sends body and returns data', (log) async {
      log.step('Arrange', 'mock POST /auth/login');
      final dio = createMockDio(
        body: successEnvelope(
          data: {'accessToken': 'tok'},
          path: '/auth/login',
        ),
        log: log,
      );
      final api = RestApiFactory.create(dio, SampleRestApi.new);

      log.step('Act', 'POST credentials');
      final result = await api.login({
        'email': 'a@b.c',
        'password': 'secret',
      });

      expectLogged(log, 'accessToken', result['accessToken'], 'tok');
    });

    loggedTest('put returns unwrapped data', (log) async {
      final dio = createMockDio(
        body: successEnvelope(data: {'updated': true}),
        log: log,
      );
      final api = RestApiFactory.create(dio, SampleRestApi.new);

      log.step('Act', 'PUT /profile');
      final result = await api.updateProfile({'bio': 'hi'});

      expectLogged(log, 'updated', result['updated'], isTrue);
    });

    loggedTest('patch returns unwrapped data', (log) async {
      final dio = createMockDio(
        body: successEnvelope(data: 42),
        log: log,
      );
      final api = RestApiFactory.create(dio, SampleRestApi.new);

      log.step('Act', 'PATCH /counter');
      final result = await api.patchCounter();

      expectLogged(log, 'value', result, 42);
    });

    loggedTest('delete completes with null data', (log) async {
      final dio = createMockDio(
        body: successEnvelope(data: null, path: '/session'),
        log: log,
      );
      final api = RestApiFactory.create(dio, SampleRestApi.new);

      log.step('Act', 'DELETE /session');
      await api.deleteSession();
      log.kv('response', 'completed (data=null)');
    });

    loggedTest('envelopeFrom returns null without interceptor', (log) async {
      log.step('Arrange', 'plain Dio without ApiEnvelopeInterceptor');
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.resolve(
            Response(requestOptions: o, data: {'plain': 1}),
            true,
          ),
        ),
      );

      log.step('Act', 'GET /');
      final response = await dio.get('/');
      expectLogged(
        log,
        'envelope',
        ApiEnvelope.fromResponse(response),
        isNull,
      );
    });

    loggedTest('propagates ApiError on business failure', (log) async {
      log.step('Arrange', 'mock 404 USER_NOT_FOUND');
      final dio = createMockDio(
        statusCode: 404,
        body: errorEnvelope(
          statusCode: 404,
          code: 'USER_NOT_FOUND',
          message: 'Không tìm thấy',
          path: '/users/1',
        ),
        log: log,
      );
      final api = RestApiFactory.create(dio, SampleRestApi.new);

      log.step('Act', 'GET /users/1 (expect throw)');
      await expectLater(
        api.getUser('1'),
        throwsA(isA<Exception>()),
      );
      log.kv('result', 'DioException propagated');
    });
  });
}
