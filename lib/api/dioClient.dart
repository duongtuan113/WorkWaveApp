import 'package:dio/dio.dart';
import 'package:project/api/controllers/auth_controller.dart';
import 'package:project/network/auth_interceptor.dart';

class DioClient {
  final Dio _dio;

  // DioClient({String baseUrl = 'http://localhost:8080'})
  DioClient({String baseUrl = 'http://192.168.0.104:8080'})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Dio get dio => _dio;

  // Gán AuthController và set lại interceptor
  void setAuthController(AuthController authController) {
    _dio.interceptors.clear();
    _dio.interceptors.add(AuthInterceptor(authController, _dio));
  }

  // Optional: thêm khả năng add interceptor khác sau này
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
