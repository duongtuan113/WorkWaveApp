class Sprint {
  final int sprintId;
  final String projectId;
  final String name;
  final String startDate;
  final String endDate;
  final int statusId;
  final String goal;

  Sprint({
    required this.sprintId,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.statusId,
    required this.goal,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      sprintId: json['sprintId'],
      projectId: json['projectId'],
      name: json['name'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      statusId: json['statusId'],
      goal: json['goal'],
    );
  }
}
