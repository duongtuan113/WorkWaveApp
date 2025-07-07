// import 'package:dio/dio.dart';
// import 'package:project/api/models/project/createProjectModel.dart';
// import 'package:project/api/models/project/projectModel.dart';
//
// class ProjectService {
//   final Dio _dio;
//   ProjectService(this._dio); // <-- inject Dio có AuthInterceptor
//
//   Future<List<Project>> fetchProjects(String accessToken) async {
//     try {
//       final response = await _dio.get(
//         '/users/projects',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $accessToken',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       final List data = response.data['data'];
//       return data.map((json) => Project.fromJson(json)).toList();
//     } catch (e) {
//       throw Exception('Failed to load projects: $e');
//     }
//   }
//
//   Future<Project> fetchProjectById(String accessToken, String projectId) async {
//     final projects = await fetchProjects(accessToken);
//     try {
//       return projects.firstWhere((p) => p.projectId == projectId);
//     } catch (e) {
//       throw Exception('Project not found');
//     }
//   }
//
//   Future<CreateProject> createProject(
//       String accessToken, Map<String, dynamic> projectData) async {
//     try {
//       final response = await _dio.post(
//         '/users/projects',
//         data: projectData,
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $accessToken',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//       return CreateProject.fromJson(response.data['data']);
//     } catch (e) {
//       print("Error: $e");
//       throw Exception("Failed to create project: $e");
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:project/api/models/project/createProjectModel.dart';
import 'package:project/api/models/project/projectModel.dart';

class ProjectService {
  late Dio _dio;

  ProjectService(Dio dio) {
    _dio = dio;
  }
  void updateDio(Dio dio) {
    _dio = dio;
  }

  Future<List<Project>> fetchProjects() async {
    try {
      final response = await _dio.get(
        '/users/projects',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print("🛰️ Response data: ${response.data}");
      print(
          "📡 GET /users/projects => ${response.statusCode}, data: ${response.data}");
      final List data = response.data['data'];
      return data.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  Future<Project> fetchProjectById(String projectId) async {
    final projects = await fetchProjects();
    try {
      return projects.firstWhere((p) => p.projectId == projectId);
    } catch (e) {
      throw Exception('Project not found');
    }
  }

  Future<CreateProject> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await _dio.post(
        '/users/projects',
        data: projectData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return CreateProject.fromJson(response.data['data']);
    } catch (e) {
      print("Error: $e");
      throw Exception("Failed to create project: $e");
    }
  }
}
