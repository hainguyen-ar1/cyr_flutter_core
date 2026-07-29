import 'package:cyr_flutter_core/cyr_flutter_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapCore();
  runApp(const ExampleApp());
}

void bootstrapCore() {
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
      locator.registerLazySingleton(
        () => ExampleRepository(locator<Dio>()),
      );
    },
  );
}

class ExampleRepository {
  const ExampleRepository(this._dio);

  final Dio _dio;

  Future<AppResult<Map<String, dynamic>>> health() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/health');
      return AppSuccess(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      return AppFailure(ApiError.fromDioException(error));
    }
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cyr_flutter_core example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  late final ExampleRepository _repository;
  AppResult<Map<String, dynamic>>? _result;

  @override
  void initState() {
    super.initState();
    _repository = AppCore.locator<ExampleRepository>();
  }

  Future<void> _loadHealth() async {
    final result = await _repository.health();
    if (mounted) {
      setState(() => _result = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('cyr_flutter_core')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: _loadHealth,
                child: const Text('Call /health'),
              ),
              const SizedBox(height: 16),
              Text(
                switch (result) {
                  AppSuccess(:final value) => 'Success: $value',
                  AppFailure(:final error) => 'Failure: ${error.message}',
                  null => 'Tap the button to call the configured API.',
                },
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
