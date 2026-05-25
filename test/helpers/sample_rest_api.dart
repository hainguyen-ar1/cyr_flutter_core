import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'sample_rest_api.g.dart';

@RestApi()
abstract class SampleRestApi {
  factory SampleRestApi(Dio dio, {String baseUrl}) = _SampleRestApi;

  @GET('/profile')
  Future<Map<String, Object?>> getProfile();

  @POST('/auth/login')
  Future<Map<String, Object?>> login(@Body() Map<String, Object?> body);

  @PUT('/profile')
  Future<Map<String, Object?>> updateProfile(@Body() Map<String, Object?> body);

  @PATCH('/counter')
  Future<int> patchCounter();

  @DELETE('/session')
  Future<void> deleteSession();

  @GET('/users/{id}')
  Future<dynamic> getUser(@Path('id') String id);
}
