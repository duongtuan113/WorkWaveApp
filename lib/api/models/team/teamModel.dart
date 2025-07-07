class Team {
  final int teamId;
  final String projectId;
  final String teamName;

  Team({
    required this.teamId,
    required this.projectId,
    required this.teamName,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['teamId'] as int,
      projectId: json['projectId'] as String,
      teamName: json['teamName'] as String,
    );
  }
}
