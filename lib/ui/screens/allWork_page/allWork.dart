import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/api/controllers/bugController.dart';
import 'package:project/api/controllers/projectController.dart';
import 'package:project/api/controllers/testCaseController.dart';
import 'package:project/api/controllers/userController.dart';
import 'package:project/api/controllers/userStoryController.dart';
import 'package:project/api/models/bug/bug.dart';
import 'package:project/api/models/project/projectModel.dart';
import 'package:project/api/models/testcase/testCase.dart';
import 'package:project/api/models/userStory/userStory.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';
import '../../widgets/CustomDrawer.dart';
import '../../widgets/WorkItemSearchDelegate.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Object> _unifiedWorkItems = [];
  bool _isLoading = true;
  int _selectedView = 0; // 0 = List (Bảng), 1 = Detailed
  String get displayInitial {
    final authController = context.read<AuthController>();
    final name = authController.currentUser?.userName ?? 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  late ScrollController _stickyColumnScrollController;
  late ScrollController _scrollablePartScrollController;

  @override
  void initState() {
    super.initState();
    _stickyColumnScrollController = ScrollController();
    _scrollablePartScrollController = ScrollController();
    _syncScrolls();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _syncScrolls() {
    _stickyColumnScrollController.addListener(() {
      if (_scrollablePartScrollController.hasClients &&
          _scrollablePartScrollController.position.pixels !=
              _stickyColumnScrollController.position.pixels) {
        _scrollablePartScrollController
            .jumpTo(_stickyColumnScrollController.position.pixels);
      }
    });

    _scrollablePartScrollController.addListener(() {
      if (_stickyColumnScrollController.hasClients &&
          _stickyColumnScrollController.position.pixels !=
              _scrollablePartScrollController.position.pixels) {
        _stickyColumnScrollController
            .jumpTo(_scrollablePartScrollController.position.pixels);
      }
    });
  }

  @override
  void dispose() {
    _stickyColumnScrollController.dispose();
    _scrollablePartScrollController.dispose();
    super.dispose();
  }

  // --- LOGIC TẢI VÀ KẾT HỢP DỮ LIỆU ---
  Future<void> _initializeData() async {
    final projectCtrl = context.read<ProjectController>();
    if (projectCtrl.projects.isEmpty) {
      await projectCtrl.loadProjects();
    }

    if (!mounted) return;

    if (projectCtrl.projects.isNotEmpty) {
      await _onProjectSelected(projectCtrl.projects.first);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onProjectSelected(Project project) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final projectCtrl = context.read<ProjectController>();
    final testCaseCtrl = context.read<TestCaseController>();
    final bugCtrl = context.read<BugController>();
    final userStoryCtrl = context.read<UserStoryController>();

    projectCtrl.setSelectedProjectById(project.projectId);

    await Future.wait([
      userStoryCtrl.loadAllStories(project.projectId),
      testCaseCtrl.loadTestCase(project.projectId),
      bugCtrl.loadBug(project.projectId),
    ]);

    if (!mounted) return;
    _combineAndSortLists();
    await _fetchAssigneeNames();

    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  void _combineAndSortLists() {
    final stories = context.read<UserStoryController>().stories;
    final testCases = context.read<TestCaseController>().testCases;
    final bugs = context.read<BugController>().bug;
    List<Object> combinedList = [...stories, ...testCases, ...bugs];
    _unifiedWorkItems = combinedList;
  }

  Future<void> _fetchAssigneeNames() async {
    if (!mounted) return;
    final userCtrl = context.read<UserController>();
    final Set<String> userIds = {};

    for (var item in _unifiedWorkItems) {
      String? userId;
      if (item is UserStory) userId = item.createdBy;
      if (item is TestCase) userId = item.createdBy;
      if (item is Bug) userId = item.createdBy;

      if (userId != null && userId.isNotEmpty) {
        userIds.add(userId);
      }
    }
    if (userIds.isNotEmpty) {
      await userCtrl.fetchUsers(userIds);
    }
  }

  // --- BUILD METHOD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final projectController = context.watch<ProjectController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        title: const Text('Work items', style: TextStyle(color: Colors.black)),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(displayInitial,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: WorkItemSearchDelegate(_unifiedWorkItems),
              );
            },
          ),
          IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      drawer: CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildProjectSelector(projectController),
                const SizedBox(height: 16),
                _buildViewToggle(),
                const SizedBox(height: 16),
                if (_selectedView == 0) _buildTableHeader(),
                Expanded(
                  child: _selectedView == 0
                      ? _buildListTable(_unifiedWorkItems)
                      : _buildDetailedColumn(_unifiedWorkItems),
                ),
              ],
            ),
    );
  }

  // --- CÁC WIDGET CON CHO BODY ---
  Widget _buildProjectSelector(ProjectController projectController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Project>(
          value: projectController.selectedProject,
          hint: const Text("Select Project..."),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: projectController.projects.map((project) {
            return DropdownMenuItem<Project>(
              value: project,
              child: Text(project.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (selectedProject) {
            if (selectedProject != null) {
              _onProjectSelected(selectedProject);
            }
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ToggleButtons(
        isSelected: [_selectedView == 0, _selectedView == 1],
        onPressed: (index) => setState(() => _selectedView = index),
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
        selectedColor: Colors.white,
        fillColor: Colors.blue,
        borderColor: Colors.grey[300],
        selectedBorderColor: Colors.blue,
        constraints: BoxConstraints(
            minWidth: (MediaQuery.of(context).size.width - 36) / 2,
            minHeight: 40),
        children: const [Text('List'), Text('Detailed')],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildListTable(List<Object> items) {
    if (items.isEmpty) return const Center(child: Text("No items found."));

    const double stickyColumnWidth = 180.0;
    const double scrollableColumnWidth = 120.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          SizedBox(
            width: stickyColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStickyHeaderCell('WORK ITEM'),
                Expanded(
                  child: ListView.separated(
                    controller: _stickyColumnScrollController,
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) =>
                        _buildStickyItemCell(items[index]),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(
              width: 1, color: Color.fromARGB(255, 219, 219, 219)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: scrollableColumnWidth * 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScrollableHeaderRow(),
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollablePartScrollController,
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) =>
                            _buildScrollableItemRow(items[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- CÁC WIDGET CON CHO BẢNG CỐ ĐỊNH ---
  Widget _buildStickyHeaderCell(String title) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _buildStickyItemCell(Object item) {
    IconData typeIcon = Icons.task;
    Color iconColor = Colors.grey;
    String title = "N/A";
    String? path;

    final projectId =
        context.read<ProjectController>().selectedProject?.projectId;

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

    return GestureDetector(
      onTap: () {
        if (path != null) {
          context.push(path); // ✅ dùng push để đảm bảo có thể pop() quay lại
        }
      },
      child: Container(
        height: 56,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(typeIcon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableHeaderRow() {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Row(
        children: [
          _buildScrollableHeaderCell('PRIORITY', width: 120),
          _buildScrollableHeaderCell('STATUS', width: 120),
          _buildScrollableHeaderCell('ASSIGNEE', width: 120),
        ],
      ),
    );
  }

  Widget _buildScrollableHeaderCell(String title, {double width = 140}) {
    return SizedBox(
      width: width,
      child: Center(
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54))),
    );
  }

  Widget _buildScrollableItemRow(Object item) {
    int? priorityId;
    String statusText = "UNKNOWN";
    Color statusColor = Colors.grey;
    String? assigneeId;

    if (item is UserStory) {
      priorityId = item.priorityId;
      statusText = _getStatusText(item.statusId);
      statusColor = _getStatusColor(item.statusId);
      assigneeId = item.createdBy;
    }
    if (item is TestCase) {
      priorityId = 3;
      statusText = _getStatusText(item.statusId);
      statusColor = _getStatusColor(item.statusId);
      assigneeId = item.createdBy;
    }
    if (item is Bug) {
      priorityId = item.priorityId;
      statusText = item.statusName.toUpperCase();
      statusColor = _getStatusColorFromString(statusText);
      assigneeId = item.createdBy;
    }

    return Container(
      height: 56,
      child: Row(
        children: [
          SizedBox(
              width: 120, child: Center(child: _getPriorityIcon(priorityId))),
          SizedBox(
              width: 120,
              child: Center(child: _buildStatusChip(statusText, statusColor))),
          SizedBox(
            width: 120,
            child: Center(child: _buildAssigneeWidget(assigneeId)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedColumn(List<Object> items) {
    if (items.isEmpty) return const Center(child: Text("No items found."));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildDetailedCard(items[index]);
      },
    );
  }

  Widget _buildDetailedCard(Object item) {
    IconData typeIcon = Icons.task;
    Color iconColor = Colors.grey;
    String title = "N/A";
    String description = "No description.";
    int? priorityId;
    String statusText = "UNKNOWN";
    Color statusColor = Colors.grey;
    String? assigneeId;
    String? detailPath;

    final projectId =
        context.read<ProjectController>().selectedProject?.projectId;

    if (item is UserStory) {
      typeIcon = Icons.library_books_outlined;
      iconColor = Colors.blue;
      title = item.name;
      description = item.description;
      priorityId = item.priorityId;
      statusText = _getStatusText(item.statusId);
      statusColor = _getStatusColor(item.statusId);
      assigneeId = item.createdBy;
      detailPath = '/story/${item.storyId}?projectId=$projectId';
    }
    if (item is TestCase) {
      typeIcon = Icons.check_circle_outline;
      iconColor = Colors.green;
      title = item.testName;
      description = item.description;
      priorityId = 3;
      statusText = _getStatusText(item.statusId);
      statusColor = _getStatusColor(item.statusId);
      assigneeId = item.createdBy;
      detailPath = '/testcase/${item.testCaseId}?projectId=$projectId';
    }
    if (item is Bug) {
      typeIcon = Icons.bug_report_outlined;
      iconColor = Colors.red;
      title = item.title;
      description = item.description;
      priorityId = item.priorityId;
      statusText = item.statusName.toUpperCase();
      statusColor = _getStatusColorFromString(statusText);
      assigneeId = item.createdBy;
      detailPath = '/bug/${item.bugId}?projectId=$projectId';
    }

    return GestureDetector(
      onTap: () {
        if (detailPath != null) context.push(detailPath);
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, color: iconColor, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17))),
                ],
              ),
              const SizedBox(height: 12),
              Text(description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], height: 1.5)),
              const Divider(height: 24),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getPriorityIcon(priorityId),
                      const SizedBox(width: 8),
                      _buildStatusChip(statusText, statusColor),
                    ],
                  ),
                  const Spacer(),
                  Flexible(child: _buildAssigneeWidget(assigneeId)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HELPER ---
  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColorFromString(String status) {
    switch (status) {
      case 'TO DO':
        return Colors.blue;
      case 'IN PROGRESS':
        return Colors.orange;
      case 'DONE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return "TO DO";
      case 2:
        return "IN PROGRESS";
      case 3:
        return "DONE";
      default:
        return "UNKNOWN";
    }
  }

  Widget _getPriorityIcon(int? priority) {
    switch (priority) {
      case 4:
        return Tooltip(
            message: 'Highest',
            child: const Icon(Icons.keyboard_double_arrow_up,
                color: Colors.red, size: 20));
      case 3:
        return Tooltip(
            message: 'High',
            child: const Icon(Icons.keyboard_arrow_up,
                color: Colors.orange, size: 20));
      case 2:
        return Tooltip(
            message: 'Medium',
            child: const Icon(Icons.horizontal_rule,
                color: Colors.amber, size: 20));
      case 1:
        return Tooltip(
            message: 'Low',
            child: const Icon(Icons.keyboard_arrow_down,
                color: Colors.green, size: 20));
      default:
        return const SizedBox(width: 20);
    }
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildAssigneeWidget(String? userId) {
    if (userId == null || userId.isEmpty) {
      return const Text("Unassigned", style: TextStyle(color: Colors.grey));
    }
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final name = userController.getUserName(userId);

        if (name == userId) {
          // Nếu tên chưa được tải về, hiển thị ID (đã được rút gọn)
          // và icon loading nếu controller đang tải
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userController.isFetchingUsers)
                const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5)),
              if (userController.isFetchingUsers) const SizedBox(width: 4),
              Text(
                userId.length > 8 ? '${userId.substring(0, 8)}...' : userId,
                style: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }

        // Nếu đã có tên
        return Tooltip(
          message: name,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor:
                    Colors.primaries[name.hashCode % Colors.primaries.length],
                child: Text(
                    name.length > 1
                        ? name.substring(0, 2)
                        : (name.isNotEmpty ? name[0].toUpperCase() : '?'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              const SizedBox(width: 6),
              Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        );
      },
    );
  }
}
