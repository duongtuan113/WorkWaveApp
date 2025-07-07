class TestCase {
  final int testCaseId;
  final String projectId;
  final int storyId;
  final String testName;
  final String description;
  final String expectedResult;
  final String actualResult;
  final int statusId;
  final String createdBy;
  final String? executedBy;
  TestCase(
      {required this.statusId,
      required this.projectId,
      required this.storyId,
      required this.description,
      required this.createdBy,
      required this.actualResult,
      required this.expectedResult,
      required this.testCaseId,
      required this.testName,
      this.executedBy});
  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      testCaseId: json['testCaseId'],
      projectId: json['projectId'],
      storyId: json['storyId'],
      testName: json['testName'],
      description: json['description'],
      expectedResult: json['expectedResult'],
      actualResult: json['actualResult'],
      statusId: json['statusId'],
      createdBy: json['createdBy'],
      executedBy: json['executedBy'],
    );
  }
}
