// lib/api/dio_notification_client.dart
import 'package:dio/dio.dart';

class DioNotificationClient {
  final Dio dio;

  DioNotificationClient()
      : dio = Dio(
          BaseOptions(
            baseUrl:
                // 'http://localhost:8086', // ⚠️ Đổi thành 10.0.2.2 nếu dùng Android Emulator
                'http://192.168.0.104:8086', // ✅ Địa chỉ IP của máy Mac trong mạng LAN
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
}
