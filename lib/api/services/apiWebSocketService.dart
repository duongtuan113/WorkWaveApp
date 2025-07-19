import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'notification_service.dart';

typedef WebSocketMessageHandler = void Function(String eventType, dynamic data);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();

  late StompClient _stompClient;
  bool _isConnected = false;
  bool _hasActivated = false;
  WebSocketMessageHandler? _messageHandler;

  void connect({WebSocketMessageHandler? onMessage}) {
    if (_isConnected || _hasActivated) return;

    if (onMessage != null) {
      _messageHandler = onMessage;
    }

    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://192.168.0.104:8086/ws',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          _isConnected = false;
          _hasActivated = false;
          print('🔴 WebSocket Error: $error');

          Future.delayed(const Duration(seconds: 5), () {
            print('🔁 Retrying WebSocket connection...');
            connect(onMessage: _messageHandler);
          });
        },
        onDisconnect: (_) {
          _isConnected = false;
          _hasActivated = false;
          print('🔌 Disconnected from WebSocket');
        },
        onStompError: (frame) {
          print('❌ STOMP Error: ${frame.body}');
        },
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient.activate();
    _hasActivated = true;
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    print('✅ WebSocket connected');
    _resubscribe();
  }

  void _resubscribe() {
    _subscribe('/topic/userstory-created', 'userstory-created');
    _subscribe('/topic/userstory-updated', 'userstory-updated');
    _subscribe('/topic/userstory-deleted', 'userstory-deleted');

    _subscribe('/topic/project-created', 'project-created');
    _subscribe('/topic/project-updated', 'project-updated');
    _subscribe('/topic/project-deleted', 'project-deleted');
  }

  dynamic _parseFrameBody(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (e) {
      print('⚠️ JSON decode error: $e');
      return body;
    }
  }

  /// ✅ Cho phép thay đổi handler sau khi kết nối
  void setMessageHandler(WebSocketMessageHandler handler) {
    _messageHandler = handler;
    if (_isConnected) {
      _resubscribe();
    }
  }

  void disconnect() {
    if (_isConnected) {
      print('🧨 Disconnect called from:\n${StackTrace.current}');
      _stompClient.deactivate();
      _isConnected = false;
      _hasActivated = false;
      print('🔌 WebSocket disconnected manually');
    }
  }

  void _subscribe(String destination, String eventType) {
    _stompClient.subscribe(
      destination: destination,
      callback: (frame) {
        final data = _parseFrameBody(frame.body);
        NotificationService().showNotification(
          'Sự kiện $eventType',
          data is Map && data['message'] != null
              ? data['message']
              : 'Bạn có thông báo mới',
        );

        _messageHandler?.call(eventType, data);
      },
    );
  }

  bool get isConnected => _isConnected;
}
