import 'package:flutter/foundation.dart';

@immutable
class Project {
  final String projectId;
  final String name;
  final String? description;

  const Project({
    required this.projectId,
    required this.name,
    this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project && other.projectId == projectId;
  }

  @override
  int get hashCode => projectId.hashCode;
}
