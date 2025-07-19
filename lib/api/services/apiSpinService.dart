import 'package:dio/dio.dart';

import '../models/spin/spin.dart';

class SprintService {
  final Dio _dio;
  SprintService(this._dio);

  Future<List<Sprint>> fetchSprints(String projectId) async {
    final response = await _dio.get(
      '/projects/sprint',
      options: Options(headers: {
        'X-Project-Id': projectId,
      }),
    );

    dynamic body = response.data;

    if (response.statusCode == 200 &&
        body is Map &&
        body['status'] == 'SUCCESS' &&
        body['data'] is List) {
      final parsed =
          (body['data'] as List).map((e) => Sprint.fromJson(e)).toList();
      return parsed;
    } else {
      print("❌ Unexpected response format in fetchSprints: $body");
      throw Exception('Invalid response format');
    }
  }

  Future<int> getActiveSprintId(String projectId) async {
    final response = await _dio.get(
      '/projects/sprint',
      options: Options(headers: {
        'X-Project-Id': projectId,
      }),
    );

    dynamic body = response.data;

    if (response.statusCode == 200 && body is Map && body['data'] is List) {
      final sprints = body['data'] as List;
      final activeSprint = sprints.firstWhere(
        (sprint) => sprint['statusId'] == 1,
        orElse: () => null,
      );
      if (activeSprint != null) {
        return activeSprint['sprintId'];
      }
    }
    return 1;
  }
}
