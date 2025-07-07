import 'package:dio/dio.dart';

import '../models/user/user.dart';
import '../models/user/userByIdModel.dart';

class UserService {
  final Dio _dio;
  UserService(this._dio);

  /// Đăng ký một người dùng mới.
  Future<bool> registerUser(User user) async {
    try {
      final response =
          await _dio.post('/users/auth/register', data: user.toJson());
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final responseBody = e.response?.data;
        if (responseBody != null && responseBody['errorCode'] == '1002') {
          throw 'Tài khoản đã tồn tại. Vui lòng chọn tên người dùng hoặc email khác.';
        }
      }
      print('Register failed: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      print("An unexpected error occurred during registration: $e");
      return false;
    }
  }

  /// Lấy thông tin chi tiết của một người dùng bằng ID.
  // ✅ SỬA LẠI: Bỏ tham số token không cần thiết
  // Future<UserByIdModel> fetchUserById(String userId) async {
  //   try {
  //     // DioClient sẽ tự động thêm token vào header
  //     final response = await _dio.get('/users/customer/$userId');
  //     print("📥 Dữ liệu trả về cho userId $userId: ${response.data}");
  //
  //     if (response.statusCode == 200 && response.data['status'] == 'success') {
  //       return UserByIdModel.fromJson(response.data['data']);
  //     } else {
  //       throw Exception(
  //           'Failed to load user data with status ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     print('Error fetching user $userId: ${e.message}');
  //     return UserByIdModel(userId: userId, userName: 'Unknown', email: '');
  //   } catch (e) {
  //     print('Unexpected error fetching user $userId: $e');
  //     return UserByIdModel(userId: userId, userName: 'Unknown', email: '');
  //   }
  // }
  Future<UserByIdModel> fetchUserById(String userId) async {
    if (userId.trim().isEmpty) {
      print('⚠️ userId is empty → skip fetchUserById');
      return UserByIdModel(userId: '', userName: 'Unknown', email: '');
    }

    try {
      final response = await _dio.get('/users/customer/$userId');
      print("📥 Dữ liệu trả về cho userId $userId: ${response.data}");

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return UserByIdModel.fromJson(response.data['data']);
      } else {
        throw Exception(
            'Failed to load user data with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error fetching user $userId: ${e.message}');
      return UserByIdModel(userId: userId, userName: 'Unknown', email: '');
    } catch (e) {
      print('❌ Unexpected error fetching user $userId: $e');
      return UserByIdModel(userId: userId, userName: 'Unknown', email: '');
    }
  }

  Future<List<UserByIdModel>> fetchProjectMembers({
    required String projectId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/users/members',
        options: Options(
          headers: {
            'X-Project-Id': projectId,
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => UserByIdModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch project members');
      }
    } catch (e) {
      print('❌ Unexpected error fetchProjectMembers: $e');
      rethrow;
    }
  }
  // Future<List<UserByIdModel>> fetchAllUsers() async {
  //   try {
  //     final response = await _dio.get('/users/customer');
  //     if (response.statusCode == 200 && response.data['status'] == 'success') {
  //       final List<dynamic> data = response.data['data'];
  //       return data.map((json) => UserByIdModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to fetch all users');
  //     }
  //   } on DioException catch (e) {
  //     print(
  //         '❌ DioException khi gọi fetchAllUsers: ${e.response?.statusCode} - ${e.message}');
  //     return [];
  //   } catch (e) {
  //     print('❌ Lỗi không xác định khi gọi fetchAllUsers: $e');
  //     return [];
  //   }
  // }
  // Future<List<UserByIdModel>> fetchProjectMembers(String projectId) async {
  //   try {
  //     final response = await _dio.get(
  //       '/users/members',
  //       options: Options(
  //         headers: {
  //           'X-Project-Id': projectId,
  //         },
  //       ),
  //     );
  //
  //     if (response.statusCode == 200 && response.data['status'] == 'success') {
  //       final List<dynamic> data = response.data['data'];
  //       return data.map((json) => UserByIdModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to fetch project members');
  //     }
  //   } on DioException catch (e) {
  //     print('❌ DioException fetchProjectMembers: ${e.message}');
  //     return [];
  //   } catch (e) {
  //     print('❌ Unexpected error fetchProjectMembers: $e');
  //     return [];
  //   }
  // }
}
