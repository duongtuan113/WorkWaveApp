// import 'package:flutter/cupertino.dart';
//
// import '../models/spin/spin.dart';
// import '../services/apiSpinService.dart';
//
// class SprintController extends ChangeNotifier {
//   final SprintService _service = SprintService();
//   List<Sprint> _sprints = [];
//   Sprint? _selectedSprint;
//   bool _isLoading = false;
//
//   List<Sprint> get sprints => _sprints;
//   Sprint? get selectedSprint => _selectedSprint;
//   bool get isLoading => _isLoading;
//   void selectSprint(Sprint sprint) {
//     _selectedSprint = sprint;
//     notifyListeners();
//   }
//
//   Future<void> loadSprints(String token, String projectId) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final data = await _service.fetchSprints(token, projectId);
//
//       // ❗ Chỉ giữ lại các sprint có statusId == 2
//       _sprints = data.where((s) => s.statusId == 2).toList();
//
//       print('📦 Sprint list: $_sprints');
//
//       if (_sprints.isNotEmpty) {
//         _selectedSprint = _sprints.first;
//         print('✅ Selected sprint after load: ${_selectedSprint?.name}');
//       } else {
//         print('❌ No active sprint (statusId == 2) found');
//         _selectedSprint = null;
//       }
//
//       notifyListeners();
//     } catch (e) {
//       print('❌ Failed to load sprints: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// ✅ Lấy SprintId đang active hoặc trả về mặc định là 1
//   Future<int> getActiveSprintId(String token, String projectId) async {
//     try {
//       return await _service.getActiveSprintId(projectId, token);
//     } catch (e) {
//       print('⚠️ Lỗi khi lấy active sprint: $e');
//       return 1; // Mặc định fallback
//     }
//   }
//
//   Future<int?> fetchAndSetActiveSprintId(String projectId, String token) async {
//     try {
//       final activeSprintId = await _service.getActiveSprintId(projectId, token);
//       _selectedSprint = _sprints.firstWhere(
//         (s) => s.sprintId == activeSprintId,
//         orElse: () => Sprint(
//           sprintId: activeSprintId,
//           name: "Sprint $activeSprintId",
//           startDate: DateTime.now().toIso8601String(),
//           endDate: DateTime.now().add(Duration(days: 7)).toIso8601String(),
//           statusId: 1,
//           goal: "",
//           projectId: projectId,
//         ),
//       );
//       notifyListeners();
//       return activeSprintId;
//     } catch (e) {
//       print('⚠️ Lỗi khi lấy active sprint: $e');
//       return null;
//     }
//   }
// }
import 'package:flutter/cupertino.dart';

import '../models/spin/spin.dart';
import '../services/apiSpinService.dart';

class SprintController extends ChangeNotifier {
  final SprintService _service;
  SprintController(this._service);

  List<Sprint> _sprints = [];
  Sprint? _selectedSprint;
  bool _isLoading = false;

  List<Sprint> get sprints => _sprints;
  Sprint? get selectedSprint => _selectedSprint;
  bool get isLoading => _isLoading;
  Sprint? get currentSprint => _selectedSprint;

  void selectSprint(Sprint sprint) {
    _selectedSprint = sprint;
    notifyListeners();
  }

  Future<void> loadAllSprints(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchSprints(projectId);
      _sprints = data;
      print('📦 All sprint list: $_sprints');

      if (_sprints.isNotEmpty) {
        _selectedSprint = _sprints.first;
      } else {
        _selectedSprint = null;
      }
    } catch (e) {
      print('❌ Failed to load all sprints: $e');
      _sprints = [];
      _selectedSprint = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveSprintsOnly(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchSprints(projectId);
      _sprints = data.where((s) => s.statusId == 2).toList();
      print('📦 Active sprint list (statusId==2): $_sprints');

      if (_sprints.isNotEmpty) {
        _selectedSprint = _sprints.first;
      } else {
        _selectedSprint = null;
      }
    } catch (e) {
      print('❌ Failed to load active sprints: $e');
      _sprints = [];
      _selectedSprint = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getActiveSprintId(String projectId) async {
    try {
      return await _service.getActiveSprintId(projectId);
    } catch (e) {
      print('⚠️ Lỗi khi lấy active sprint: $e');
      return 1; // Mặc định fallback
    }
  }

  Future<int?> fetchAndSetActiveSprintId(String projectId) async {
    try {
      final activeSprintId = await _service.getActiveSprintId(projectId);
      _selectedSprint = _sprints.firstWhere(
        (s) => s.sprintId == activeSprintId,
        orElse: () => Sprint(
          sprintId: activeSprintId,
          name: "Sprint $activeSprintId",
          startDate: DateTime.now().toIso8601String(),
          endDate:
              DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          statusId: 1,
          goal: "",
          projectId: projectId,
        ),
      );
      notifyListeners();
      return activeSprintId;
    } catch (e) {
      print('⚠️ Lỗi khi lấy active sprint: $e');
      return null;
    }
  }
}
