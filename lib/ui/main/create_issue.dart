import 'package:flutter/material.dart';

class CreateIssueScreen extends StatefulWidget {
  const CreateIssueScreen({super.key});

  @override
  State<CreateIssueScreen> createState() => _CreateIssueScreenState();
}

class _CreateIssueScreenState extends State<CreateIssueScreen> {
  String selectedProject = "Core Work WA";
  String selectedIssueType = "Task";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title:
            const Text("Create issue", style: TextStyle(color: Colors.black)),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.blue)),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Create", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _pillDropdown<String>(
                  value: selectedProject,
                  items: ["Core Work WA", "Mobile App", "Backend API"],
                  icon: Icons.business,
                  onChanged: (val) {
                    setState(() {
                      selectedProject = val!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pillDropdown<String>(
                  value: selectedIssueType,
                  items: ["Task", "Bug", "Story"],
                  icon: Icons.check_box,
                  onChanged: (val) {
                    setState(() {
                      selectedIssueType = val!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Add an issue summary...",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 24),
          _section(
            title: "Description",
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Add a description...",
                border: InputBorder.none,
              ),
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: "Attachments",
            child: OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Add attachment"),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: "More fields",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _moreFieldItem("Sprint", "None"),
                _moreFieldItem("Parent", "None"),
                _moreFieldItem("Components", "None"),
                _moreFieldItem("Reporter *", "Me", leadingCircle: true),
                _moreFieldItem("Fix versions", "None"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillDropdown<T>({
    required T value,
    required List<T> items,
    required IconData icon,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.toString())),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _moreFieldItem extends StatelessWidget {
  final String label;
  final String value;
  final bool leadingCircle;

  const _moreFieldItem(this.label, this.value, {this.leadingCircle = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          if (leadingCircle)
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.orange,
              child: Text('D',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
