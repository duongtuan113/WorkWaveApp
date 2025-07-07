import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/global.dart'; // <-- Dùng key toàn cục
import 'package:project/ui/main/home_page.dart';
import 'package:project/ui/screens/allWork_page/allWork.dart'; // <-- THÊM DÒNG NÀY
import 'package:project/ui/screens/login_page/LoginScreen.dart';
import 'package:project/ui/screens/login_page/RegisterScreen.dart';
import 'package:project/ui/screens/login_page/splash_screen.dart';
import 'package:project/ui/screens/notifications_page/notifications_page.dart';
import 'package:project/ui/screens/project_page/backlog.dart';
import 'package:project/ui/screens/project_page/board_page.dart';
import 'package:project/ui/screens/project_page/bugDetailPage.dart';
import 'package:project/ui/screens/project_page/bugTimelinePage.dart';
import 'package:project/ui/screens/project_page/project_page.dart';
import 'package:project/ui/screens/project_page/storyDetailPage.dart';
import 'package:project/ui/screens/project_page/summary.dart';
import 'package:project/ui/screens/project_page/testCaseDetailPage.dart';
import 'package:project/ui/widgets/main_layout.dart';

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey, // ✅ Thêm navigatorKey vào GoRouter
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/home_page',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/allWork',
          builder: (context, state) => const TaskPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/project',
          builder: (context, state) =>
              const ProjectPage(), // ✅ Không truyền projectId
        ),
        GoRoute(
          path: '/summary/:projectId',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId'] ?? '';
            return SummaryPage(projectId: projectId);
          },
        ),
        GoRoute(
          path: '/board/:projectId',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            return BoardPage(
              key: ValueKey(projectId),
              projectId: projectId,
            );
          },
        ),
        // GoRoute(
        //   path: '/backlog/:projectId',
        //   builder: (context, state) {
        //     final projectId = state.pathParameters['projectId']!;
        //     return BacklogPage(projectId: projectId);
        //   },
        // ),
        GoRoute(
          path: '/backlog/:projectId',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            final fromPage = (state.extra as Map?)?['fromPage'] ??
                'project'; // 👈 default fallback
            return BacklogPage(projectId: projectId, fromPage: fromPage);
          },
        ),

        GoRoute(
          path: '/timeline/:projectId',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            return BugTimelinePage(
              // ✅ CHỈNH TÊN LẠI CHO ĐÚNG
              key: ValueKey('bugtimeline-$projectId'),
              projectId: projectId,
            );
          },
        ),
        GoRoute(
          path: '/story/:id',
          builder: (context, state) {
            final storyIdStr = state.pathParameters['id'];
            final projectId = state.uri.queryParameters['projectId'];

            final storyId = int.tryParse(storyIdStr ?? '');

            if (storyId == null || projectId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid story ID or project ID')),
              );
            }

            return StoryDetailPage(
              storyId: storyId,
              projectId: projectId,
            );
          },
        ),
        GoRoute(
          path: '/bug/:id',
          builder: (context, state) {
            final bugIdStr = state.pathParameters['id'];
            final projectId = state.uri.queryParameters['projectId'];

            final bugId = int.tryParse(bugIdStr ?? '');

            if (bugId == null || projectId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid bug ID or project ID')),
              );
            }

            return BugDetailPage(
              bugId: bugId,
              projectId: projectId,
            );
          },
        ),
        GoRoute(
          path: '/testcase/:id',
          builder: (context, state) {
            final testCaseIdStr = state.pathParameters['id'];
            final projectId = state.uri.queryParameters['projectId'];

            final testCaseId = int.tryParse(testCaseIdStr ?? '');

            if (testCaseId == null || projectId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid test case ID or project ID')),
              );
            }

            return TestCaseDetailPage(
              testCaseId: testCaseId,
              projectId: projectId,
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('404 - Not Found')),
  ),
);
