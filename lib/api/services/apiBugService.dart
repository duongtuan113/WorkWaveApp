import 'package:dio/dio.dart';
import 'package:project/api/models/bug/bug.dart';

class BugService {
  final Dio _dio;
  BugService(this._dio);
  Future<List<Bug>> fetchBugByProject(String projectId) async {
    try {
      final response = await _dio.get('/bugs/bug/projects/$projectId/bugs',
          options: Options(headers: {
            'X-Project-Id': projectId,
          }));
      final List data = response.data['data'];
      return data.map((json) => Bug.fromJson(json)).toList();
    } catch (e) {
      throw Exception("khong lay duoc Bug service");
    }
  }

  Future<Bug> fetchBugById(int bugId) async {
    try {
      final response = await _dio.get('/bugs/bug/$bugId');
      final data = response.data['data'];
      return Bug.fromJson(data);
    } catch (e) {
      throw Exception("Không lấy được bug $bugId: $e");
    }
  }
}
