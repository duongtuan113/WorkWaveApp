class NotificationModel {
  final String id;
  final String message;
  final String type;
  final String relatedId;
  final String projectId;
  final int timestamp;
  final bool read;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.relatedId,
    required this.projectId,
    required this.timestamp,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      type: json['type'],
      relatedId: json['relatedId'],
      projectId: json['projectId'] ?? '',
      timestamp: json['timestamp'],
      read: json['read'],
    );
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      message: message,
      type: type,
      relatedId: relatedId,
      projectId: projectId,
      timestamp: timestamp,
      read: read ?? this.read,
    );
  }
}
