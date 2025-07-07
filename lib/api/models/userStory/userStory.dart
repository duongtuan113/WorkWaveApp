class UserStory {
  static const _sentinel = Object();

  final int storyId;
  final int? epicId;
  final int? sprintId;
  final String name;
  final String description;
  final int? priorityId;
  final String? assignedTo;
  final int statusId;
  final String createdAt;
  final String updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String projectId;

  UserStory({
    required this.storyId,
    required this.epicId,
    required this.sprintId,
    required this.statusId,
    required this.projectId,
    required this.description,
    required this.name,
    required this.createdAt,
    required this.createdBy,
    required this.updatedBy,
    required this.updatedAt,
    required this.assignedTo,
    required this.priorityId,
  });

  factory UserStory.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return UserStory(
      storyId: tryParseInt(json['storyId']) ?? 0,
      epicId: tryParseInt(json['epicId']),
      sprintId: tryParseInt(json['sprintId']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priorityId: tryParseInt(json['priorityId']),
      assignedTo: json['assignedTo']?.toString(),
      statusId: tryParseInt(json['statusId']) ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      projectId: json['projectId']?.toString() ?? '',
    );
  }

  UserStory copyWith({
    int? storyId,
    Object? epicId = _sentinel,
    Object? sprintId = _sentinel,
    String? name,
    String? description,
    Object? priorityId = _sentinel,
    Object? assignedTo = _sentinel,
    int? statusId,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? projectId,
  }) {
    return UserStory(
      storyId: storyId ?? this.storyId,
      epicId: epicId == _sentinel ? this.epicId : epicId as int?,
      sprintId: sprintId == _sentinel ? this.sprintId : sprintId as int?,
      name: name ?? this.name,
      description: description ?? this.description,
      priorityId:
          priorityId == _sentinel ? this.priorityId : priorityId as int?,
      assignedTo:
          assignedTo == _sentinel ? this.assignedTo : assignedTo as String?,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      projectId: projectId ?? this.projectId,
    );
  }

  // ⚠️ Toàn bộ thông tin
  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'epicId': epicId,
      'sprintId': sprintId,
      'name': name,
      'description': description,
      'priorityId': priorityId,
      'assignedTo': assignedTo,
      'statusId': statusId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'projectId': projectId,
    };
  }

  // ✅ Chỉ các trường mà backend PUT cho phép cập nhật
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'epicId': epicId,
      'sprintId': sprintId,
      'name': name,
      'description': description,
      'priorityId': priorityId,
      'assignedTo': assignedTo,
      'statusId': statusId,
    };
  }
}

extension UserStoryUpdateJson on UserStory {
  Map<String, dynamic> toJsonForUpdate() {
    return {
      // 'epicId': epicId,//bỏ tạm
      'sprintId': sprintId,
      'name': name,
      'description': description,
      'priorityId': priorityId,
      'assignedTo': assignedTo,
      'statusId': statusId,
    };
  }
}
