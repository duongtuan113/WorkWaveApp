// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../api/controllers/NotificationController.dart';
// import '../../../api/controllers/auth_controller.dart';
// import '../../widgets/CustomDrawer.dart';
//
// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({super.key});
//
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final auth = context.read<AuthController>();
//       final userId = auth.currentUser?.userId;
//       if (userId != null) {
//         final controller = context.read<NotificationController>();
//         controller.load(userId); // Load từ API
//         controller
//             .connectWebSocket(userId); // ✅ Thêm dòng này để kết nối WebSocket
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authController = context.read<AuthController>();
//     final notificationController = context.watch<NotificationController>();
//     final name = authController.currentUser?.userName ?? 'U';
//     final displayInitial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
//     final notifications = notificationController.notifications;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Builder(
//               builder: (context) => GestureDetector(
//                 onTap: () => Scaffold.of(context).openDrawer(),
//                 child: CircleAvatar(
//                   backgroundColor: Colors.orange,
//                   child: Text(displayInitial,
//                       style: const TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 final userId = authController.currentUser?.userId;
//                 if (userId != null) {
//                   notificationController.markAllAsRead(userId);
//                 }
//               },
//               icon: const Icon(Icons.mark_email_read_outlined),
//               tooltip: 'Mark all as read',
//             )
//           ],
//         ),
//       ),
//       drawer: CustomDrawer(),
//       body: notifications.isEmpty
//           ? _buildEmpty()
//           : ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: notifications.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 final n = notifications[index];
//                 final time = DateTime.fromMillisecondsSinceEpoch(n.timestamp);
//                 final formattedTime =
//                     DateFormat('dd/MM/yyyy • HH:mm').format(time);
//
//                 return Dismissible(
//                   key: ValueKey(n.id),
//                   direction: DismissDirection.endToStart,
//                   background: Container(
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     color: Colors.red,
//                     child: const Icon(Icons.delete, color: Colors.white),
//                   ),
//                   onDismissed: (_) {
//                     context
//                         .read<NotificationController>()
//                         .deleteNotification(n.id);
//                   },
//                   child: Card(
//                     color: n.read ? Colors.grey[100] : Colors.orange[50],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ListTile(
//                       onTap: () async {
//                         final type = n.type;
//                         final relatedId = n.relatedId;
//                         final projectId = n.projectId; // ✅ SỬA
//
//                         if (relatedId.isNotEmpty && projectId.isNotEmpty) {
//                           await context
//                               .read<NotificationController>()
//                               .markAsReadById(n.id);
//
//                           final encodedId = Uri.encodeComponent(relatedId);
//                           if (type == 'story') {
//                             context
//                                 .push('/story/$encodedId?projectId=$projectId');
//                           } else if (type == 'bug') {
//                             context
//                                 .push('/bug/$encodedId?projectId=$projectId');
//                           } else if (type == 'testcase') {
//                             context.push(
//                                 '/testcase/$encodedId?projectId=$projectId');
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text('Unknown notification type')),
//                             );
//                           }
//                         }
//                       },
//                       leading: Icon(
//                         n.read
//                             ? Icons.notifications_none
//                             : Icons.notifications_active,
//                         color: n.read ? Colors.grey : Colors.orange,
//                       ),
//                       title: Text(
//                         n.message,
//                         style: const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       subtitle: Text(formattedTime),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Notifications",
//               style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 150),
//           Container(
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset("assets/images/chuong.png", width: 200),
//                 const SizedBox(height: 30),
//                 const Text('No new notifications',
//                     style:
//                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 10),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 40.0),
//                   child: Text(
//                     'Updates to work you are assigned and watching will appear here.',
//                     style: TextStyle(fontSize: 15, color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/NotificationController.dart';
import '../../../api/controllers/auth_controller.dart';
import '../../widgets/CustomDrawer.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.userId;
      if (userId != null) {
        _notificationController = context.read<NotificationController>();
        _notificationController.load(userId); // Load danh sách ban đầu
        _notificationController.connectWebSocket(userId); // ✅ Kết nối WebSocket
      }
    });
  }

  @override
  void dispose() {
    // ✅ Không còn dùng context.read nữa
    _notificationController.disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final notificationController = context.watch<NotificationController>();
    final name = auth.currentUser?.userName ?? 'U';
    final displayInitial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final notifications = notificationController.notifications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            IconButton(
              onPressed: () {
                final userId = auth.currentUser?.userId;
                if (userId != null) {
                  notificationController.markAllAsRead(userId);
                }
              },
              icon: const Icon(Icons.mark_email_read_outlined),
              tooltip: 'Mark all as read',
            )
          ],
        ),
      ),
      drawer: CustomDrawer(),
      body: notifications.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final time = DateTime.fromMillisecondsSinceEpoch(n.timestamp);
                final formattedTime =
                    DateFormat('dd/MM/yyyy • HH:mm').format(time);

                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context
                        .read<NotificationController>()
                        .deleteNotification(n.id);
                  },
                  child: Card(
                    color: n.read ? Colors.grey[100] : Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () async {
                        final type = n.type;
                        final relatedId = n.relatedId;
                        final projectId = n.projectId;

                        if (relatedId.isNotEmpty && projectId.isNotEmpty) {
                          await notificationController.markAsReadById(n.id);

                          final encodedId = Uri.encodeComponent(relatedId);
                          if (type == 'story') {
                            context
                                .push('/story/$encodedId?projectId=$projectId');
                          } else if (type == 'bug') {
                            context
                                .push('/bug/$encodedId?projectId=$projectId');
                          } else if (type == 'testcase') {
                            context.push(
                                '/testcase/$encodedId?projectId=$projectId');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Unknown notification type')),
                            );
                          }
                        }
                      },
                      leading: Icon(
                        n.read
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: n.read ? Colors.grey : Colors.orange,
                      ),
                      title: Text(
                        n.message,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(formattedTime),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Notifications",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 150),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/chuong.png", width: 200),
                const SizedBox(height: 30),
                const Text('No new notifications',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Updates to work you are assigned and watching will appear here.',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
