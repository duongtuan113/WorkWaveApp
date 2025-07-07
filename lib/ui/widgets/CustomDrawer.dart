import 'package:flutter/material.dart';
import 'package:project/api/controllers/auth_controller.dart';
import 'package:project/api/controllers/userController.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    // Dùng `watch` để Drawer tự động cập nhật khi trạng thái đăng nhập thay đổi
    final authController = context.watch<AuthController>();
    // Dùng `watch` cả UserController để rebuild khi cache có dữ liệu mới
    final userController = context.watch<UserController>();

    final currentUserId = authController.loggedInUser?.userId;
    print("📌 CustomDrawer: currentUserId = $currentUserId");

    // ✅ LOGIC QUAN TRỌNG NHẤT: Tự động tải dữ liệu nếu cần
    // Nếu có userId, user chưa có trong cache, và không đang trong quá trình tải
    if (currentUserId != null &&
        userController.getUserById(currentUserId) == null &&
        !userController.isFetchingUsers) {
      // Dùng addPostFrameCallback để tránh lỗi "setState during build"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Kiểm tra lại mounted để chắc chắn widget vẫn tồn tại
        if (context.mounted) {
          // Lấy token từ AuthController
          final token = context.read<AuthController>().accessToken;
          if (token != null) {
            print(
                "ℹ️ [CustomDrawer] Triggering fetch for current user: $currentUserId");
            // ✅ SỬA LỖI: Truyền token vào hàm fetchUsers
            context.read<UserController>().fetchUsers({currentUserId});
          }
        }
      });
    }

    // Lấy thông tin user từ cache để hiển thị
    final user = userController.getUserById(currentUserId);
    final userName = user?.userName ?? 'Người dùng';
    final email = user?.email ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.orange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Xin chào!',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  // Nếu user là null (chưa có trong cache) và đang tải, hiển thị loading
                  user == null && userController.isFetchingUsers
                      ? 'Đang tải...'
                      : userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthController>().logout(context);
            },
          ),
        ],
      ),
    );
  }
}
