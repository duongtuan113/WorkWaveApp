// class Task {
//   final int taskId;
//   final int storyId;
//   final String assignedTo;
//   final String taskName;
//   final String description;
//   final int status;
//   final int estimatedHours;
//   final int loggedHours;
//   final String createdAt;
//   final String updatedAt;
//   final String createdBy;
//   final String? updatedBy;
//
//   Task({
//     required this.taskId,
//     required this.storyId,
//     required this.assignedTo,
//     required this.taskName,
//     required this.description,
//     required this.status,
//     required this.estimatedHours,
//     required this.loggedHours,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.createdBy,
//     this.updatedBy,
//   });
//
//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//       taskId: json['taskId'],
//       storyId: json['storyId'],
//       assignedTo: json['assignedTo'],
//       taskName: json['taskName'],
//       description: json['description'],
//       status: json['status'],
//       estimatedHours: json['estimatedHours'],
//       loggedHours: json['loggedHours'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       createdBy: json['createdBy'],
//       updatedBy: json['updatedBy'],
//     );
//   }
//
//   Task copyWith({
//     int? taskId,
//     int? storyId,
//     String? assignedTo,
//     String? taskName,
//     String? description,
//     int? status,
//     int? estimatedHours,
//     int? loggedHours,
//     String? createdAt,
//     String? updatedAt,
//     String? createdBy,
//     String? updatedBy,
//   }) {
//     return Task(
//       taskId: taskId ?? this.taskId,
//       storyId: storyId ?? this.storyId,
//       assignedTo: assignedTo ?? this.assignedTo,
//       taskName: taskName ?? this.taskName,
//       description: description ?? this.description,
//       status: status ?? this.status,
//       estimatedHours: estimatedHours ?? this.estimatedHours,
//       loggedHours: loggedHours ?? this.loggedHours,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       createdBy: createdBy ?? this.createdBy,
//       updatedBy: updatedBy ?? this.updatedBy,
//     );
//   }
// }
class Task {
  final int taskId;
  final int storyId;
  final String assignedTo;
  final String taskName;
  final String? description;
  final int status;
  final int? estimatedHours;
  final int? loggedHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  Task({
    required this.taskId,
    required this.storyId,
    required this.assignedTo,
    required this.taskName,
    this.description,
    required this.status,
    this.estimatedHours,
    this.loggedHours,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'],
      storyId: json['storyId'],
      assignedTo: json['assignedTo'],
      taskName: json['taskName'],
      description: json['description'],
      status: json['status'],
      estimatedHours: json['estimatedHours'],
      loggedHours: json['loggedHours'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }
  Task copyWith({
    int? taskId,
    int? storyId,
    String? assignedTo,
    String? taskName,
    String? description,
    int? status,
    int? estimatedHours,
    int? loggedHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      storyId: storyId ?? this.storyId,
      assignedTo: assignedTo ?? this.assignedTo,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      status: status ?? this.status,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      loggedHours: loggedHours ?? this.loggedHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
