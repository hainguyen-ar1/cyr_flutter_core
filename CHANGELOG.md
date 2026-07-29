## 0.1.0

Initial public release.

* Added `AppCore`, `CoreConfig`, `NetworkConfig`, and `PresentationConfig` for host app bootstrap.
* Added Dio HTTP client registration with request IDs, dynamic headers, logging, and envelope unwrapping.
* Added Retrofit API registration helpers for `GetIt`.
* Added normalized `ApiError`, `ApiResponse`, `ApiEnvelope`, `FieldError`, and `ApiCode` models.
* Added `AppResult`, `AppSuccess`, and `AppFailure` for repository and use-case layers.
* Added `AppBloc`, `AppCubit`, `BlocHostPage`, and `ErrorDialogMixin` for shared state and error presentation.
