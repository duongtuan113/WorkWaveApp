import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/bugController.dart';
import '../../../api/controllers/userController.dart';
import '../../../api/models/bug/bug.dart';

class BugDetailPage extends StatefulWidget {
  final int bugId;
  final String projectId;

  const BugDetailPage(
      {super.key, required this.bugId, required this.projectId});

  @override
  State<BugDetailPage> createState() => _BugDetailPageState();
}

class _BugDetailPageState extends State<BugDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _sectionExpanded = {
    'description': true,
    'details': true,
    'timestamps': false,
    'people': false,
  };

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _assignedTo;

  static const Map<int, String> priorityMap = {
    1: 'Low',
    2: 'Medium',
    3: 'High',
    4: 'Highest',
  };

  static const Map<int, String> severityMap = {
    1: 'Minor',
    2: 'Major',
    3: 'Critical',
    4: 'Blocker',
  };

  static const Map<int, String> statusMap = {
    1: 'Open',
    2: 'In Progress',
    3: 'Resolved',
    4: 'Closed',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBug());
  }

  Future<void> _loadBug() async {
    final bugCtrl = context.read<BugController>();
    final userCtrl = context.read<UserController>();

    await bugCtrl.loadBug(widget.projectId);
    final bug = bugCtrl.bug.firstWhere((b) => b.bugId == widget.bugId,
        orElse: () => throw Exception("Not found"));

    _titleController.text = bug.title;
    _descController.text = bug.description;
    _assignedTo = bug.assignedTo;

    final userIds = {
      bug.createdBy,
      bug.updatedBy,
      bug.reportedBy,
      bug.assignedTo,
    }.where((id) => id.trim().isNotEmpty).toSet();

    for (final id in userIds) {
      await userCtrl.fetchUserByIdOnce(id);
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    return dt != null ? DateFormat('dd/MM/yyyy - HH:mm').format(dt) : iso;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BugController, UserController>(
      builder: (context, bugCtrl, userCtrl, _) {
        Bug? bug;
        try {
          bug = bugCtrl.bug.firstWhere((b) => b.bugId == widget.bugId);
        } catch (_) {
          bug = null;
        }

        if (bug == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF0F0F0),
          // appBar: AppBar(
          //   backgroundColor: const Color(0xFFF0F0F0),
          //   elevation: 0,
          //   scrolledUnderElevation: 0,
          //   iconTheme: const IconThemeData(color: Colors.black),
          //   title: const Text("Chi tiết Bug",
          //       style: TextStyle(color: Colors.black)),
          // ),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF0F0F0),
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/');
                }
              },
            ),
            title: const Text("Chi tiết Bug",
                style: TextStyle(color: Colors.black)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSection("🐞 Mô tả", 'description', [
                    _editRow("Tiêu đề", _titleController, required: true),
                    _editRow("Mô tả", _descController, maxLines: 4),
                  ]),
                  _buildSection("📌 Chi tiết", 'details', [
                    _dropdownRow<String>(
                      label: "Assigned To",
                      value: _assignedTo,
                      items: userCtrl.getUserIds().map((id) {
                        return DropdownMenuItem(
                          value: id,
                          child: Text(userCtrl.getUserName(id)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _assignedTo = val),
                    ),
                    _dropdownRow<int>(
                      label: "Severity",
                      value: bug.severityId,
                      items: severityMap.entries.map((e) {
                        return DropdownMenuItem(
                            value: e.key, child: Text(e.value));
                      }).toList(),
                      onChanged: (_) {},
                    ),
                    _dropdownRow<int>(
                      label: "Priority",
                      value: bug.priorityId,
                      items: priorityMap.entries.map((e) {
                        return DropdownMenuItem(
                            value: e.key, child: Text(e.value));
                      }).toList(),
                      onChanged: (_) {},
                    ),
                    _dropdownRow<int>(
                      label: "Status",
                      value: bug.statusId,
                      items: statusMap.entries.map((e) {
                        return DropdownMenuItem(
                            value: e.key, child: Text(e.value));
                      }).toList(),
                      onChanged: (_) {},
                    ),
                  ]),
                  _buildSection("🕒 Thời gian", 'timestamps', [
                    _infoRow("Tạo lúc", _formatDate(bug.createdAt)),
                    _infoRow("Cập nhật lúc", _formatDate(bug.updatedAt)),
                  ]),
                  _buildSection("👤 Người liên quan", 'people', [
                    _infoRow("Người tạo", userCtrl.getUserName(bug.createdBy)),
                    _infoRow(
                        "Người cập nhật", userCtrl.getUserName(bug.updatedBy)),
                    _infoRow(
                        "Người báo lỗi", userCtrl.getUserName(bug.reportedBy)),
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
                ? (val) =>
                    (val == null || val.isEmpty) ? 'Không được để trống' : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
