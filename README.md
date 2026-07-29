# cyr_flutter_core

Shared Flutter foundation for production apps that use Dio, Retrofit, GetIt, and Bloc.

`cyr_flutter_core` packages the repeatable app infrastructure used by CYR /
StrangerConfide projects: HTTP client setup, API envelope handling, dependency
registration, typed repository results, and shared Bloc/Cubit error handling.

## Features

* Configure a Dio client from one `NetworkConfig`.
* Add request IDs, dynamic headers, debug logging, and extra interceptors.
* Unwrap StrangerConfide-style API envelopes and normalize failures into `ApiError`.
* Register Retrofit services and app dependencies through GetIt.
* Return typed `AppResult<T>` values from repositories.
* Reuse `AppBloc`, `AppCubit`, `BlocHostPage`, and `ErrorDialogMixin` for consistent UI errors.

## Getting Started

Add the package to your Flutter app:

```bash
flutter pub add cyr_flutter_core
```

If you define Retrofit APIs in the host app, also add the generator dependencies
there:

```bash
flutter pub add dio retrofit
flutter pub add --dev build_runner retrofit_generator
```

## Usage

Initialize the core package before `runApp()` and register the shared HTTP
client in the setup callback.

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const config = CoreConfig(
    network: NetworkConfig(
      baseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.com/api',
      ),
      enableLogging: bool.fromEnvironment('dart.vm.product') == false,
    ),
  );

  AppCore.initialize(
    config,
    setup: (locator) {
      registerHttpClient(config.network, locator: locator);
    },
  );

  runApp(const MyApp());
}
```

Register a Retrofit API from the host app:

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String baseUrl}) = _ProfileApi;

  @GET('/profile')
  Future<Map<String, Object?>> me();
}

void registerApis() {
  registerRestApi<ProfileApi>(ProfileApi.new, locator: AppCore.locator);
}
```

Map repository calls to typed results:

```dart
class ProfileRepository {
  ProfileRepository(this._api);

  final ProfileApi _api;

  Future<AppResult<Map<String, Object?>>> me() async {
    try {
      return AppSuccess(await _api.me());
    } on DioException catch (error) {
      return AppFailure(ApiError.fromDioException(error));
    }
  }
}
```

When `NetworkConfig.unwrapEnvelope` is enabled, successful API responses are
unwrapped from `data`. Failed envelopes are rejected as `DioException` values
whose `error` can be converted to `ApiError`.

## API Envelope

The package expects this response shape when envelope unwrapping is enabled:

```json
{
  "success": true,
  "statusCode": 200,
  "code": "OK",
  "message": "Success",
  "data": {},
  "errors": null,
  "meta": null,
  "requestId": "req_123",
  "path": "/api/profile",
  "timestamp": "2026-05-22T16:21:01.289Z"
}
```

The original envelope remains available from a Dio `Response`:

```dart
final response = await AppCore.locator<Dio>().get('/profile');
final envelope = ApiEnvelope.fromResponse(response);
final requestId = envelope?.requestId;
```

## Documentation

* [Full integration guide](doc/TAI_LIEU.md)
* [Error response contract](doc/ERROR_RESPONSE.md)
* [Example app entry point](example/main.dart)
* [Publishing checklist](PUBLISHING.md)

## Testing

```bash
flutter test
flutter analyze
flutter pub publish --dry-run
```

Before publishing, run `pana` on a copy of the package to estimate pub points:

```bash
dart pub global activate pana
dart pub global run pana .
```
