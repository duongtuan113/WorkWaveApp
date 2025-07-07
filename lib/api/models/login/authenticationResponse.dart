class AuthenticationResponse {
  String accessToken;
  String refreshToken;
  bool login;
  String? message;
  int? expiresIn;
  String? userId;

  AuthenticationResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.login,
    this.message,
    this.expiresIn,
    this.userId,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    if (data is Map<String, dynamic>) {
      final accessToken = data['accessToken'] ?? '';
      final refreshToken = data['refreshToken'] ?? '';
      final login = accessToken.isNotEmpty;
      final expiresIn = data['expiresIn'];
      final userId = data['userId'];

      return AuthenticationResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        login: login,
        message: json['message'],
        expiresIn: expiresIn,
        userId: userId,
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
    final userId = json['userId'];

    return AuthenticationResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      login: login,
      message: json['message'],
      expiresIn: expiresIn,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'login': login,
      'message': message,
      'expiresIn': expiresIn,
      'userId': userId,
    };
  }
}
