class CreateProject {
  final String name;
  final String description;
  final int statusId;
  final String createdBy;
  final String createdAt;
  final String? startDate;
  final String? endDate;

  CreateProject({
    required this.name,
    required this.description,
    required this.statusId,
    required this.createdBy,
    required this.createdAt,
    this.startDate,
    this.endDate,
  });

  factory CreateProject.fromJson(Map<String, dynamic> json) {
    return CreateProject(
      name: json['name'],
      description: json['description'],
      statusId: json['statusId'] ?? 1,
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'statusId': statusId,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'startDate': startDate,
        'endDate': endDate,
      };

  String get statusLabel {
    switch (statusId) {
      case 1:
        return "Not Started";
      case 2:
        return "In Progress";
      case 3:
        return "Completed";
      case 4:
        return "On Hold";
      case 5:
        return "Cancelled";
      default:
        return "Unknown";
    }
  }
}
