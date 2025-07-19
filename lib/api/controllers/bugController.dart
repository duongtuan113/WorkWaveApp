import 'package:flutter/material.dart';
import 'package:project/api/models/bug/bug.dart';
import 'package:project/api/services/apiBugService.dart';

class BugController extends ChangeNotifier {
  final BugService _service;
  BugController(this._service);
  bool _isLoading = false;
  List<Bug> _bug = [];
  String? _error;
  bool get isLoading => _isLoading;
  List<Bug> get bug => _bug;
  String? get error => _error;
  Bug? _currentBug;
  Bug? get currentBug => _currentBug;
  Future<void> loadBug(String projectId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bug = await _service.fetchBugByProject(projectId, token);
      print("Loaded bugs: $_bug");
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBugById(int bugId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentBug = await _service.fetchBugById(bugId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
