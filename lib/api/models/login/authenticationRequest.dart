class AuthenticationRequest {
  late final String email;
  late final String password;
  AuthenticationRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
