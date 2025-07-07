import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Biến để kiểm soát việc hiển thị loading ban đầu hoặc UI splash screen
  bool _isLoadingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Gọi hàm kiểm tra trạng thái đăng nhập
  }

  Future<void> _checkLoginStatus() async {
    // Dùng addPostFrameCallback để đảm bảo context sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Kiểm tra mounted trước khi dùng context
      if (!mounted) return;
      final authController = context.read<AuthController>();

      // Chờ AuthController khởi tạo xong (đọc token từ storage)
      await authController.initialized;
      if (!mounted) return;

      // ✅ SỬA LỖI: Dùng authController.status thay vì isLoggedInStatus
      if (authController.status == AuthStatus.authenticated) {
        // Nếu đã đăng nhập, chuyển đến trang chủ
        context.go('/home_page');
      } else {
        // Nếu chưa đăng nhập, dừng loading và hiển thị các nút
        setState(() {
          _isLoadingAuth = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingAuth) {
      // Hiển thị loading khi đang kiểm tra trạng thái đăng nhập
      return const Scaffold(
        backgroundColor: Color(0xFF0052CC), // Giữ màu nền thương hiệu
        body: Center(
          child: CircularProgressIndicator(
              color: Colors.white), // Loading màu trắng
        ),
      );
    } else {
      // Đã kiểm tra xong, không có token hợp lệ, hiển thị UI splash screen với nút Đăng nhập/Đăng ký
      return Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Giả sử bạn có ảnh này trong assets
              Image.asset('assets/images/logo_1.png', height: 50),
              // const Icon(Icons.track_changes, color: Colors.white, size: 40),
              const SizedBox(width: 10),
              const Text(
                'WorkWave',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C5279),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 40),
                // Giả sử bạn có ảnh này trong assets
                Image.asset('assets/images/logo_1.png', height: 300),
                // Icon(Icons.workspaces_outline,
                //     size: 200, color: Colors.white.withOpacity(0.8)),
                const SizedBox(height: 90),
                const Text(
                  'Lên kế hoạch và theo dõi công việc giúp bạn làm việc hiệu quả và thú vị hơn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1C5279),
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1C5279),
                        // foregroundColor: const Color(0xFF0052CC),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => context.go('/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF1C5279),
                        side: const BorderSide(
                            color: Color(0xFF1C5279), width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C5279),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Bằng cách tiếp tục, bạn đồng ý với\nChính sách quyền riêng tư và Điều khoản dịch vụ.\nKhông đăng nhập được?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
