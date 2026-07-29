/// Shared Flutter core: network, bloc, DI, and presentation helpers.
library;

export 'src/app_core.dart';
export 'src/bloc/app_bloc.dart';
export 'src/bloc/app_cubit.dart';
export 'src/bloc/bloc_event.dart';
export 'src/config/core_config.dart';
export 'src/config/network_config.dart';
export 'src/config/presentation_config.dart';
export 'src/di/dependency_locator.dart';
export 'src/di/dependency_override_module.dart';
export 'src/di/dependency_registry.dart';
export 'src/network/api_envelope.dart';
export 'src/network/api_code.dart';
export 'src/network/api_error.dart';
export 'src/network/api_response.dart';
export 'src/network/field_error.dart';
export 'src/network/http_client_factory.dart';
export 'src/network/interceptors/api_envelope_interceptor.dart';
export 'src/network/interceptors/request_id_interceptor.dart';
export 'src/network/network_error_mapper.dart';
export 'package:retrofit/retrofit.dart'
    show Body, DELETE, GET, Headers, PATCH, POST, PUT, Path, Query, RestApi;
export 'src/network/register_http_client.dart';
export 'src/network/rest_api_factory.dart';
export 'src/presentation/bloc_host_page.dart';
export 'src/presentation/error_dialog_mixin.dart';
export 'src/result/app_result.dart';
