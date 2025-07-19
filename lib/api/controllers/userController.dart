import 'package:flutter/material.dart';

import '../models/user/user.dart';
import '../models/user/userByIdModel.dart';
import '../services/apiUserService.dart';

class UserController extends ChangeNotifier {
  final UserService _service;
  UserController(this._service);
  List<UserByIdModel> _projectMembers = [];

  UserService get service => _service;
  List<String> getUserIds() => _userCache.keys.toList();

  final Map<String, UserByIdModel> _userCache = {};
  bool _isFetchingUsers = false;

  bool _isRegistering = false;
  String? _registrationError;

  List<UserByIdModel> get projectMembers => _projectMembers;
  bool get isFetchingUsers => _isFetchingUsers;
  bool get isRegistering => _isRegistering;
  String? get registrationError => _registrationError;

  UserByIdModel? getUserById(String? userId) {
    if (userId == null) return null;
    return _userCache[userId];
  }

  String getUserName(String? userId) {
    if (userId == null || userId.isEmpty) return "Unassigned";
    return _userCache[userId]?.userName ?? userId;
  }

  Future<void> fetchUsers(Set<String> userIds) async {
    final idsToFetch =
        userIds.where((id) => !_userCache.containsKey(id)).toSet();

    print("👤 [UserController] Bắt đầu fetch users: $idsToFetch");

    if (idsToFetch.isEmpty) {
      print("ℹ️ Tất cả user đã có trong cache. Không cần fetch.");
      return;
    }

    _isFetchingUsers = true;
    notifyListeners();

    List<Future> futures = [];
    for (String id in idsToFetch) {
      futures.add(_service.fetchUserById(id).then((user) {
        print("✅ Fetched user: ${user.userId} - ${user.userName}");
        if (user.userName != 'Unknown') {
          _userCache[id] = user;
        } else {
          print("⚠️ User $id có userName là 'Unknown' → không cache");
        }
      }).catchError((e) {
        print("❌ Lỗi khi tải user $id: $e");
      }));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    _isFetchingUsers = false;
    notifyListeners();
  }

  Future<bool> register(User user) async {
    _isRegistering = true;
    _registrationError = null;
    notifyListeners();

    try {
      bool isSuccess = await _service.registerUser(user);
      _isRegistering = false;
      notifyListeners();
      return isSuccess;
    } catch (e) {
      _registrationError = e.toString();
      _isRegistering = false;
      notifyListeners();
      print("Error in UserController (register): $e");
      throw e;
    }
  }

  Future<void> fetchUserByIdOnce(String userId) async {
    if (userId.trim().isEmpty || _userCache.containsKey(userId)) {
      return;
    }

    try {
      final user = await _service.fetchUserById(userId);
      _userCache[userId] = user;
      notifyListeners();
    } catch (e) {
      print("❌ fetchUserByIdOnce error for $userId: $e");
    }
  }

  Future<void> loadProjectMembers({
    required String projectId,
    required String token,
  }) async {
    try {
      final members = await _service.fetchProjectMembers(
        projectId: projectId,
        token: token,
      );
      _projectMembers = members;
      for (var member in members) {
        _userCache[member.userId] = member;
      }
      notifyListeners();
    } catch (e) {
      print("❌ loadProjectMembers failed: $e");
    }
  }
}
