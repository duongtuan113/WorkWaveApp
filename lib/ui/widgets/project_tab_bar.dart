import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectTabBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final String projectId;

  ProjectTabBar({
    required this.selectedIndex,
    required this.projectId,
    Key? key,
  }) : super(key: key);

  List<Map<String, String>> get _tabs => [
        {"title": "Summary", "route": "/summary/$projectId"},
        {"title": "Board", "route": "/board/$projectId"},
        {"title": "Backlog", "route": "/backlog/$projectId"},
        {"title": "Timeline", "route": "/timeline/$projectId"},
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                context.go(tab["route"]!);
              }
            },
            child: Text(
              tab["title"]!,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
