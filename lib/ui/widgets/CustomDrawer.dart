import 'package:flutter/material.dart';
import 'package:project/api/controllers/auth_controller.dart';
import 'package:project/api/controllers/userController.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userController = context.watch<UserController>();

    final currentUserId = authController.loggedInUser?.userId;
    print("📌 CustomDrawer: currentUserId = $currentUserId");
    if (currentUserId != null &&
        userController.getUserById(currentUserId) == null &&
        !userController.isFetchingUsers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          final token = context.read<AuthController>().accessToken;
          if (token != null) {
            print(
                "ℹ️ [CustomDrawer] Triggering fetch for current user: $currentUserId");
            context.read<UserController>().fetchUsers({currentUserId});
          }
        }
      });
    }
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
