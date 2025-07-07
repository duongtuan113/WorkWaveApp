import 'package:dio/dio.dart';
import 'package:project/api/models/userStory/userStory.dart';

import '../models/userStory/addUserStory.dart';

class UserStoryService {
  // Bỏ 'final Dio _dio = Dio();'
  final Dio _dio;
  // Thêm constructor để nhận Dio từ bên ngoài
  UserStoryService(this._dio);

  // Sửa lại các hàm để không cần truyền token nữa
  Future<List<UserStory>> fetchStories({
    required String projectId,
  }) async {
    final response = await _dio.get(
      '/projects/stories/project',
      options: Options(headers: {'X-Project-Id': projectId}),
    );
    final List data = response.data['data'];
    return data.map((json) => UserStory.fromJson(json)).toList();
  }

  Future<List<UserStory>> fetchStoriesBySprint({
    required String projectId,
    required int sprintId,
  }) async {
    final response = await _dio.get(
      '/projects/stories/sprint/$sprintId',
      options: Options(headers: {'X-Project-Id': projectId}),
    );
    if (response.data['status'] == 'SUCCESS') {
      List<dynamic> data = response.data['data'];
      return data.map((item) => UserStory.fromJson(item)).toList();
    }
    return [];
  }

  // Future<bool> updateStoryStatus(int storyId, UserStory story) async {
  //   try {
  //     final Map<String, Object?> data = {
  //       "sprintId": story.sprintId,
  //       "name": story.name,
  //       "description": story.description,
  //       "priorityId": story.priorityId,
  //       "assignedTo": story.assignedTo,
  //       "statusId": story.statusId,
  //       "epicId": story.epicId,
  //     };
  //     final response = await _dio.put(
  //       "/projects/stories/$storyId",
  //       data: data,
  //       options: Options(headers: {'X-Project-Id': story.projectId}),
  //     );
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print("❌ Error updateStoryStatus: $e");
  //     return false;
  //   }
  // }
  Future<bool> updateStoryStatus(int storyId, UserStory story) async {
    try {
      final Map<String, Object?> data = {
        // ❌ BỎ dòng này nếu backend không hỗ trợ epic
        // 'epicId': story.epicId,
        'sprintId': story.sprintId,
        'name': story.name,
        'description': story.description,
        'priorityId': story.priorityId,
        'assignedTo': story.assignedTo,
        'statusId': story.statusId,
      };
      print('📦 PUT payload sent: $data');

      final response = await _dio.put(
        "/projects/stories/$storyId",
        data: data,
        options: Options(headers: {'X-Project-Id': story.projectId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error updateStoryStatus: $e");
      return false;
    }
  }

  Future<bool> addUserStory({
    required String projectId,
    required AddUserStory story,
  }) async {
    try {
      final response = await _dio.post(
        "/projects/stories",
        data: story.toJson(),
        options: Options(headers: {'X-Project-Id': projectId}),
      );
      return response.statusCode == 200 && response.data['status'] == 'SUCCESS';
    } catch (e) {
      print('Error in addUserStory: $e');
      return false;
    }
  }

  Future<UserStory?> getStoryById({
    required int storyId,
    required String projectId,
  }) async {
    try {
      final response = await _dio.get(
        '/projects/stories/$storyId',
        options: Options(headers: {'X-Project-Id': projectId}),
      );
      final data = response.data['data'];
      return UserStory.fromJson(data);
    } catch (e) {
      print("❌ Error getStoryById: $e");
      return null;
    }
  }
}
