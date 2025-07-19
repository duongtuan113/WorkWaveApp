import 'package:dio/dio.dart';

import '../models/Notification/NotificationModel.dart';

class ApiNotificationService {
  final Dio _dio;

  ApiNotificationService(this._dio);

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final url = '/api/notifications';
    print('🔍 GET $url?userId=$userId');
    final response = await _dio.get(url, queryParameters: {
      'userId': userId,
    });

    return (response.data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  Future<void> markAllAsRead(String userId) async {
    final url = '/api/notifications/$userId/read';
    print('📝 PUT $url');
    await _dio.put(url);
  }

  Future<void> createNotification(
      String userId, String message, String type) async {
    final url = '/api/notifications';
    print('📬 POST $url');
    await _dio.post(url, data: {
      'userId': userId,
      'message': message,
      'type': type,
    });
  }

  Future<void> deleteNotification(String id) async {
    final response = await _dio.delete('/api/notifications/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }
}
