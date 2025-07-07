class UserByIdModel {
  final String userId;
  final String userName;
  final String email;

  UserByIdModel({
    required this.userId,
    required this.userName,
    required this.email,
  });

  factory UserByIdModel.fromJson(Map<String, dynamic> json) {
    return UserByIdModel(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
