import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:project/api/models/project/createProjectModel.dart';
import 'package:project/api/models/project/projectModel.dart';
import 'package:project/api/services/apiProjectService.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _service;

  ProjectController(this._service);
  List<Project> _filteredProjects = [];
  List<Project> _projects = [];
  List<CreateProject> _createProject = [];
  bool _isLoading = false;
  String? _error;
  Project? _selectedProject;
  CreateProject? _selectedCreateProject;
  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;
  List<Project> get filteredProjects =>
      _filteredProjects.isNotEmpty || _hasLoadedOnce
          ? _filteredProjects
          : _projects;
  bool _disposed = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Project? get selectedProject => _selectedProject;
  void searchProjects(String query) {
    if (query.trim().isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      _filteredProjects = _projects
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              (p.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    }
    safeNotify();
  }

  void setSelectedProjectById(String projectId) {
    try {
      _selectedProject = _projects.firstWhere((p) => p.projectId == projectId);
      safeNotify();
    } catch (e) {
      print("Không tìm thấy project với ID: $projectId");
    }
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _service.fetchProjects();
      _hasLoadedOnce = true;

      if (fetched.isNotEmpty) {
        _projects = fetched;
        _filteredProjects = List.from(fetched);
        print("✅ Hiển thị ${_projects.length} project(s)");
      } else {
        print("⚠️ Dữ liệu rỗng, không ghi đè");
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print("❌ Error loading projects: $_error");
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  Future<Project> getProjectById(String projectId) async {
    try {
      return await _service.fetchProjectById(projectId);
    } catch (e) {
      throw Exception('Failed to load project: $e');
    }
  }

  Future<List<Project>> getProjects() async {
    try {
      return await _service.fetchProjects();
    } on DioException catch (dioError) {
      final errorMessage =
          dioError.response?.data['message'] ?? dioError.message;
      throw Exception('Failed to fetch projects: $errorMessage');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> createNewProject(Map<String, dynamic> projectData) async {
    _isLoading = true;
    safeNotify();

    try {
      final newProject = await _service.createProject(projectData);
      _createProject.add(newProject);
      _selectedCreateProject = newProject;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  void safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void updateDio(Dio dio) {
    _service.updateDio(dio);
  }

  void clearProjects() {
    _projects = [];
    _filteredProjects = [];
    notifyListeners();
  }
}
