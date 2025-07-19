import 'package:dio/dio.dart';
import 'package:project/api/models/bug/bug.dart';

class BugService {
  final Dio _dio;
  BugService(this._dio);
  // Future<List<Bug>> fetchBugByProject(String projectId) async {
  //   try {
  //     final response = await _dio.get('/bugs/bug/projects/$projectId/bugs',
  //         options: Options(headers: {
  //           'X-Project-Id': projectId,
  //         }));
  //     final List data = response.data['data'];
  //     return data.map((json) => Bug.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception("khong lay duoc Bug service");
  //   }
  // }
  Future<List<Bug>> fetchBugByProject(String projectId, String token) async {
    try {
      final response = await _dio.get(
        '/bugs/bug/projects/$projectId/bugs',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'X-Project-Id': projectId,
        }),
      );
      print("BUG RESPONSE: ${response.data}");
      final List data = response.data['data'];
      for (var json in data) {
        print("BUG ITEM: $json");
      }
      final bugs = data
          .map((json) {
            try {
              return Bug.fromJson(json);
            } catch (e) {
              print("Parse error: $e");
              return null;
            }
          })
          .whereType<Bug>()
          .toList();
      print("Parsed bugs: $bugs");
      return bugs;
    } catch (e) {
      print("Fetch Bug Error: $e");
      throw Exception("Không lấy được Bug service: $e");
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
