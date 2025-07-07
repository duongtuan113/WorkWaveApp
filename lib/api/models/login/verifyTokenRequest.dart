class VerifyTokenRequest {
  String accessToken;
  String refreshToken;
  VerifyTokenRequest({required this.accessToken, required this.refreshToken});
  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}
