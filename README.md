# cyr_flutter_core

Thư viện Flutter dùng chung cho app CYR / **StrangerConfide**: HTTP client (Dio), envelope REST API, DI (GetIt), Bloc/Cubit nền, và helper hiển thị lỗi.

| | |
|---|---|
| Phiên bản | `0.1.0` |
| Dart SDK | `^3.5.0` |
| Flutter | `>=3.22.0` |
| Tài liệu chi tiết | [docs/TAI_LIEU.md](docs/TAI_LIEU.md) · [docs/ERROR_RESPONSE.md](docs/ERROR_RESPONSE.md) |

---

## Tích hợp vào project cha

Phần dưới mô tả cách gắn package vào **app Flutter host** (ví dụ `stranger_confide_app` trong monorepo). Core **không** chứa UI feature, routing hay Socket.IO — chỉ nền kỹ thuật để feature layer gọi REST API.

### 1. Cấu trúc monorepo gợi ý

```
monorepo/
├── backend/                 # NestJS — nguồn contract API
├── frontend/                # Next.js (tham chiếu client)
├── cyr_flutter_core/        # package này
└── stranger_confide_app/    # app Flutter cha
    ├── lib/
    │   ├── main.dart
    │   ├── core/di/
    │   └── features/
    └── pubspec.yaml
```

### 2. Khai báo dependency

Trong `pubspec.yaml` của **app cha**:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cyr_flutter_core:
    path: ../cyr_flutter_core   # điều chỉnh path theo monorepo thực tế
  flutter_bloc: ^9.1.1          # nếu dùng AppBloc / BlocHostPage
```

Sau đó:

```bash
cd stranger_confide_app && flutter pub get
```

Có thể dùng `git:` thay `path:` khi publish repo riêng.

### 3. Khởi tạo trong `main.dart` (bắt buộc)

Gọi `AppCore.initialize()` **trước** `runApp()`. Đăng ký `Dio` + `ApiClient` qua `registerHttpClient`.

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const config = CoreConfig(
    network: NetworkConfig(
      // Khớp NEXT_PUBLIC_API_URL / backend — thường có suffix /api
      baseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000/api',
      ),
      enableLogging: bool.fromEnvironment('dart.vm.product') == false,
      headerProvider: _authHeaders,
    ),
    presentation: const PresentationConfig(
      errorDialogTitle: 'Lỗi',
      errorDialogCloseLabel: 'Đóng',
      connectionErrorMessage: 'Không kết nối được. Thử lại.',
    ),
  );

  AppCore.initialize(
    config,
    setup: (locator) {
      registerHttpClient(config.network, locator: locator);

      configureDependencies(
        manualRegistration: (locator) {
          // Đăng ký repository / service app cha tại đây
          // locator.registerLazySingleton<AuthRepository>(
          //   () => AuthRepository(locator<ApiClient>()),
          // );
        },
        locator: locator,
      );
    },
  );

  runApp(const MyApp());
}

/// Token động mỗi request — implement theo storage app cha.
Future<Map<String, String>> _authHeaders() async {
  final token = await TokenStorage.readAccessToken();
  if (token == null || token.isEmpty) return {};
  return {'Authorization': 'Bearer $token'};
}
```

**Lưu ý:** `AppCore.locator` là `GetIt` dùng chung; mọi feature resolve `ApiClient` / `Dio` từ đây.

### 4. Gọi REST API từ feature (repository)

`ApiClient` trả **payload đã unwrap** (`data` trong envelope). Lỗi nghiệp vụ → `DioException` với `error` kiểu `ApiError`.

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  factory AuthRepository.fromLocator() =>
      AuthRepository(AppCore.locator<ApiClient>());

  Future<AppResult<AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    try {
      final json = await _api.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
        fromJson: (raw) => Map<String, dynamic>.from(raw! as Map),
      );
      return AppSuccess(AuthTokens.fromJson(json));
    } on DioException catch (e) {
      final apiError = e.error is ApiError
          ? e.error! as ApiError
          : ApiError.fromDioException(e);
      return AppFailure(apiError);
    }
  }
}
```

**Xử lý theo `ApiCode`** (không dựa `message` — có thể đổi trên server):

```dart
void handleLoginFailure(ApiError err) {
  switch (err.code) {
    case 'AUTH_INVALID_CREDENTIALS':
      // sai email/mật khẩu
      break;
    case 'VALIDATION_ERROR':
      // err.fieldMessages['email'], err.errors, ...
      break;
    case 'AUTH_USER_BANNED':
      break;
    default:
      break;
  }
  // Hoặc: err.apiCode == ApiCode.authInvalidCredentials
}
```

### 5. Envelope API (contract backend)

Mọi response REST StrangerConfide dùng chung shape (2xx và 4xx/5xx có JSON):

```json
{
  "success": true,
  "statusCode": 200,
  "code": "OK",
  "message": "Thành công",
  "data": { },
  "errors": null,
  "meta": null,
  "requestId": "req_…",
  "path": "/api/…",
  "timestamp": "2026-05-22T16:21:01.289Z"
}
```

Package tự động (khi `unwrapEnvelope: true` — mặc định):

| Thành phần | Việc làm |
|------------|----------|
| `ApiEnvelopeInterceptor` | `success: true` → `response.data` = `data`; `success: false` → reject + `ApiError` |
| `RequestIdInterceptor` | Gắn `X-Request-Id` (server tôn trọng header này) |
| `DynamicHeaderInterceptor` | Merge `headerProvider` (Bearer token, …) |

Cần `meta` / `requestId` sau khi gọi:

```dart
final response = await AppCore.locator<Dio>().get('/profile');
final envelope = ApiClient.envelopeFrom(response);
final requestId = envelope?.requestId;
```

Chi tiết lỗi: [docs/ERROR_RESPONSE.md](docs/ERROR_RESPONSE.md).

### 6. Đăng ký DI feature trong app cha

Ví dụ tách file `lib/core/di/injection.dart`:

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';

void registerAppDependencies(GetIt locator) {
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator<ApiClient>()),
  );
  locator.registerFactory<LoginBloc>(
    () => LoginBloc(locator<AuthRepository>()),
  );
}
```

Gọi trong `setup` của `AppCore.initialize`:

```dart
setup: (locator) {
  registerHttpClient(config.network, locator: locator);
  configureDependencies(
    manualRegistration: registerAppDependencies,
    locator: locator,
  );
},
```

### 7. Bloc + dialog lỗi (tùy chọn)

Khi feature dùng `flutter_bloc`:

```dart
class LoginBloc extends AppBloc<LoginEvent, LoginState> {
  LoginBloc(this._repo) : super(const LoginState.initial()) {
    on<LoginSubmitted>(_onSubmit);
  }

  final AuthRepository _repo;

  Future<void> _onSubmit(LoginSubmitted e, Emitter<LoginState> emit) =>
      guard(() async {
        emit(state.copyWith(status: LoginStatus.loading));
        final result = await _repo.login(
          email: e.email,
          password: e.password,
        );
        switch (result) {
          case AppSuccess(:final value):
            emit(state.copyWith(status: LoginStatus.success, tokens: value));
          case AppFailure(:final error):
            throw error; // guard → errorStream → dialog
        }
      });
}
```

UI — `BlocHostPage` tự hiện dialog từ `errorStream`:

```dart
class LoginPage extends BlocHostPage {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends BlocHostPageState<LoginPage> {
  @override
  Stream<String> get errorStream => context.read<LoginBloc>().errorStream;

  @override
  Widget buildPage(BuildContext context) {
    return /* form đăng nhập */;
  }
}
```

### 8. Interceptor tùy chỉnh (refresh token, v.v.)

Thêm vào `NetworkConfig.extraInterceptors` **sau** interceptor core (đăng ký qua factory):

```dart
NetworkConfig(
  baseUrl: apiBaseUrl,
  headerProvider: _authHeaders,
  extraInterceptors: [
    RefreshTokenInterceptor(
      dioProvider: () => AppCore.locator<Dio>(),
      onLogout: () => /* điều hướng login */,
    ),
  ],
),
```

Refresh token **không** có sẵn trong core — implement ở app cha, tương tự `frontend/src/lib/api.ts`.

### 9. Biến môi trường / build flavor

```bash
flutter run --dart-define=API_BASE_URL=https://api.staging.example.com/api
```

```dart
NetworkConfig(
  baseUrl: const String.fromEnvironment('API_BASE_URL'),
  enableLogging: kDebugMode,
),
```

### 10. Checklist tích hợp

- [ ] `path` / `git` dependency trỏ đúng `cyr_flutter_core`
- [ ] `AppCore.initialize` trước `runApp`
- [ ] `registerHttpClient` trong `setup`
- [ ] `baseUrl` khớp backend (có `/api` nếu server cấu hình vậy)
- [ ] `headerProvider` gắn Bearer khi đã login
- [ ] Repository `catch DioException` → `ApiError` / `AppFailure`
- [ ] UI/Bloc switch theo `ApiCode`, không hard-code `message`
- [ ] Feature DI đăng ký trong `configureDependencies`

---

## Export chính

| Symbol | Mục đích |
|--------|----------|
| `AppCore`, `CoreConfig`, `NetworkConfig`, `PresentationConfig` | Bootstrap |
| `registerHttpClient`, `ApiClient`, `Dio` | HTTP |
| `ApiCode`, `ApiResponse`, `ApiError`, `FieldError` | Contract API |
| `AppResult`, `AppSuccess`, `AppFailure` | Repository result |
| `AppBloc`, `AppCubit`, `BlocHostPage` | State + lỗi UI |
| `configureDependencies`, `register*Override` | DI |

---

## Kiểm thử package

```bash
cd cyr_flutter_core
flutter test
# Log chi tiết: mặc định bật
# Tắt log: flutter test --dart-define=SILENT_TESTS=true
```

Trong test app cha, `tearDown` gọi `AppCore.reset()` nếu dùng config/locator toàn cục.

---

## Cấu trúc mã nguồn

```
lib/
├── cyr_flutter_core.dart
└── src/
    ├── app_core.dart
    ├── config/
    ├── network/          # ApiClient, envelope, interceptors
    ├── di/
    ├── bloc/
    ├── presentation/
    └── result/
```

---

## Tài liệu thêm

- [docs/TAI_LIEU.md](docs/TAI_LIEU.md) — hướng dẫn đầy đủ từng module
- [docs/ERROR_RESPONSE.md](docs/ERROR_RESPONSE.md) — contract lỗi, `ApiCode`, debug `requestId`
