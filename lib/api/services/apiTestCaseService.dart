import 'package:dio/dio.dart';
import 'package:project/api/models/testcase/testCase.dart';

class TestCaseService {
  final Dio _dio;
  TestCaseService(this._dio);
  Future<List<TestCase>> fetchTestCasesByProject(String projectId) async {
    try {
      final response = await _dio.get('/tests/testcases/project/$projectId',
          options: Options(headers: {
            'X-Project-Id': projectId,
          }));
      final List data = response.data["data"];
      return data.map((json) => TestCase.fromJson(json)).toList();
    } catch (e) {
      throw Exception("khong lay duoc testcase service");
    }
  }

  Future<TestCase> fetchTestCaseById(String projectId, int testCaseId) async {
    final response = await _dio.get('/tests/testcases/$testCaseId',
        options: Options(headers: {
          'X-Project-Id': projectId,
        }));
    return TestCase.fromJson(response.data['data']);
  }
}
