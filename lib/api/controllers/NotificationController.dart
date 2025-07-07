// import 'package:flutter/material.dart';
//
// import '../models/Notification/NotificationModel.dart';
// import '../services/apiNotificationService.dart';
//
// class NotificationController extends ChangeNotifier {
//   final ApiNotificationService apiService;
//   List<NotificationModel> _notifications = [];
//
//   NotificationController(this.apiService);
//
//   List<NotificationModel> get notifications => _notifications;
//
//   Future<void> load(String userId) async {
//     _notifications = await apiService.fetchNotifications(userId);
//     notifyListeners();
//   }
//
//   Future<void> markAllAsRead(String userId) async {
//     await apiService.markAllAsRead(userId);
//     await load(userId);
//   }
//
//   Future<void> markAsReadById(String notificationId) async {
//     final index = _notifications.indexWhere((n) => n.id == notificationId);
//     if (index != -1) {
//       _notifications[index] = _notifications[index].copyWith(read: true);
//       notifyListeners();
//     }
//   }
//
//   void deleteNotification(String id) {
//     _notifications.removeWhere((n) => n.id == id);
//     notifyListeners();
//     // Nếu cần gọi API delete backend, bạn thêm ở đây
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../models/Notification/NotificationModel.dart';
import '../services/apiNotificationService.dart';

class NotificationController extends ChangeNotifier {
  final ApiNotificationService apiService;
  List<NotificationModel> _notifications = [];

  late StompClient _stompClient;
  bool _isConnected = false;

  NotificationController(this.apiService);

  List<NotificationModel> get notifications => _notifications;

  Future<void> load(String userId) async {
    _notifications = await apiService.fetchNotifications(userId);
    notifyListeners();
  }

  Future<void> markAllAsRead(String userId) async {
    await apiService.markAllAsRead(userId);
    await load(userId);
  }

  Future<void> markAsReadById(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
    }
  }

  void deleteNotification(String id) async {
    try {
      await apiService.deleteNotification(id); // 👈 gọi API xóa trên backend
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Failed to delete notification: $e");
    }
  }

  void connectWebSocket(String userId) {
    if (_isConnected) return;

    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://192.168.0.104:8086/ws', // ✅ Đã đổi thành IP thật
        onConnect: (StompFrame frame) {
          _isConnected = true;
          _stompClient.subscribe(
            destination: '/topic/notification-created-$userId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final jsonData = jsonDecode(frame.body!);
                print("📥 Received WebSocket data: $jsonData"); // ✅ Log debug
                final notification = NotificationModel.fromJson(jsonData);
                _notifications.insert(0, notification);
                notifyListeners();
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          debugPrint('❌ WebSocket error: $error');
        },
        onStompError: (dynamic error) {
          debugPrint('❌ STOMP error: $error');
        },
        onDisconnect: (frame) {
          _isConnected = false;
        },
      ),
    );

    _stompClient.activate();
  }

  void disconnectWebSocket() {
    if (_isConnected) {
      _stompClient.deactivate();
      _isConnected = false;
    }
  }
}
