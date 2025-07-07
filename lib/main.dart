import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Controllers
import 'api/controllers/NotificationController.dart';
import 'api/controllers/auth_controller.dart';
import 'api/controllers/bugController.dart';
import 'api/controllers/projectController.dart';
import 'api/controllers/spinController.dart';
import 'api/controllers/testCaseController.dart';
import 'api/controllers/userController.dart';
import 'api/controllers/userStoryController.dart';
// Dio Clients & Services
import 'api/dioClient.dart';
import 'api/dioNotificationClient.dart';
import 'api/services/apiBugService.dart';
import 'api/services/apiLoginService.dart';
import 'api/services/apiNotificationService.dart';
import 'api/services/apiProjectService.dart';
import 'api/services/apiSpinService.dart';
import 'api/services/apiTestCaseService.dart';
import 'api/services/apiUserService.dart';
import 'api/services/apiUserStoryService.dart';
import 'api/services/apiWebSocketService.dart';
import 'api/services/notification_service.dart';
// Firebase & Routing
import 'firebase_options.dart';
import 'router.dart';

// Global Notification Service
final notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, s) {
    print('🔥 Firebase init failed: $e');
    print(s);
  }

  // Dio clients
  final dioClient = DioClient();
  final dio = dioClient.dio;

  final notificationDioClient = DioNotificationClient(); // port 8086
  final notificationApiService =
      ApiNotificationService(notificationDioClient.dio);

  // Services
  final apiLoginService = ApiLoginService(dio);
  final userService = UserService(dio);
  final projectService = ProjectService(dio);
  final testCaseService = TestCaseService(dio);
  final bugService = BugService(dio);
  final userStoryService = UserStoryService(dio);
  final sprintService = SprintService(dio);
  final webSocketService = WebSocketService();

  // Controllers
  final userController = UserController(userService);
  final authController =
      AuthController(apiLoginService, userController, webSocketService);

  dioClient.setAuthController(authController); // Inject token middleware

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiLoginService>.value(value: apiLoginService),
        ChangeNotifierProvider<UserController>.value(value: userController),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<ProjectController>(
          create: (_) => ProjectController(projectService),
        ),
        ChangeNotifierProvider<TestCaseController>(
          create: (_) => TestCaseController(testCaseService),
        ),
        ChangeNotifierProvider<BugController>(
          create: (_) => BugController(bugService),
        ),
        ChangeNotifierProvider<UserStoryController>(
          create: (_) => UserStoryController(userStoryService),
        ),
        ChangeNotifierProvider<SprintController>(
          create: (_) => SprintController(sprintService),
        ),
        ChangeNotifierProvider<NotificationController>(
          create: (_) => NotificationController(notificationApiService),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // Firebase Messaging Setup
  await notificationService.init();
  await setupFirebaseMessaging();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Notification permission granted');

    messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
    });

    String? apnsToken;
    int retry = 0;
    while (apnsToken == null && retry < 10) {
      apnsToken = await messaging.getAPNSToken();
      await Future.delayed(const Duration(milliseconds: 300));
      retry++;
    }

    if (apnsToken == null) {
      print('❌ APNs token vẫn chưa sẵn sàng. Thử lại sau.');
      return;
    }

    String? fcmToken = await messaging.getToken();
    print('📱 FCM Token: $fcmToken');
  } else {
    print('❌ Notification permission not granted');
  }
}
