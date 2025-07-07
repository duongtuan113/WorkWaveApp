import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/api/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Đổi tên hàm cho rõ ràng hơn
  }

  Future<void> _checkLoginStatus() async {
    final auth = Provider.of<AuthController>(context, listen: false);

    // BƯỚC QUAN TRỌNG: CHỜ CHO AuthController HOÀN TẤT VIỆC TẢI TOKEN TỪ STORAGE
    await auth
        .initialized; // Đảm bảo constructor của AuthController đã hoàn tất

    // Bây giờ, _loggedInUser đã có giá trị (nếu có token được lưu)
    // Mới thử refresh token
    bool hasValidToken = await auth.refreshAccessToken();

    if (hasValidToken) {
      context.go('/'); // Đã đăng nhập => vào trang chính
    } else {
      context.go('/login'); // Chưa đăng nhập => vào trang đăng nhập
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
