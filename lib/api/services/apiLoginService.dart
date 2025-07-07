import 'package:dio/dio.dart';
import 'package:project/api/models/login/authenticationRequest.dart';
import 'package:project/api/models/login/authenticationResponse.dart';

import '../utils/jwt_utils.dart';

class ApiLoginService {
  final Dio _dio;

  ApiLoginService(this._dio); // ✅ Chỉ nhận Dio (không cần AuthController)

  Future<AuthenticationResponse> login(AuthenticationRequest request) async {
    try {
      final response = await _dio.post(
        '/users/auth/login',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final jsonResponse = response.data;
      final data = jsonResponse['data'] ?? {};

      return AuthenticationResponse(
        accessToken: data['accessToken'] ?? '',
        refreshToken: data['refreshToken'] ?? '',
        login: jsonResponse['status'] == 'success',
        message: jsonResponse['message'],
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Lỗi không xác định';
      return AuthenticationResponse(
        accessToken: '',
        refreshToken: '',
        login: false,
        message: 'Lỗi đăng nhập: $message',
      );
    }
  }

  // Future<AuthenticationResponse> refreshToken(String refreshToken) async {
  //   try {
  //     final response = await _dio.post(
  //       '/users/auth/refresh',
  //       options: Options(
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization':
  //               'Bearer $refreshToken', // ✅ GỬI refreshToken ở header
  //         },
  //       ),
  //     );
  //
  //     final jsonResponse = response.data;
  //     final data = jsonResponse['data'] ?? {};
  //
  //     final accessToken = data['accessToken'] ?? '';
  //     final newRefreshToken = data['refreshToken'] ?? '';
  //     final userId = extractUserIdFromJwt(accessToken);
  //     final expiresIn = extractExpiryInFromJwt(accessToken);
  //
  //     return AuthenticationResponse(
  //       accessToken: accessToken,
  //       refreshToken: newRefreshToken,
  //       login: jsonResponse['status'] == 'success',
  //       message: jsonResponse['message'],
  //       expiresIn: expiresIn,
  //       userId: userId,
  //     );
  //   } on DioException catch (e) {
  //     final message =
  //         e.response?.data['message'] ?? e.message ?? 'Lỗi không xác định';
  //     return AuthenticationResponse(
  //       accessToken: '',
  //       refreshToken: '',
  //       login: false,
  //       message: 'Làm mới token thất bại: $message',
  //     );
  //   }
  // }
  Future<AuthenticationResponse> refreshToken(String refreshToken) async {
    print("🚀 Đang gửi refreshToken: $refreshToken");
    try {
      final response = await _dio.post(
        '/users/auth/refresh',
        data: {'refreshToken': refreshToken}, // ✅ gửi trong body
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final jsonResponse = response.data;
      final data = jsonResponse['data'] ?? {};

      final accessToken = data['accessToken'] ?? '';
      final newRefreshToken = data['refreshToken'] ?? '';
      final userId = extractUserIdFromJwt(accessToken);
      final expiresIn = extractExpiryInFromJwt(accessToken);

      return AuthenticationResponse(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        login: jsonResponse['status'] == 'success',
        message: jsonResponse['message'],
        expiresIn: expiresIn,
        userId: userId,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Lỗi không xác định';
      return AuthenticationResponse(
        accessToken: '',
        refreshToken: '',
        login: false,
        message: 'Làm mới token thất bại: $message',
      );
    }
  }

  Dio get dio => _dio;
}
