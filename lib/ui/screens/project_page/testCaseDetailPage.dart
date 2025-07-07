import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/testCaseController.dart';
import '../../../api/controllers/userController.dart';

class TestCaseDetailPage extends StatefulWidget {
  final int testCaseId;
  final String projectId;

  const TestCaseDetailPage(
      {super.key, required this.testCaseId, required this.projectId});

  @override
  State<TestCaseDetailPage> createState() => _TestCaseDetailPageState();
}

class _TestCaseDetailPageState extends State<TestCaseDetailPage> {
  final _sectionExpanded = {
    'description': true,
    'details': true,
    'people': false,
    'timestamps': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final projectId = widget.projectId;

    final testCtrl = context.read<TestCaseController>();
    final userCtrl = context.read<UserController>();

    await testCtrl.loadTestCaseById(projectId, widget.testCaseId);
    final test = testCtrl.selectedTestCase;

    if (test != null) {
      final userIds = {
        if ((test.createdBy ?? '').isNotEmpty) test.createdBy!,
        if ((test.executedBy ?? '').isNotEmpty) test.executedBy!,
      };
      await userCtrl.fetchUsers(userIds);
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    return dt != null ? DateFormat('dd/MM/yyyy - HH:mm').format(dt) : iso;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TestCaseController, UserController>(
      builder: (context, testCtrl, userCtrl, _) {
        final test = testCtrl.selectedTestCase;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F0F0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF0F0F0),
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text("Chi tiết Test Case",
                style: TextStyle(color: Colors.black)),
          ),
          body: testCtrl.isLoading
              ? const Center(child: CircularProgressIndicator())
              : test == null
                  ? const Center(child: Text("Không có dữ liệu"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSection("🧪 Mô tả", 'description', [
                            _infoRow("Tên kiểm thử", test.testName),
                            _infoRow("Mô tả", test.description),
                          ]),
                          _buildSection("📋 Kết quả", 'details', [
                            _infoRow("Kết quả mong đợi", test.expectedResult),
                            _infoRow("Kết quả thực tế", test.actualResult),
                            _infoRow("Trạng thái", _statusLabel(test.statusId)),
                          ]),
                          _buildSection("👤 Người liên quan", 'people', [
                            _infoRow("Người tạo",
                                userCtrl.getUserName(test.createdBy ?? '')),
                            _infoRow("Người thực hiện",
                                userCtrl.getUserName(test.executedBy ?? '')),
                          ]),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  String _statusLabel(int? id) {
    switch (id) {
      case 1:
        return "Chưa thực hiện";
      case 2:
        return "Đạt";
      case 3:
        return "Không đạt";
      default:
        return "Không xác định";
    }
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
            onTap: () => setState(() => _sectionExpanded[key] = !expanded),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value.isNotEmpty ? value : '—')),
        ],
      ),
    );
  }
}
