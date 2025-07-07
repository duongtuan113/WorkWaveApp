import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';
import '../../../api/controllers/projectController.dart';
import '../../../api/controllers/spinController.dart';
import '../../../api/controllers/userStoryController.dart';
import '../../../api/models/userStory/addUserStory.dart';
import '../../../api/models/userStory/userStory.dart';
import '../../../api/services/apiWebSocketService.dart';
import '../../widgets/project_tab_bar.dart';

class BacklogPage extends StatefulWidget {
  final String projectId;
  final String fromPage;

  const BacklogPage(
      {required this.projectId, this.fromPage = 'project', super.key});

  @override
  State<BacklogPage> createState() => _BacklogPageState();
}

void _showSprintSelector(BuildContext context, SprintController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final sprints = controller.sprints;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text('Select Sprint',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                itemCount: sprints.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final sprint = sprints[index];
                  final isSelected =
                      sprint.sprintId == controller.selectedSprint?.sprintId;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: Text(sprint.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        "${sprint.startDate.substring(0, 10)} → ${sprint.endDate.substring(0, 10)}",
                        style: const TextStyle(fontSize: 12)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: Colors.blueAccent)
                        : const Icon(Icons.radio_button_unchecked,
                            color: Colors.grey),
                    onTap: () {
                      controller.selectSprint(sprint);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _BacklogPageState extends State<BacklogPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = context.read<AuthController>();
      final userStoryController = context.read<UserStoryController>();
      final sprintController = context.read<SprintController>();
      final projectController = context.read<ProjectController>();
      final token = authController.accessToken!;
      final projectId = projectController.selectedProject?.projectId;

      if (projectId == null) return;

      await sprintController.loadAllSprints(projectId);
      if (sprintController.selectedSprint != null) {
        await userStoryController.loadAllStories(projectId);
      }

      if (!WebSocketService().isConnected) {
        WebSocketService().connect();
      }

      WebSocketService().setMessageHandler((eventType, data) async {
        if (["userstory-created", "userstory-updated", "userstory-deleted"]
            .contains(eventType)) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 800), () async {
            await userStoryController.loadAllStories(projectId);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    // ❌ Đừng disconnect tại đây nữa
    // if (WebSocketService().isConnected) {
    //   WebSocketService().disconnect();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyController = context.watch<UserStoryController>();
    final sprintController = context.watch<SprintController>();
    final projectController = context.watch<ProjectController>();
    final selectedProject = projectController.selectedProject;
    final selectedSprint = sprintController.selectedSprint;
    final sprints = sprintController.sprints;
    final stories = storyController.stories;
    final backlogStories = stories.where((s) => s.sprintId == null).toList();
    final sprintMap = <int, List<UserStory>>{};
    for (var story in stories.where((s) => s.sprintId != null)) {
      sprintMap.putIfAbsent(story.sprintId!, () => []).add(story);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.fromPage == 'home') {
              context.go('/home_page');
            } else {
              context.go('/project');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedProject?.name ?? '',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
            InkWell(
              onTap: () => _showSprintSelector(context, sprintController),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedSprint?.name ?? 'Select Sprint',
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
        bottom: ProjectTabBar(selectedIndex: 2, projectId: widget.projectId),
        scrolledUnderElevation: 0,
      ),
      body: storyController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SprintWidget(
                  title: 'Backlog',
                  workItems: backlogStories,
                  sprintId: null,
                ),
                if (sprints.isEmpty)
                  const Text(
                    '⚠️ Không có Sprint nào được tạo',
                    style: TextStyle(color: Colors.black54),
                  ),
                ...sprints.map((sprint) {
                  final sprintId = sprint.sprintId;
                  final storiesInSprint = sprintMap[sprintId] ?? [];
                  return SprintWidget(
                    title: sprint.name,
                    workItems: storiesInSprint,
                    sprintId: sprintId,
                  );
                }),
              ],
            ),
    );
  }
}

class SprintWidget extends StatefulWidget {
  final String title;
  final List<UserStory> workItems;
  final int? sprintId; // sprintId hoặc null cho backlog

  const SprintWidget({
    super.key,
    required this.title,
    required this.workItems,
    required this.sprintId,
  });

  @override
  State<SprintWidget> createState() => _SprintWidgetState();
}

class _SprintWidgetState extends State<SprintWidget> {
  bool showInput = false;
  bool _expanded = true;
  final TextEditingController _controller = TextEditingController();

  void _toggleInput() => setState(() => showInput = !showInput);
  void _toggleExpand() => setState(() => _expanded = !_expanded);

  Future<void> _submitNewStory(String name) async {
    if (name.trim().isEmpty) return;

    final userStoryController = context.read<UserStoryController>();
    final authController = context.read<AuthController>();
    final projectController = context.read<ProjectController>();

    final token = authController.accessToken!;
    final projectId = projectController.selectedProject!.projectId;

    final newStory = AddUserStory(
      name: name,
      description: '',
      priorityId: 1,
      statusId: 1,
      sprintId: widget.sprintId,
      assignedTo: null,
      epicId: null,
    );

    final success = await userStoryController.addStory(
      projectId: projectId,
      newStory: newStory,
    );

    if (success) {
      _controller.clear();
      setState(() => showInput = false);
      // Giữ nguyên loadAllStories ở đây là đúng rồi
      await userStoryController.loadAllStories(projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<UserStory>(
      onWillAccept: (data) => data?.sprintId != widget.sprintId,
      onAccept: (data) async {
        final userStoryController = context.read<UserStoryController>();
        final authController = context.read<AuthController>();
        final projectController = context.read<ProjectController>();

        final token = authController.accessToken!;
        final projectId = projectController.selectedProject!.projectId;

        final updatedStory = data.copyWith(
            sprintId: widget.sprintId); // <- có thể là null nếu kéo về backlog

        final success = await userStoryController.updateStory(
          updatedStory: updatedStory,
        );

        if (success) {
          // <<< ĐÂY LÀ THAY ĐỔI QUAN TRỌNG
          // Tải lại toàn bộ story của project để cập nhật cả sprint nguồn và đích
          await userStoryController.loadAllStories(projectId);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _toggleExpand,
                  child: Row(
                    children: [
                      Icon(_expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right),
                      Text(widget.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? Column(
                          children: [
                            ...widget.workItems.map((item) => WorkItem(
                                  item: item,
                                  key: ValueKey(item.storyId),
                                )),
                            const Divider(),
                            showInput
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        hintText: "Nhập tên công việc mới",
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: _submitNewStory,
                                    ),
                                  )
                                : InkWell(
                                    onTap: _toggleInput,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.add),
                                        SizedBox(width: 6),
                                        Text("Create work item"),
                                      ],
                                    ),
                                  ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WorkItem extends StatelessWidget {
  final UserStory item;

  const WorkItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final projectId =
        context.read<ProjectController>().selectedProject!.projectId;

    return Draggable<UserStory>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(item.name, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildListTile(context, projectId),
      ),
      child: _buildListTile(context, projectId),
    );
  }

  Widget _buildListTile(BuildContext context, String projectId) {
    return InkWell(
      onTap: () {
        context.push('/story/${item.storyId}?projectId=$projectId');
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.check_box, color: Colors.blue),
        title: Text(item.name),
        subtitle: Row(
          children: [
            Text(item.description ?? ''),
            const SizedBox(width: 6),
            if ((item.assignedTo ?? '').isNotEmpty)
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.orange,
                child: Text(
                  item.assignedTo![0].toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }
}
