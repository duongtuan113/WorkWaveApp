import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/controllers/auth_controller.dart';
import '../../api/controllers/projectController.dart';
import '../../api/services/apiWebSocketService.dart';
import '../widgets/CustomDrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthStatus? _previousAuthStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authController = context.read<AuthController>();
      final projectController = context.read<ProjectController>();
      final ws = WebSocketService();

      _previousAuthStatus = authController.status;

      if (_previousAuthStatus == AuthStatus.authenticated) {
        print("🟢 [HomePage] Đã đăng nhập sẵn, tải projects...");
        if (!projectController.isLoading) {
          projectController.loadProjects();
        }

        final token = authController.accessToken;
        if (token != null && token.isNotEmpty) {
          if (!ws.isConnected) {
            ws.connect(onMessage: (eventType, data) {
              _handleWebSocketMessage(eventType, data);
            });
          } else {
            ws.setMessageHandler((eventType, data) {
              _handleWebSocketMessage(eventType, data);
            });
          }
        }
      }
    });
  }

  void _handleWebSocketMessage(String eventType, dynamic data) {
    final projectController = context.read<ProjectController>();
    if (['project-created', 'project-updated', 'project-deleted']
        .contains(eventType)) {
      print("🔁 WebSocket update: $eventType — reloading projects...");
      if (!projectController.isLoading) {
        projectController.loadProjects();
      }
    }
  }

  @override
  void dispose() {
    // ❌ KHÔNG nên disconnect WebSocket ở đây, để giữ kết nối khi chuyển tab
    // WebSocketService().disconnect();
    super.dispose();
  }

  void _createProject(BuildContext context) {
    print("➕ Create project button clicked");
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final projectController = context.watch<ProjectController>();
    final currentAuthStatus = authController.status;

    if (currentAuthStatus != _previousAuthStatus &&
        currentAuthStatus == AuthStatus.authenticated) {
      print(
          "🎉 [HomePage] Phát hiện đăng nhập thành công! Bắt đầu tải projects...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProjectController>().loadProjects();
        }
      });
    }

    _previousAuthStatus = currentAuthStatus;

    final user = authController.currentUser;
    final displayInitial = (user?.userName.isNotEmpty ?? false)
        ? user!.userName[0].toUpperCase()
        : '?';
    final displayName = user?.userName ?? 'Người dùng';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nút mở drawer
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(displayInitial,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo_1.png', height: 36),
                const SizedBox(width: 15),
                const Text(
                  'WorkWave',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // color: Color(0xFF1C5279),
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 36), // Để căn giữa logo nếu cần
          ],
        ),
      ),
      drawer: CustomDrawer(),
      body: _buildBody(authController, projectController, displayName),
    );
  }

  Widget _buildBody(
      AuthController auth, ProjectController projects, String displayName) {
    if (auth.status != AuthStatus.authenticated) {
      return const Center(child: Text("Vui lòng đăng nhập để xem dự án."));
    }

    if (projects.isLoading && projects.projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (projects.error != null) {
      return Center(child: Text("Lỗi: ${projects.error}"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $displayName 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              context.read<ProjectController>().searchProjects(value);
            },
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[300],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Card(
            color: Colors.grey[200],
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/list_icon.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalize this space',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Add your most important stuff here, for fast access.',
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (projects.projects.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Center(child: Text("Không có dự án nào.")),
            )
          else
            Column(
              children: projects.filteredProjects.map((project) {
                return RecentItemCard(
                  icon: Icons.folder_open,
                  title: project.name,
                  subtitle: project.description ?? 'No description',
                  iconColor: Colors.blue,
                  route: '/board/${project.projectId}',
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class RecentItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final String route;

  const RecentItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => context.push(route),
        child: ListTile(
          leading: Icon(icon, color: iconColor, size: 30),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}
