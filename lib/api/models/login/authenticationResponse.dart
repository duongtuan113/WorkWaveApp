// class AuthenticationResponse {
//   String accessToken;
//   String refreshToken;
//   bool login;
//   String? message;
//   int? expiresIn; // ✅ thêm thời gian sống của access token (tính bằng giây)
//
//   AuthenticationResponse({
//     required this.accessToken,
//     required this.refreshToken,
//     required this.login,
//     this.message,
//     this.expiresIn,
//   });
//
//   factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
//     final dynamic data = json['data'];
//     if (data is Map<String, dynamic>) {
//       final accessToken = data['accessToken'] ?? '';
//       final refreshToken = data['refreshToken'] ?? '';
//       final login = accessToken.isNotEmpty;
//       final expiresIn = data['expiresIn']; // ✅ lấy expiresIn từ backend nếu có
//
//       return AuthenticationResponse(
//         accessToken: accessToken,
//         refreshToken: refreshToken,
//         login: login,
//         message: json['message'],
//         expiresIn: expiresIn,
//       );
//     } else {
//       return AuthenticationResponse(
//         accessToken: '',
//         refreshToken: '',
//         login: false,
//         message: 'Invalid response format',
//       );
//     }
//   }
//
//   factory AuthenticationResponse.fromStorageJson(Map<String, dynamic> json) {
//     final accessToken = json['accessToken'] ?? '';
//     final refreshToken = json['refreshToken'] ?? '';
//     final login = accessToken.isNotEmpty;
//     final expiresIn = json['expiresIn'];
//
//     return AuthenticationResponse(
//       accessToken: accessToken,
//       refreshToken: refreshToken,
//       login: login,
//       message: json['message'],
//       expiresIn: expiresIn,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'accessToken': accessToken,
//       'refreshToken': refreshToken,
//       'login': login,
//       'message': message,
//       'expiresIn': expiresIn,
//     };
//   }
// }
class AuthenticationResponse {
  String accessToken;
  String refreshToken;
  bool login;
  String? message;
  int? expiresIn;
  String? userId; // <-- THÊM THUỘC TÍNH NÀY

  AuthenticationResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.login,
    this.message,
    this.expiresIn,
    this.userId, // <-- THÊM VÀO CONSTRUCTOR
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    if (data is Map<String, dynamic>) {
      final accessToken = data['accessToken'] ?? '';
      final refreshToken = data['refreshToken'] ?? '';
      final login = accessToken.isNotEmpty;
      final expiresIn = data['expiresIn'];
      final userId = data['userId']; // <-- LẤY userId TỪ API RESPONSE

      return AuthenticationResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        login: login,
        message: json['message'],
        expiresIn: expiresIn,
        userId: userId, // <-- GÁN VÀO ĐÂY
      );
    } else {
      return AuthenticationResponse(
        accessToken: '',
        refreshToken: '',
        login: false,
        message: 'Invalid response format',
      );
    }
  }

  factory AuthenticationResponse.fromStorageJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'] ?? '';
    final refreshToken = json['refreshToken'] ?? '';
    final login = accessToken.isNotEmpty;
    final expiresIn = json['expiresIn'];
    final userId = json['userId']; // <-- LẤY userId TỪ BỘ NHỚ

    return AuthenticationResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      login: login,
      message: json['message'],
      expiresIn: expiresIn,
      userId: userId, // <-- GÁN VÀO ĐÂY
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'login': login,
      'message': message,
      'expiresIn': expiresIn,
      'userId': userId, // <-- THÊM VÀO JSON ĐỂ LƯU
    };
  }
}
