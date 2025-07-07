import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("dashboardPage")),
      body: const Center(
          child: Text("dashboard Page", style: TextStyle(fontSize: 24))),
    );
  }
}
