class AddUserStory {
  final String name;
  final String description;
  final int priorityId;
  final int statusId;
  final int? sprintId;
  final String? assignedTo;
  final String? epicId;

  AddUserStory({
    required this.name,
    required this.description,
    required this.priorityId,
    required this.statusId,
    this.sprintId,
    this.assignedTo,
    this.epicId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "name": name,
      "description": description,
      "priorityId": priorityId,
      "statusId": statusId,
      "sprintId": sprintId,
    };

    if (assignedTo != null) data["assignedTo"] = assignedTo;
    if (epicId != null) data["epicId"] = epicId;

    return data;
  }
}
