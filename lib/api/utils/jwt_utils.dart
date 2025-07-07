// import 'dart:convert';
//
// /// Giải mã JWT accessToken để lấy userId từ trường `sub`
// String extractUserIdFromJwt(String token) {
//   try {
//     final parts = token.split('.');
//     if (parts.length != 3) return '';
//     final payload =
//         utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
//     final Map<String, dynamic> decoded = json.decode(payload);
//     return decoded['sub'] ?? '';
//   } catch (e) {
//     print("❌ Lỗi khi parse JWT: $e");
//     return '';
//   }
// }
import 'dart:convert';

String? extractUserIdFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);

    return payloadMap['sub']; // sub thường là userId
  } catch (e) {
    print('❌ extractUserIdFromJwt error: $e');
    return null;
  }
}

int? extractExpiryInFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);

    final exp = payloadMap['exp'];
    final iat = payloadMap['iat'];

    if (exp is int && iat is int) {
      return exp - iat;
    }
  } catch (e) {
    print('❌ extractExpiryInFromJwt error: $e');
  }
  return null;
}
