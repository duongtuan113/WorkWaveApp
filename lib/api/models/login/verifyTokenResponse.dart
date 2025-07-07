class VerifyTokenResponse {
  bool isValid;
  VerifyTokenResponse({required this.isValid});
  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) {
    return VerifyTokenResponse(isValid: json["result"]["isValid"]);
  }
}
