import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/api/controllers/projectController.dart';
import 'package:project/api/models/bug/bug.dart';
import 'package:project/api/models/testcase/testCase.dart';
import 'package:project/api/models/userStory/userStory.dart';
import 'package:provider/provider.dart';

class WorkItemSearchDelegate extends SearchDelegate<Object?> {
  final List<Object> allItems;

  WorkItemSearchDelegate(this.allItems);

  List<Object> _filterItems(String query) {
    return allItems.where((item) {
      String name = '';
      if (item is UserStory) name = item.name;
      if (item is TestCase) name = item.testName;
      if (item is Bug) name = item.title;
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      textTheme: base.textTheme.copyWith(
        bodyLarge: const TextStyle(color: Colors.black),
        bodyMedium: const TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filtered = _filterItems(query);
    if (filtered.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    final projectId = Provider.of<ProjectController>(context, listen: false)
        .selectedProject
        ?.projectId;

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = filtered[index];

        IconData typeIcon = Icons.task;
        Color iconColor = Colors.grey;
        String title = "N/A";
        String? path;

        if (item is UserStory) {
          typeIcon = Icons.library_books_outlined;
          iconColor = Colors.blue;
          title = item.name;
          path = '/story/${item.storyId}?projectId=$projectId';
        } else if (item is TestCase) {
          typeIcon = Icons.check_circle_outline;
          iconColor = Colors.green;
          title = item.testName;
          path = '/testcase/${item.testCaseId}?projectId=$projectId';
        } else if (item is Bug) {
          typeIcon = Icons.bug_report_outlined;
          iconColor = Colors.red;
          title = item.title;
          path = '/bug/${item.bugId}?projectId=$projectId';
        }

        return ListTile(
          tileColor: Colors.white,
          leading: Icon(typeIcon, color: iconColor),
          title: Text(title),
          onTap: () {
            if (path != null) {
              close(context, null);
              context.push(path);
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
