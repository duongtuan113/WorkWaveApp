import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global.dart';
import '../controllers/projectController.dart';
import '../controllers/userController.dart';
import '../models/login/authenticationRequest.dart';
import '../models/login/authenticationResponse.dart';
import '../models/user/userByIdModel.dart';
import '../services/apiLoginService.dart';
import '../services/apiWebSocketService.dart';
import '../utils/jwt_utils.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController with ChangeNotifier {
  final ApiLoginService _apiLoginService;
  final UserController _userController;
  final WebSocketService _ws;

  Dio get dioClient => _apiLoginService.dio;

  AuthenticationResponse? _loggedInUser;
  AuthStatus _status = AuthStatus.unknown;
  Timer? _refreshTimer;
  final Completer<void> _initialized = Completer<void>();
  UserByIdModel? _currentUser;

  AuthenticationResponse? get loggedInUser => _loggedInUser;
  AuthStatus get status => _status;
  String? get accessToken => _loggedInUser?.accessToken;
  UserByIdModel? get currentUser => _currentUser;

  AuthController(
    this._apiLoginService,
    this._userController,
    this._ws,
  ) {
    _loadTokensFromStorage().then((_) {
      if (!_initialized.isCompleted) _initialized.complete();
    }).catchError((e) {
      if (!_initialized.isCompleted) _initialized.completeError(e);
    });
  }

  Future<void> get initialized => _initialized.future;

  Future<void> _saveAuthDataToStorage(AuthenticationResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_data', jsonEncode(response.toJson()));
  }

  Future<void> _loadTokensFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authDataString = prefs.getString('auth_data');

    if (authDataString != null) {
      try {
        final authDataJson = jsonDecode(authDataString);
        final storedResponse =
            AuthenticationResponse.fromStorageJson(authDataJson);

        if (storedResponse.refreshToken.isNotEmpty) {
          _loggedInUser = storedResponse;
          _status = AuthStatus.authenticated;
          _startTokenRefreshTimer(storedResponse.expiresIn ?? 900);
          await _loadCurrentUser(storedResponse.userId);
        } else {
          await _clearAuthDataFromStorage(calledFrom: 'load_empty_token');
        }
      } catch (e) {
        await _clearAuthDataFromStorage(calledFrom: 'load_corrupted_data');
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> _loadCurrentUser(String? userId) async {
    if (userId != null && accessToken != null && accessToken!.isNotEmpty) {
      try {
        final user = await _userController.service.fetchUserById(userId);
        _currentUser = user;
      } catch (e) {
        print("❌ Lỗi khi tải thông tin user: $e");
      }
    }
  }

  Future<AuthenticationResponse> login(String email, String password) async {
    try {
      final request = AuthenticationRequest(email: email, password: password);
      final response = await _apiLoginService.login(request);

      if (response.login) {
        final userId = extractUserIdFromJwt(response.accessToken);
        final expiresIn = extractExpiryInFromJwt(response.accessToken);

        final updatedResponse = AuthenticationResponse(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          login: true,
          message: response.message,
          expiresIn: expiresIn,
          userId: userId,
        );

        _loggedInUser = updatedResponse;
        _status = AuthStatus.authenticated;
        _startTokenRefreshTimer(expiresIn ?? 900);
        await _saveAuthDataToStorage(updatedResponse);
        await _loadCurrentUser(userId);
        print("💾 Saved Auth: ${jsonEncode(updatedResponse.toJson())}");
        notifyListeners();
        return updatedResponse;
      } else {
        await _clearAuthDataFromStorage(calledFrom: 'login_failed');
        _loggedInUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return AuthenticationResponse(
          accessToken: '',
          refreshToken: '',
          login: false,
          message: response.message ?? 'Sai tài khoản hoặc mật khẩu',
        );
      }
    } catch (e) {
      await _clearAuthDataFromStorage(calledFrom: 'login_system_error');
      _loggedInUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return AuthenticationResponse(
        accessToken: '',
        refreshToken: '',
        login: false,
        message: 'Lỗi hệ thống: $e',
      );
    }
  }

  void _startTokenRefreshTimer(int expiresIn) {
    if (expiresIn <= 60) {
      print('⚠️ Token expires too soon. Skipping refresh timer setup.');
      return;
    }

    _refreshTimer?.cancel();
    final refreshBefore = Duration(seconds: expiresIn - 60);
    _refreshTimer = Timer(refreshBefore, () async {
      if (_status == AuthStatus.authenticated) {
        final success = await refreshAccessToken();
        if (!success) navigatorKey.currentContext?.go('/login');
      }
    });
  }

  Future<bool> refreshAccessToken() async {
    final token = _loggedInUser?.refreshToken;
    print("🔍 [RefreshAccessToken] Token được lấy từ storage: $token");

    if (token == null || token.isEmpty) {
      await _clearAuthDataFromStorage(calledFrom: 'refresh_no_token');
      _loggedInUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    try {
      final response = await _apiLoginService.refreshToken(token);
      if (response.login) {
        final updated = AuthenticationResponse(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          login: true,
          message: response.message,
          expiresIn: response.expiresIn,
          userId: extractUserIdFromJwt(response.accessToken),
        );
        _loggedInUser = updated;
        _status = AuthStatus.authenticated;
        await _saveAuthDataToStorage(updated);
        _startTokenRefreshTimer(updated.expiresIn ?? 900);
        await _loadCurrentUser(updated.userId);
        notifyListeners();
        return true;
      } else {
        await _handleRefreshFailure('refresh_api_failure');
        return false;
      }
    } catch (e) {
      await _handleRefreshFailure('refresh_api_error');
      return false;
    }
  }

  Future<void> _handleRefreshFailure(String reason) async {
    await _clearAuthDataFromStorage(calledFrom: reason);
    _loggedInUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        context.go('/login');
      } catch (e) {
        print("❌ GoRouter navigation error: $e");
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    // 1. Ngắt WebSocket
    _ws.disconnect();

    // 2. Xoá token khỏi storage
    await _clearAuthDataFromStorage(calledFrom: 'logout');

    // 3. Xoá user hiện tại và reset các controller liên quan
    _currentUser = null;
    _loggedInUser = null;
    _status = AuthStatus.unauthenticated;
    context.read<ProjectController>().clearProjects();

    notifyListeners();

    // 4. Điều hướng sang trang login
    if (context.mounted) {
      context.go('/login');
    } else {
      final navContext = navigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        navContext.go('/login');
      } else {
        print("❌ Không tìm thấy context để điều hướng về trang đăng nhập.");
      }
    }
  }

  Future<void> _clearAuthDataFromStorage(
      {String calledFrom = 'Unknown'}) async {
    print("🧹 Clearing auth from storage due to: $calledFrom");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
    _refreshTimer?.cancel();
  }
}
