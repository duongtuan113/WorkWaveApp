import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';
import '../../../api/controllers/projectController.dart';
import '../../../api/controllers/spinController.dart';
import '../../../api/controllers/userStoryController.dart';
import '../../../api/models/userStory/addUserStory.dart';
import '../../../api/services/apiWebSocketService.dart';
import '../../widgets/project_tab_bar.dart';

class BoardPage extends StatefulWidget {
  final String projectId;
  const BoardPage({super.key, required this.projectId});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  bool _isDragging = false;
  Timer? _debounce;

  final Map<String, TextEditingController> _controllers = {
    'To Do': TextEditingController(),
    'In Progress': TextEditingController(),
    'Done': TextEditingController(),
  };
  final Map<String, bool> _showInputs = {
    'To Do': false,
    'In Progress': false,
    'Done': false,
  };
  final Map<String, int> _statusMap = {
    'To Do': 1,
    'In Progress': 2,
    'Done': 3,
  };

  Map<String, List<_TaskCardData>> _tasks = {
    'To Do': [],
    'In Progress': [],
    'Done': [],
  };
  // @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final projectController = context.read<ProjectController>();
  //     final userStoryController = context.read<UserStoryController>();
  //     final sprintController = context.read<SprintController>();
  //     final authController = context.read<AuthController>();
  //
  //     final token = authController.accessToken;
  //     final projectId = widget.projectId;
  //
  //     projectController.setSelectedProjectById(projectId);
  //
  //     if (token != null) {
  //       await sprintController.loadActiveSprintsOnly(projectId);
  //
  //       final selectedSprint = sprintController.selectedSprint;
  //
  //       if (selectedSprint != null) {
  //         await userStoryController.loadStories(
  //           projectId,
  //           selectedSprint.sprintId,
  //         );
  //       }
  //     }
  //   });
  // }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectController = context.read<ProjectController>();
      final userStoryController = context.read<UserStoryController>();
      final sprintController = context.read<SprintController>();
      final authController = context.read<AuthController>();

      final token = authController.accessToken;
      final projectId = widget.projectId;

      projectController.setSelectedProjectById(projectId);

      if (token != null) {
        await sprintController.loadActiveSprintsOnly(projectId);

        final selectedSprint = sprintController.selectedSprint;

        if (selectedSprint != null) {
          await userStoryController.loadStories(
            projectId,
            selectedSprint.sprintId,
          );
        }
      }

      // ✅ WebSocket init
      if (!WebSocketService().isConnected) {
        WebSocketService().connect();
      }

      WebSocketService().setMessageHandler((eventType, data) async {
        if (["userstory-created", "userstory-updated", "userstory-deleted"]
            .contains(eventType)) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 800), () async {
            final selectedSprint =
                context.read<SprintController>().selectedSprint;
            final currentProjectId =
                context.read<ProjectController>().selectedProject?.projectId;
            if (currentProjectId != null && selectedSprint != null) {
              await context
                  .read<UserStoryController>()
                  .loadStories(currentProjectId, selectedSprint.sprintId);
            }
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userStoryController = context.watch<UserStoryController>();

    Map<String, List<_TaskCardData>> newTasks = {
      'To Do': [],
      'In Progress': [],
      'Done': [],
    };

    for (var story in userStoryController.stories) {
      final assignedTo = story.assignedTo;

      final cardData = _TaskCardData(
        storyId: story.storyId,
        name: story.name,
        description:
            story.description.isNotEmpty ? story.description : 'No description',
        avatarText: (assignedTo != null && assignedTo.isNotEmpty)
            ? assignedTo.characters.first.toUpperCase()
            : 'N/A',
        avatarColor: _getAvatarColor(assignedTo),
        statusId: story.statusId,
      );

      switch (story.statusId) {
        case 1:
          newTasks['To Do']!.add(cardData);
          break;
        case 2:
          newTasks['In Progress']!.add(cardData);
          break;
        case 3:
          newTasks['Done']!.add(cardData);
          break;
        default:
          newTasks['To Do']!.add(cardData);
      }
    }

    setState(() {
      _tasks = newTasks;
    });
  }

  Color _getAvatarColor(String? assignedTo) {
    if (assignedTo == null || assignedTo.isEmpty) return Colors.grey;
    return Colors.primaries[assignedTo.hashCode % Colors.primaries.length];
  }

  void _toggleInput(String column) {
    setState(() {
      _showInputs[column] = !_showInputs[column]!;
    });
  }

  void _showSprintSelector(BuildContext context, SprintController sprintCtrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.drag_handle, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                '📅 Choose a Sprint',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...sprintCtrl.sprints.map((sprint) {
                final isSelected = sprint == sprintCtrl.selectedSprint;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected ? Colors.blue.shade50 : null,
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    sprint.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () async {
                    sprintCtrl.selectSprint(sprint);

                    final token = context.read<AuthController>().accessToken!;
                    final userStoryCtrl = context.read<UserStoryController>();
                    final projectId = context
                        .read<ProjectController>()
                        .selectedProject!
                        .projectId;

                    await userStoryCtrl.loadStories(projectId, sprint.sprintId);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addTask(String column, String name) async {
    if (name.trim().isEmpty) return;

    final userStoryController = context.read<UserStoryController>();
    final authController = context.read<AuthController>();
    final projectController = context.read<ProjectController>();
    final sprintController = context.read<SprintController>();

    final token = authController.accessToken!;
    final projectId = projectController.selectedProject!.projectId;
    final sprintId = sprintController.selectedSprint?.sprintId;

    if (sprintId == null) return;

    final newStory = AddUserStory(
      name: name.trim(),
      description: "",
      priorityId: 1,
      statusId: _statusMap[column]!,
      sprintId: sprintId,
    );

    bool success = await userStoryController.addStory(
      projectId: projectId,
      newStory: newStory,
    );

    if (success) {
      await userStoryController.loadStories(projectId, sprintId); // ✅ load lại

      _controllers[column]?.clear();
      setState(() {
        _showInputs[column] = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thêm công việc mới')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStoryController = context.watch<UserStoryController>();
    final sprintController = context.watch<SprintController>();
    final projectController = context.watch<ProjectController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(
                  '/project'); // hoặc '/dashboard' hoặc '/home_page' tùy bạn
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectController.selectedProject?.name ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: () => _showSprintSelector(context, sprintController),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sprintController.selectedSprint?.name ?? 'Select Sprint',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 22, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
        actions: const [Icon(Icons.more_vert)],
        bottom: ProjectTabBar(selectedIndex: 1, projectId: widget.projectId),
        scrolledUnderElevation: 0,
      ),
      body: sprintController.selectedSprint == null
          ? const Center(
              child: Text(
                '⚠️ Không có Sprint đang hoạt động',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : userStoryController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _tasks.keys.map((status) {
                      return _buildTaskColumn(status);
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildTaskColumn(String status) {
    const double maxListHeight = 500;

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxListHeight),
            child: DragTarget<_DragData>(
              onWillAccept: (data) => true,
              onAccept: (data) async {
                final userStoryController = context.read<UserStoryController>();
                final token = context.read<AuthController>().accessToken!;
                final oldStatus = data.task.statusId;
                final newStatus = _statusMap[status]!;

                setState(() {
                  _tasks[data.from]!.remove(data.task);
                  _tasks[status]!.add(data.task.copyWith(statusId: newStatus));
                });

                bool success = await userStoryController.updateStoryStatus(
                  data.task.storyId,
                  newStatus,
                );

                if (!success) {
                  setState(() {
                    _tasks[status]!
                        .removeWhere((t) => t.storyId == data.task.storyId);
                    _tasks[data.from]!.add(data.task);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Không thể cập nhật trạng thái công việc')),
                  );
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isEmpty = _tasks[status]!.isEmpty;

                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: (_isDragging && isEmpty)
                      ? const BoxConstraints(minHeight: 150)
                      : const BoxConstraints(),
                  child: isEmpty
                      ? (_isDragging
                          ? Container(
                              height: 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: candidateData.isNotEmpty
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.grey[300],
                              ),
                              child: const Text(
                                "Drag task here",
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : const SizedBox.shrink())
                      : SingleChildScrollView(
                          child: Column(
                            children: _tasks[status]!
                                .map((task) => Draggable<_DragData>(
                                      data: _DragData(task: task, from: status),
                                      onDragStarted: () {
                                        setState(() {
                                          _isDragging = true;
                                        });
                                      },
                                      onDragEnd: (details) {
                                        setState(() {
                                          _isDragging = false;
                                        });
                                      },
                                      feedback: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 280,
                                          child: _TaskCard(
                                            storyId: task.storyId,
                                            name: task.name,
                                            description: task.description,
                                            avatarText: task.avatarText,
                                            avatarColor: task.avatarColor,
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.5,
                                        child: _TaskCard(
                                          storyId: task.storyId,
                                          name: task.name,
                                          description: task.description,
                                          avatarText: task.avatarText,
                                          avatarColor: task.avatarColor,
                                        ),
                                      ),
                                      child: _TaskCard(
                                        storyId: task.storyId,
                                        name: task.name,
                                        description: task.description,
                                        avatarText: task.avatarText,
                                        avatarColor: task.avatarColor,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _showInputs[status]!
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _controllers[status],
                    decoration: const InputDecoration(
                      hintText: "Nhập tên công việc mới",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _addTask(status, value),
                  ),
                )
              : InkWell(
                  onTap: () => _toggleInput(status),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: const [
                        Icon(Icons.add),
                        SizedBox(width: 6),
                        Text("Create", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _TaskCardData {
  final int storyId;
  final String name;
  final String description;
  final String avatarText;
  final Color avatarColor;
  final int statusId;

  _TaskCardData({
    required this.storyId,
    required this.name,
    required this.description,
    required this.avatarText,
    required this.avatarColor,
    required this.statusId,
  });

  _TaskCardData copyWith({
    int? storyId,
    String? name,
    String? description,
    String? avatarText,
    Color? avatarColor,
    int? statusId,
  }) {
    return _TaskCardData(
      storyId: storyId ?? this.storyId,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarText: avatarText ?? this.avatarText,
      avatarColor: avatarColor ?? this.avatarColor,
      statusId: statusId ?? this.statusId,
    );
  }
}

class _DragData {
  final _TaskCardData task;
  final String from;

  _DragData({required this.task, required this.from});
}

class _TaskCard extends StatelessWidget {
  final int storyId;
  final String name;
  final String description;
  final String avatarText;
  final Color avatarColor;

  const _TaskCard({
    required this.storyId,
    required this.name,
    required this.description,
    required this.avatarText,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final projectId =
            context.read<ProjectController>().selectedProject?.projectId;
        if (projectId != null) {
          context.push('/story/$storyId?projectId=$projectId');
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: avatarColor,
                    child: Text(
                      avatarText,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('STORY-${storyId.toString().padLeft(4, '0')}'),
                  const Spacer(),
                  const Icon(Icons.more_vert),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
