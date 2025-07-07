// import 'package:dio/dio.dart';
// import 'package:project/api/controllers/auth_controller.dart';
// import 'package:project/global.dart'; // Chứa navigatorKey
//
// class AuthInterceptor extends Interceptor {
//   final AuthController authController;
//   final Dio dio;
//
//   bool _isRefreshing = false; // ✅ Tránh gọi refresh song song
//
//   AuthInterceptor(this.authController, this.dio);
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     final token = authController.accessToken;
//
//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//
//     print('🚀 Sending Request: ${options.method} ${options.path}');
//     super.onRequest(options, handler);
//   }
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     final originalRequest = err.requestOptions;
//     final isAuthEndpoint = originalRequest.path.contains('/auth');
//
//     // Chỉ xử lý nếu lỗi 401/403 và không phải gọi đến /auth
//     if ((err.response?.statusCode == 401 || err.response?.statusCode == 403) &&
//         !isAuthEndpoint) {
//       print('❗ Token expired or invalid. Attempting to refresh...');
//
//       // ✅ Nếu đang refresh thì bỏ qua
//       if (_isRefreshing) {
//         return handler.reject(err);
//       }
//
//       _isRefreshing = true;
//
//       try {
//         final refreshSuccess = await authController.refreshAccessToken();
//         _isRefreshing = false;
//
//         if (refreshSuccess) {
//           print('✅ Token refreshed. Retrying original request...');
//
//           final newToken = authController.accessToken;
//
//           final clonedRequest = originalRequest.copyWith(
//             headers: {
//               ...originalRequest.headers,
//               'Authorization': 'Bearer $newToken',
//             },
//           );
//
//           final response = await dio.fetch(clonedRequest);
//           return handler.resolve(response);
//         } else {
//           print('❌ Refresh failed. Logging out...');
//           _redirectToLogin();
//           return handler.reject(err);
//         }
//       } catch (e) {
//         _isRefreshing = false;
//         print('🔴 Error during token refresh: $e');
//         _redirectToLogin();
//         return handler.reject(err);
//       }
//     }
//
//     return super.onError(err, handler);
//   }
//
//   void _redirectToLogin() {
//     final context = navigatorKey.currentContext;
//     if (context != null) {
//       authController.logout(context);
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:project/api/controllers/auth_controller.dart';
import 'package:project/global.dart'; // Chứa navigatorKey

class AuthInterceptor extends Interceptor {
  final AuthController authController;
  final Dio dio;

  bool _isRefreshing = false;
  final List<void Function(String?)> _onTokenRefreshedCallbacks = [];

  AuthInterceptor(this.authController, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authController.accessToken;
    final isRefreshEndpoint = options.path.contains('/users/auth/refresh');

    if (!isRefreshEndpoint && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers.putIfAbsent('Content-Type', () => 'application/json');

    print('🚀 Sending Request: ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final originalRequest = err.requestOptions;
    final isAuthEndpoint = originalRequest.path.contains('/users/auth');
    final alreadyRetried = originalRequest.extra['retried'] == true;

    if ((err.response?.statusCode == 401 || err.response?.statusCode == 403) &&
        !isAuthEndpoint &&
        !alreadyRetried) {
      print('❗ Token expired or invalid. Attempting to refresh...');

      if (_isRefreshing) {
        _onTokenRefreshedCallbacks.add((newToken) async {
          if (newToken != null) {
            await _retryRequest(newToken, originalRequest, handler);
          } else {
            handler.reject(err);
          }
        });
        return;
      }

      _isRefreshing = true;

      try {
        final success = await authController.refreshAccessToken();
        final newToken = authController.accessToken;
        _isRefreshing = false;

        for (var cb in _onTokenRefreshedCallbacks) {
          cb(success ? newToken : null);
        }
        _onTokenRefreshedCallbacks.clear();

        if (success && newToken != null) {
          return await _retryRequest(newToken, originalRequest, handler);
        } else {
          _redirectToLogin();
          return handler.reject(err);
        }
      } catch (e) {
        _isRefreshing = false;
        for (var cb in _onTokenRefreshedCallbacks) {
          cb(null);
        }
        _onTokenRefreshedCallbacks.clear();
        _redirectToLogin();
        return handler.reject(err);
      }
    }

    return super.onError(err, handler);
  }

  Future<void> _retryRequest(String newToken, RequestOptions originalRequest,
      ErrorInterceptorHandler handler) async {
    try {
      final clonedRequest = originalRequest.copyWith(
        headers: {
          ...originalRequest.headers,
          'Authorization': 'Bearer $newToken',
        },
        extra: {
          ...originalRequest.extra,
          'retried': true,
        },
      );
      final response = await dio.fetch(clonedRequest);
      return handler.resolve(response);
    } catch (e) {
      print('❌ Retry failed: $e');
      return handler.reject(DioException(
        requestOptions: originalRequest,
        error: e,
        response: null,
        type: DioExceptionType.unknown,
      ));
    }
  }

  void _redirectToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      authController.logout(context);
    }
  }
}
