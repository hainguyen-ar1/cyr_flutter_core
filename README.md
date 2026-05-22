# cyr_flutter_core

Shared Flutter core library: configurable HTTP client, Bloc/Cubit base classes, dependency injection helpers, and error UI.

## Setup in host app

```yaml
dependencies:
  cyr_flutter_core:
    path: ../cyr_flutter_core
```

```dart
import 'package:cyr_flutter_core/cyr_flutter_core.dart';

void main() {
  final config = CoreConfig(
    network: NetworkConfig(
      baseUrl: 'https://api.example.com/',
      headerProvider: () async => {'Authorization': 'Bearer $token'},
    ),
    presentation: const PresentationConfig(
      errorDialogTitle: 'Error',
      connectionErrorMessage: 'Connection failed. Try again.',
    ),
  );

  AppCore.initialize(
    config,
    setup: (locator) {
      registerHttpClient(config.network, locator: locator);
      // injectable: getIt.init(); or manual registrations
      configureDependencies(
        manualRegistration: (locator) {
          // locator.init() from generated code
        },
        locator: locator,
      );
    },
  );

  runApp(const MyApp());
}
```

## Bloc

```dart
class ProfileBloc extends AppBloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState.initial());

  Future<void> onLoad() => guard(() async {
    // ...
  });
}
```

## Page with error dialog

```dart
class ProfilePage extends BlocHostPage {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends BlocHostPageState<ProfilePage> {
  @override
  Stream<String> get errorStream => context.read<ProfileBloc>().errorStream;

  @override
  Widget buildPage(BuildContext context) => /* ... */;
}
```

## Structure

```
lib/src/
  app_core.dart
  config/
  bloc/
  network/
  di/
  presentation/
  result/
```
