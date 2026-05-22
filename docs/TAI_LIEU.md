# Tài liệu `cyr_flutter_core`

Thư viện Flutter dùng chung cho các ứng dụng CYR: cấu hình tập trung, HTTP client (Dio), lớp nền Bloc/Cubit, dependency injection (GetIt), và helper hiển thị lỗi trên UI.

| Thuộc tính | Giá trị |
|------------|---------|
| Phiên bản | `0.1.0` |
| SDK Dart | `^3.5.0` |
| Flutter | `>=3.22.0` |
| Phụ thuộc chính | `dio`, `flutter_bloc`, `get_it`, `meta` |

---

## Mục lục

1. [Tổng quan kiến trúc](#1-tổng-quan-kiến-trúc)
2. [Cài đặt](#2-cài-đặt)
3. [Khởi tạo ứng dụng host](#3-khởi-tạo-ứng-dụng-host)
4. [Cấu hình](#4-cấu-hình)
5. [Lớp mạng (Network)](#5-lớp-mạng-network)
6. [Dependency Injection](#6-dependency-injection)
7. [Bloc và Cubit](#7-bloc-và-cubit)
8. [Presentation — trang và dialog lỗi](#8-presentation--trang-và-dialog-lỗi)
9. [AppResult — kết quả repository](#9-appresult--kết-quả-repository)
10. [Cấu trúc thư mục](#10-cấu-trúc-thư-mục)
11. [Tham chiếu API nhanh](#11-tham-chiếu-api-nhanh)
12. [Kiểm thử](#12-kiểm-thử)
13. [Ví dụ tích hợp đầy đủ](#13-ví-dụ-tích-hợp-đầy-đủ)

---

## 1. Tổng quan kiến trúc

```
┌─────────────────────────────────────────────────────────────┐
│                     Ứng dụng host (MyApp)                    │
├─────────────────────────────────────────────────────────────┤
│  AppCore.initialize(CoreConfig)                              │
│    ├── NetworkConfig  → HttpClientFactory → Dio (GetIt)      │
│    └── PresentationConfig → ErrorDialogMixin / ErrorMapper   │
├─────────────────────────────────────────────────────────────┤
│  Feature layer                                               │
│    Repository → AppResult<T>                                 │
│    AppBloc / AppCubit + guard() → errorStream                │
│    BlocHostPage / CubitHostPage → dialog lỗi tự động         │
└─────────────────────────────────────────────────────────────┘
```

**Luồng xử lý lỗi tiêu chuẩn:**

1. Repository bắt lỗi mạng, trả về `AppFailure` với `ApiError`, hoặc ném exception.
2. Bloc/Cubit gọi logic trong `guard()`. Khi có exception, `BlocGuard` ghi log, map sang chuỗi hiển thị qua `NetworkErrorMapper`, rồi đẩy vào `errorStream`.
3. `BlocHostPage` / `CubitHostPage` lắng nghe `errorStream` và hiển thị `AlertDialog` qua `ErrorDialogMixin`.

---

## 2. Cài đặt

Thêm package vào `pubspec.yaml` của app host:

```yaml
dependencies:
  cyr_flutter_core:
    path: ../cyr_flutter_core   # hoặc git / pub.dev khi publish
```

Import barrel:

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';
```

---

## 3. Khởi tạo ứng dụng host

Gọi `AppCore.initialize()` **trước** `runApp()`. Hàm này lưu `CoreConfig` toàn cục và cho phép đăng ký DI qua callback `setup`.

```dart
void main() {
  const config = CoreConfig(
    network: NetworkConfig(
      baseUrl: 'https://api.example.com/',
      headerProvider: () async => {
        'Authorization': 'Bearer $token',
      },
    ),
    presentation: PresentationConfig(
      errorDialogTitle: 'Lỗi',
      connectionErrorMessage: 'Không kết nối được. Thử lại.',
    ),
  );

  AppCore.initialize(
    config,
    setup: (locator) {
      registerHttpClient(config.network, locator: locator);
      configureDependencies(
        manualRegistration: (locator) {
          // Ví dụ: locator từ injectable code-gen
          // getIt.init();
        },
        locator: locator,
      );
    },
  );

  runApp(const MyApp());
}
```

### API `AppCore`

| Thành viên | Mô tả |
|------------|--------|
| `AppCore.initialize(config, {setup})` | Khởi tạo config và chạy hook DI |
| `AppCore.config` | Trả `CoreConfig`; ném `StateError` nếu chưa initialize |
| `AppCore.isInitialized` | `true` sau khi gọi `initialize` |
| `AppCore.locator` | Instance `GetIt` dùng chung (`DependencyLocator.instance`) |
| `AppCore.reset()` | Xóa config và reset GetIt — **chỉ dùng trong test** |

---

## 4. Cấu hình

### `CoreConfig`

Gốc cấu hình truyền vào `AppCore.initialize`.

| Trường | Kiểu | Bắt buộc | Mặc định |
|--------|------|----------|----------|
| `network` | `NetworkConfig` | Có | — |
| `presentation` | `PresentationConfig` | Không | `const PresentationConfig()` |

### `NetworkConfig`

| Trường | Kiểu | Mặc định | Mô tả |
|--------|------|----------|--------|
| `baseUrl` | `String` | — | URL gốc API (bắt buộc) |
| `connectTimeout` | `Duration` | 30 giây | Timeout kết nối |
| `receiveTimeout` | `Duration` | 30 giây | Timeout nhận dữ liệu |
| `sendTimeout` | `Duration?` | `null` | Timeout gửi |
| `defaultHeaders` | `Map<String, String>` | `Accept`, `Content-Type: application/json` | Header cố định |
| `headerProvider` | `Future<Map<String, String>> Function()?` | `null` | Header động mỗi request (token, locale…) |
| `extraInterceptors` | `List<Interceptor>` | `[]` | Interceptor tùy chỉnh thêm vào Dio |
| `enableLogging` | `bool` | `true` | Bật `LoggingInterceptor` |
| `requestIdProvider` | `String Function()?` | `null` | Custom `X-Request-Id` |
| `enableRequestId` | `bool` | `true` | Gắn `X-Request-Id` |
| `unwrapEnvelope` | `bool` | `true` | Bật `ApiEnvelopeInterceptor` |

### `PresentationConfig`

| Trường | Mặc định | Dùng cho |
|--------|----------|----------|
| `errorDialogTitle` | `'Error'` | Tiêu đề dialog |
| `errorDialogCloseLabel` | `'Close'` | Nút đóng |
| `primaryColor` | `null` (lấy từ `Theme`) | Màu nút trong dialog |
| `connectionErrorMessage` | `'Connection error. Please try again.'` | Lỗi Dio không có message |
| `unknownErrorMessage` | `'An unknown error occurred.'` | Lỗi không map được |

---

## 5. Lớp mạng (Network)

### Tạo Dio thủ công

```dart
final dio = HttpClientFactory.create(networkConfig);
```

`HttpClientFactory` tạo `Dio` với `BaseOptions`, sau đó gắn interceptor theo thứ tự:

1. `RequestIdInterceptor` — nếu `enableRequestId`
2. `DynamicHeaderInterceptor` — nếu có `headerProvider`
3. `ApiEnvelopeInterceptor` — nếu `unwrapEnvelope`
4. `LoggingInterceptor` — nếu `enableLogging`
5. `extraInterceptors`

### Đăng ký Dio vào GetIt

```dart
registerHttpClient(config.network, locator: AppCore.locator);
// Sau đó: final dio = AppCore.locator<Dio>();
```

Đăng ký dạng **lazy singleton**, có thể ghi đè bằng `registerLazySingletonOverride`.

### Envelope StrangerConfide (REST)

Mọi response backend dùng chung shape — xem [docs/ERROR_RESPONSE.md](ERROR_RESPONSE.md).

| Thành phần | Vai trò |
|------------|---------|
| `ApiCode` | Enum mã lỗi/trạng thái (đồng bộ 1:1 backend) |
| `ApiResponse<T>` | Parse envelope JSON |
| `ApiError` | Lỗi normalize (`code`, `errors[]`, `requestId`, …) |
| `ApiEnvelopeInterceptor` | Unwrap `data`; `success: false` → reject + `ApiError` |
| `RequestIdInterceptor` | Header `X-Request-Id` |
| `ApiClient` | GET/POST/… trả payload đã unwrap |

```dart
final client = AppCore.locator<ApiClient>();
final profile = await client.get<Map<String, dynamic>>(
  '/profile/me',
  fromJson: (j) => Map<String, dynamic>.from(j! as Map),
);

// Switch theo code (không dựa message)
try {
  await client.post('/auth/login', data: body);
} on DioException catch (e) {
  final err = e.error as ApiError?;
  if (err?.code == ApiCode.authInvalidCredentials.value) { /* ... */ }
}
```

`registerHttpClient` đăng ký cả `Dio` và `ApiClient` (có thể tắt bằng `registerApiClient: false`).

### `ApiError`

Model lỗi API thống nhất cho repository và UI.

```dart
final err = ApiError.fromJson(responseData);
// Hoặc: ApiError.fromEnvelope(envelope)
```

| Trường | Mô tả |
|--------|--------|
| `statusCode` | Mã HTTP |
| `code` | `ApiCode` string (machine-readable) |
| `message` | Thông báo hiển thị |
| `errors` | `List<FieldError>?` — validation |
| `requestId` / `path` | Tra log / debug |
| `raw` | Envelope hoặc JSON gốc |

### `NetworkErrorMapper`

Chuyển mọi `Object` lỗi thành `String` cho người dùng.

**`DefaultNetworkErrorMapper`** xử lý:

| Loại lỗi | Cách map |
|----------|----------|
| `ApiError` | `error.message` |
| `DioException` + body JSON có `message` hoặc `error` | Giá trị tương ứng |
| `DioException` khác | `error.message` hoặc `connectionErrorMessage` |
| Khác | `toString()` hoặc `unknownErrorMessage` |

Có thể inject mapper tùy chỉnh vào `AppBloc` / `AppCubit`:

```dart
class ProfileBloc extends AppBloc<ProfileEvent, ProfileState> {
  ProfileBloc({NetworkErrorMapper? errorMapper})
      : super(const ProfileState.initial(), errorMapper: errorMapper);
}
```

### Interceptor có sẵn

- **`DynamicHeaderInterceptor`**: gọi `headerProvider()` trước mỗi request, merge vào `options.headers`.
- **`LoggingInterceptor`**: log response/error qua `dart:developer` (`name: 'HTTP'`). Tuỳ chọn `logRequestBody`.

---

## 6. Dependency Injection

Package bọc **GetIt** qua `DependencyLocator` và các helper ghi đè an toàn.

### `configureDependencies`

```dart
configureDependencies(
  manualRegistration: (locator) {
    // Đăng ký thủ công hoặc gọi code-gen injectable
  },
  overrideModules: [
    MyOverrideModule(), // implements DependencyOverrideModule
  ],
  locator: AppCore.locator,
);
```

### Helper ghi đè registration

| Hàm | Kiểu đăng ký |
|-----|----------------|
| `registerFactoryOverride<T>()` | Factory — mỗi lần `get` tạo mới |
| `registerLazySingletonOverride<T>()` | Lazy singleton |
| `registerSingletonOverride<T>()` | Singleton instance |

Mỗi hàm **unregister** nếu `T` đã tồn tại, rồi đăng ký lại — hữu ích khi test hoặc hot-swap mock.

### `DependencyOverrideModule`

Interface cho module override sau code-gen:

```dart
class TestOverrideModule implements DependencyOverrideModule {
  @override
  void register(GetIt locator) {
    registerSingletonOverride<AuthService>(MockAuthService(), locator: locator);
  }
}
```

---

## 7. Bloc và Cubit

### `BlocEvent`

Lớp marker — mọi event của app nên `extends BlocEvent`:

```dart
sealed class ProfileEvent extends BlocEvent {
  const ProfileEvent();
}
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}
```

### `AppBloc<E, S>` và `AppCubit<S>`

Kế thừa `Bloc` / `Cubit` của `flutter_bloc`, mixin `BlocGuard`, cung cấp:

- `errorStream` — `Stream<String>` broadcast cho UI
- `guard()` — bọc async, bắt lỗi, log, emit message

### `BlocGuard.guard()`

```dart
Future<void> onLoad() => guard(() async {
  emit(state.copyWith(status: Loading()));
  final result = await repository.fetch();
  // ...
}, onError: (e) {
  // Tuỳ chọn: xử lý thêm, không hiện dialog
}, reportError: true); // false = không đẩy vào errorStream
```

| Tham số | Mặc định | Mô tả |
|---------|----------|--------|
| `action` | — | Hàm async cần chạy |
| `onError` | `null` | Callback khi catch |
| `reportError` | `true` | Có đẩy message lên `errorStream` hay không |

Log lỗi dùng `dart:developer` với `name: 'BlocGuard'`.

### Ví dụ Bloc

```dart
class ProfileBloc extends AppBloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repo) : super(const ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoad);
  }

  final ProfileRepository _repo;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) => guard(() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _repo.getProfile();
    switch (result) {
      case AppSuccess(:final value):
        emit(state.copyWith(status: ProfileStatus.success, profile: value));
      case AppFailure(:final error):
        throw error; // guard sẽ map và hiện dialog
    }
  });
}
```

### Ví dụ Cubit

```dart
class CounterCubit extends AppCubit<int> {
  CounterCubit() : super(0);

  Future<void> incrementRemote() => guard(() async {
    final value = await api.increment(state);
    emit(value);
  });
}
```

---

## 8. Presentation — trang và dialog lỗi

### `BlocHostPage` / `BlocHostPageState`

Dành cho màn hình dùng `AppBloc`:

```dart
class ProfilePage extends BlocHostPage {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends BlocHostPageState<ProfilePage> {
  @override
  Stream<String> get errorStream =>
      context.read<ProfileBloc>().errorStream;

  @override
  Widget buildPage(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) => /* UI */,
    );
  }
}
```

### `CubitHostPage` / `CubitHostPageState`

Tương tự cho `AppCubit` — cung cấp `errorStream` và implement `buildPage`.

### `ErrorDialogMixin`

- `listenErrors(stream)` — subscribe trong `initState` (post-frame).
- `presentationConfig` — lấy từ `AppCore.config.presentation` hoặc default.
- Tự `dispose` subscription.

Type alias tiện lợi: `AppBlocPage`, `AppCubitPage`.

---

## 9. AppResult — kết quả repository

Kiểu **sealed** discriminated union cho layer data:

```dart
sealed class AppResult<T> {}
final class AppSuccess<T> extends AppResult<T> { final T value; }
final class AppFailure<T> extends AppResult<T> { final ApiError error; }
```

### Extension `AppResultX`

| Getter | Mô tả |
|--------|--------|
| `isSuccess` / `isFailure` | Kiểm tra nhánh |
| `valueOrNull` | Giá trị khi success, ngược lại `null` |
| `errorOrNull` | `ApiError` khi failure |

Ví dụ repository:

```dart
Future<AppResult<User>> fetchUser() async {
  try {
    final response = await dio.get('/user');
    return AppSuccess(User.fromJson(response.data));
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return AppFailure(ApiError.fromJson(data));
    }
    return AppFailure(ApiError(message: e.message ?? 'Network error'));
  }
}
```

---

## 10. Cấu trúc thư mục

```
lib/
├── cyr_flutter_core.dart          # Barrel export
└── src/
    ├── app_core.dart              # Bootstrap & config toàn cục
    ├── config/
    │   ├── core_config.dart
    │   ├── network_config.dart
    │   └── presentation_config.dart
    ├── network/
    │   ├── api_error.dart
    │   ├── http_client_factory.dart
    │   ├── network_error_mapper.dart
    │   ├── register_http_client.dart
    │   └── interceptors/
    │       ├── dynamic_header_interceptor.dart
    │       └── logging_interceptor.dart
    ├── di/
    │   ├── dependency_locator.dart
    │   ├── dependency_registry.dart
    │   └── dependency_override_module.dart
    ├── bloc/
    │   ├── app_bloc.dart
    │   ├── app_cubit.dart
    │   ├── bloc_event.dart
    │   └── bloc_guard.dart
    ├── presentation/
    │   ├── bloc_host_page.dart
    │   └── error_dialog_mixin.dart
    └── result/
        └── app_result.dart
```

---

## 11. Tham chiếu API nhanh

### Export công khai (`cyr_flutter_core.dart`)

| Symbol | Loại |
|--------|------|
| `AppCore` | Bootstrap |
| `CoreConfig`, `NetworkConfig`, `PresentationConfig` | Config |
| `HttpClientFactory`, `registerHttpClient` | HTTP |
| `ApiCode`, `ApiResponse`, `FieldError`, `ApiClient` | Envelope REST |
| `ApiError`, `NetworkErrorMapper`, `DefaultNetworkErrorMapper` | Lỗi mạng |
| `DependencyLocator`, `configureDependencies`, `register*Override` | DI |
| `DependencyOverrideModule` | DI module |
| `AppBloc`, `AppCubit`, `BlocEvent` | State |
| `BlocHostPage`, `CubitHostPage`, `AppBlocPage`, `AppCubitPage` | UI |
| `AppResult`, `AppSuccess`, `AppFailure`, `AppResultX` | Result |

---

## 12. Kiểm thử

Trong test, gọi `tearDown` để reset trạng thái toàn cục:

```dart
tearDown(() async {
  await AppCore.reset();
});
```

Có thể dùng `GetIt.asNewInstance()` với `locator:` riêng khi test DI override.

Chạy test:

```bash
flutter test
```

Các nhóm test hiện có: `AppCore`, `HttpClientFactory`, `DefaultNetworkErrorMapper`, `ApiError`, dependency registry, `AppResult`.

---

## 13. Ví dụ tích hợp đầy đủ

```dart
// main.dart
void main() {
  final config = CoreConfig(
    network: NetworkConfig(
      baseUrl: 'https://api.example.com/',
      headerProvider: () async => {'Authorization': 'Bearer $token'},
      enableLogging: kDebugMode,
    ),
    presentation: const PresentationConfig(
      errorDialogTitle: 'Thông báo lỗi',
      errorDialogCloseLabel: 'Đóng',
    ),
  );

  AppCore.initialize(config, setup: (locator) {
    registerHttpClient(config.network, locator: locator);
    configureDependencies(
      manualRegistration: (locator) {
        locator.registerLazySingleton<ProfileRepository>(
          () => ProfileRepository(locator<Dio>()),
        );
      },
      locator: locator,
    );
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc(AppCore.locator())),
      ],
      child: const MaterialApp(home: ProfilePage()),
    ),
  );
}
```

---

## Ghi chú mở rộng

- **Injectable / code-gen**: Gọi `getIt.init()` (hoặc tương đương) bên trong `manualRegistration` của `configureDependencies`.
- **Mapper tùy chỉnh**: Implement `NetworkErrorMapper` nếu API trả format lỗi khác `message` / `error`.
- **Không dùng dialog**: Đặt `reportError: false` trong `guard()` và tự xử lý state lỗi trong Bloc.
- **Publish**: Package hiện `homepage` trống trong `pubspec.yaml` — cập nhật khi đưa lên pub.dev hoặc git dependency.

---

*Tài liệu tương ứng mã nguồn phiên bản `0.1.0`.*
