import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';
import '../../../api/controllers/spinController.dart';
import '../../../api/controllers/userController.dart';
import '../../../api/controllers/userStoryController.dart';

class StoryDetailPage extends StatefulWidget {
  final int storyId;
  final String projectId;

  const StoryDetailPage({
    super.key,
    required this.storyId,
    required this.projectId,
  });

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _sectionExpanded = {
    'description': true,
    'details': true,
    'timestamps': false,
    'people': false,
  };

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedAssignedTo;
  int? _selectedPriorityId;
  int? _selectedSprintId;
  int? _selectedEpicId;

  static const Map<int, String> priorityMap = {
    1: 'Low',
    2: 'Medium',
    3: 'High',
    4: 'Highest',
  };

  static const Map<int, String> epicMap = {
    1: 'Not Started',
    2: 'In Progress',
    3: 'Completed',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStory());
  }

  Future<void> _loadStory() async {
    final userStoryController = context.read<UserStoryController>();
    final userController = context.read<UserController>();
    final sprintController = context.read<SprintController>();

    await userStoryController.loadStoryById(
      storyId: widget.storyId,
      projectId: widget.projectId,
    );

    final authController = context.read<AuthController>();
    final token = authController.accessToken;
    if (token == null || token.isEmpty) {
      print("❌ Token null hoặc rỗng → bỏ qua loadProjectMembers");
      return;
    }

    await userController.loadProjectMembers(
      projectId: widget.projectId,
      token: token,
    );

    await sprintController.loadAllSprints(widget.projectId);
    print("🔐 Access token: $token");
    print("📁 Project ID: ${widget.projectId}");
    final story = userStoryController.story;
    if (story != null) {
      _nameController.text = story.name;
      _descController.text = story.description;
      _selectedAssignedTo = story.assignedTo;
      _selectedPriorityId = story.priorityId;
      _selectedSprintId = story.sprintId;
      _selectedEpicId = story.epicId;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return "-";
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserStoryController, UserController, SprintController>(
      builder: (context, storyCtrl, userCtrl, sprintCtrl, _) {
        final story = storyCtrl.story;
        final sprints = sprintCtrl.sprints;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F0F0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF0F0F0),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text("Chi tiết công việc",
                style: TextStyle(color: Colors.black)),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: "Lưu thay đổi",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updated = story!.copyWith(
                      name: _nameController.text,
                      description: _descController.text,
                      assignedTo: _selectedAssignedTo ?? story.assignedTo,
                      priorityId: _selectedPriorityId ?? story.priorityId,
                      sprintId: _selectedSprintId ?? story.sprintId,
                      epicId: _selectedEpicId ?? story.epicId,
                    );

                    // 👇 THÊM DÒNG NÀY để in dữ liệu gửi lên
                    print('🛰️ PUT payload: ${updated.toJson()}');

                    final success =
                        await storyCtrl.updateStory(updatedStory: updated);
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(success
                              ? "✅ Cập nhật thành công"
                              : "❌ Cập nhật thất bại")),
                    );

                    if (success) Navigator.pop(context);
                  }
                },
              )
            ],
          ),
          body: storyCtrl.isLoading || story == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSection("📄 Mô tả", 'description', [
                          _editRow("Tên công việc", _nameController,
                              required: true),
                          _editRow("Mô tả", _descController, maxLines: 4),
                        ]),
                        _buildSection("📌 Chi tiết", 'details', [
                          _dropdownRow<String>(
                            label: "Assigned To",
                            value: userCtrl
                                    .getUserIds()
                                    .contains(_selectedAssignedTo)
                                ? _selectedAssignedTo
                                : null,
                            items: userCtrl.getUserIds().map((id) {
                              return DropdownMenuItem(
                                value: id,
                                child: Text(userCtrl.getUserName(id)),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedAssignedTo = val),
                          ),
                          _dropdownRow<int>(
                            label: "Priority",
                            value: priorityMap.containsKey(_selectedPriorityId)
                                ? _selectedPriorityId
                                : null,
                            items: priorityMap.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPriorityId = val),
                          ),
                          _dropdownRow<int>(
                            label: "Sprint",
                            value: sprints
                                    .any((s) => s.sprintId == _selectedSprintId)
                                ? _selectedSprintId
                                : null,
                            items: sprints
                                .map((s) => DropdownMenuItem(
                                      value: s.sprintId,
                                      child: Text(s.name),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSprintId = val),
                          ),
                          _dropdownRow<int>(
                            label: "Epic",
                            value: epicMap.containsKey(_selectedEpicId)
                                ? _selectedEpicId
                                : null,
                            items: epicMap.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedEpicId = val),
                          ),
                        ]),
                        _buildSection("🕒 Thời gian", 'timestamps', [
                          _infoRow("Tạo lúc", _formatDate(story.createdAt)),
                          _infoRow(
                              "Cập nhật lúc", _formatDate(story.updatedAt)),
                        ]),
                        _buildSection("👤 Người liên quan", 'people', [
                          _infoRow("Người tạo",
                              userCtrl.getUserName(story.createdBy)),
                          _infoRow("Người cập nhật",
                              userCtrl.getUserName(story.updatedBy)),
                        ]),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSection(String title, String key, List<Widget> children) {
    final expanded = _sectionExpanded[key] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _sectionExpanded[key] = !(expanded)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (expanded) ...children,
        ],
      ),
    );
  }

  Widget _editRow(String label, TextEditingController controller,
      {int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: required
                ? (value) => (value == null || value.isEmpty)
                    ? 'Không được để trống'
                    : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownRow<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            value: items.any((item) => item.value == value) ? value : null,
            items: items,
            onChanged: onChanged,
            validator: (val) => null,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
