class User {
  late final String userName;
  late final String email;
  late final String password;
  User({required this.userName, required this.email, required this.password});
  // Hàm chuyển Model thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {'userName': userName, 'email': email, 'password': password};
  }

// Hàm chuyển đổi từ JSON sang Model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userName: json["userName"],
        email: json["email"],
        password: json["password"]);
  }
}
