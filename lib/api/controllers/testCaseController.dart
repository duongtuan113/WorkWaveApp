import 'package:flutter/cupertino.dart';
import 'package:project/api/models/testcase/testCase.dart';
import 'package:project/api/services/apiTestCaseService.dart';

class TestCaseController extends ChangeNotifier {
  final TestCaseService _service;
  TestCaseController(this._service);
  List<TestCase> _testCase = [];
  bool _isLoading = false;
  String? _error;
  TestCase? _selectedTestCase;

  List<TestCase> get testCases => _testCase;
  TestCase? get selectedTestCase => _selectedTestCase;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTestCase(String projectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _testCase = await _service.fetchTestCasesByProject(projectId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTestCaseById(String projectId, int testCaseId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedTestCase =
          await _service.fetchTestCaseById(projectId, testCaseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
