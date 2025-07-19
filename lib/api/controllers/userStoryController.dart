import 'package:flutter/material.dart';
import 'package:project/api/models/userStory/userStory.dart';

import '../models/userStory/addUserStory.dart';
import '../services/apiUserStoryService.dart';

class UserStoryController with ChangeNotifier {
  final UserStoryService _service;
  UserStoryController(this._service);

  List<UserStory> stories = [];
  bool _isLoading = false;
  UserStory? _story;
  UserStory? get story => _story;
  bool get isLoading => _isLoading;

  Future<void> loadAllStories(String projectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Bỏ token
      stories = await _service.fetchStories(projectId: projectId);
    } catch (e) {
      print("❌ Lỗi khi load all stories: $e");
      stories = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStories(String projectId, int? sprintId) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (sprintId == null) {
        final allStories = await _service.fetchStories(projectId: projectId);
        stories = allStories.where((s) => s.sprintId == null).toList();
      } else {
        stories = await _service.fetchStoriesBySprint(
          projectId: projectId,
          sprintId: sprintId,
        );
      }
    } catch (e) {
      print("❌ Lỗi khi load stories: $e");
      stories = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStoryStatus(int storyId, int newStatus) async {
    final index = stories.indexWhere((s) => s.storyId == storyId);
    if (index == -1) return false;

    final story = stories[index];
    final updatedStory = story.copyWith(statusId: newStatus);

    bool success = await _service.updateStoryStatus(storyId, updatedStory);

    if (success) {
      stories[index] = updatedStory;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateStory({required UserStory updatedStory}) async {
    final success = await _service.updateStoryStatus(
      updatedStory.storyId,
      updatedStory,
    );
    if (success) {
      final index =
          stories.indexWhere((s) => s.storyId == updatedStory.storyId);
      if (index != -1) {
        stories[index] = updatedStory;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> addStory({
    required String projectId,
    required AddUserStory newStory,
  }) async {
    try {
      final success = await _service.addUserStory(
        projectId: projectId,
        story: newStory,
      );
      if (success) {
        print("✅ Add story thành công, load lại list");
        await loadStories(projectId, newStory.sprintId);
      } else {
        print("❌ Add story thất bại từ service");
      }
      return success;
    } catch (e) {
      print('Add story error: $e');
      return false;
    }
  }

  Future<void> loadStoryById({
    required int storyId,
    required String projectId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final storyData = await _service.getStoryById(
        storyId: storyId,
        projectId: projectId,
      );
      _story = storyData;
    } catch (e) {
      print('❌ Lỗi khi load story by ID: $e');
      _story = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
