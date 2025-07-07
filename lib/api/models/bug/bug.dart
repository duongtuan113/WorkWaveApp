class Bug {
  final int bugId;
  final String title;
  final String description;
  final String projectId;
  final int storyId;
  final int taskId;
  final String reportedBy;
  final String assignedTo;
  final int severityId;
  final String severityName;
  final int priorityId;
  final String priorityName;
  final int statusId;
  final String statusName;
  final String createdBy;
  final String updatedBy;
  final String createdAt;
  final String updatedAt;
  Bug(
      {required this.bugId,
      required this.title,
      required this.description,
      required this.projectId,
      required this.storyId,
      required this.taskId,
      required this.reportedBy,
      required this.createdBy,
      required this.statusId,
      required this.assignedTo,
      required this.updatedAt,
      required this.updatedBy,
      required this.createdAt,
      required this.priorityId,
      required this.priorityName,
      required this.severityId,
      required this.severityName,
      required this.statusName});
  factory Bug.fromJson(Map<String, dynamic> json) {
    return Bug(
        bugId: json['bugId'],
        title: json['title'],
        description: json['description'],
        projectId: json['projectId'],
        storyId: json["storyId"],
        taskId: json["taskId"],
        reportedBy: json['reportedBy'],
        createdBy: json['createdBy'],
        statusId: json['statusId'],
        assignedTo: json['assignedTo'],
        updatedAt: json["updatedAt"],
        updatedBy: json['updatedBy'],
        createdAt: json['createdAt'],
        priorityId: json['priorityId'],
        priorityName: json['priorityName'],
        severityId: json['severityId'],
        severityName: json['severityName'],
        statusName: json['statusName']);
  }
}
