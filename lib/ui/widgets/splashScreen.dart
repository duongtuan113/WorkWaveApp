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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    await auth.initialized;
    bool hasValidToken = await auth.refreshAccessToken();

    if (hasValidToken) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
