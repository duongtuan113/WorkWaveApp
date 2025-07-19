import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';
import '../../../api/controllers/projectController.dart';
import '../../widgets/CustomDrawer.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  AuthStatus? _previousAuthStatus;
  String get displayInitial {
    final currentUser = context.read<AuthController>().currentUser;
    final name = currentUser?.userName ?? 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authController = context.read<AuthController>();
      _previousAuthStatus = authController.status;
      if (_previousAuthStatus == AuthStatus.authenticated) {
        print("🟢 [ProjectPage] Đã đăng nhập sẵn, tải projects...");
        context.read<ProjectController>().loadProjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final projectController = context.watch<ProjectController>();

    final currentAuthStatus = authController.status;
    if (currentAuthStatus != _previousAuthStatus &&
        currentAuthStatus == AuthStatus.authenticated) {
      print(
          "🎉 [ProjectPage] Phát hiện đăng nhập thành công! Bắt đầu tải projects...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProjectController>().loadProjects();
        }
      });
    }

    _previousAuthStatus = currentAuthStatus;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(displayInitial,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 30, color: Colors.blue),
              onPressed: () => _createProject(context),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
      body: _buildProjectList(authController, projectController),
    );
  }

  Widget _buildProjectList(AuthController auth, ProjectController projects) {
    if (auth.status != AuthStatus.authenticated) {
      return const Center(child: Text("Vui lòng đăng nhập để xem dự án."));
    }
    if (projects.isLoading && projects.projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (projects.error != null) {
      return Center(child: Text("Lỗi: ${projects.error}"));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Project",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            onChanged: (value) {
              context.read<ProjectController>().searchProjects(value);
            },
            decoration: InputDecoration(
              hintText: "Search Project",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[300],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 20),
          const Text("All Project",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (projects.filteredProjects.isEmpty)
            const Center(child: Text('No projects available'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.filteredProjects.length,
              itemBuilder: (context, index) {
                final project = projects.filteredProjects[index];
                return RecentItemCard(
                  icon: Icons.folder_open,
                  title: project.name,
                  subtitle: project.description ?? '',
                  iconColor: Colors.blue,
                  route: '/board/${project.projectId}',
                );
              },
            ),
        ],
      ),
    );
  }

  void _createProject(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int selectedStatusId = 1;
    DateTime? startDate;
    DateTime? endDate;
    final dateFormat = DateFormat('yyyy-MM-dd');

    Future<void> _selectDate(BuildContext context, DateTime? initialDate,
        Function(DateTime) onPicked) async {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          final fullDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          onPicked(fullDate);
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Create New Project",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Project Name",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Project Description",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedStatusId,
                    decoration: InputDecoration(
                      labelText: "Project Status",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.flag),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Not Started")),
                      DropdownMenuItem(value: 2, child: Text("In Progress")),
                      DropdownMenuItem(value: 3, child: Text("Completed")),
                      DropdownMenuItem(value: 4, child: Text("On Hold")),
                      DropdownMenuItem(value: 5, child: Text("Cancelled")),
                    ],
                    onChanged: (value) {
                      if (value != null)
                        setState(() => selectedStatusId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, startDate,
                        (picked) => setState(() => startDate = picked)),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        startDate != null
                            ? "${startDate!.toLocal()}".split('.').first
                            : "Select Start Date",
                        style: TextStyle(
                            color: startDate != null
                                ? Colors.black
                                : Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, endDate,
                        (picked) => setState(() => endDate = picked)),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "End Date",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        endDate != null
                            ? "${endDate!.toLocal()}".split('.').first
                            : "Select End Date",
                        style: TextStyle(
                            color: endDate != null
                                ? Colors.black
                                : Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          side: BorderSide.none,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final desc = descController.text.trim();
                          if (name.isEmpty ||
                              desc.isEmpty ||
                              startDate == null ||
                              endDate == null) {
                            Fluttertoast.showToast(
                                msg: "Please fill all fields and dates");
                            return;
                          }

                          final authController = Provider.of<AuthController>(
                              context,
                              listen: false);

                          try {
                            final projectController =
                                Provider.of<ProjectController>(context,
                                    listen: false);
                            await projectController.createNewProject({
                              'name': name,
                              'description': desc,
                              'statusId': selectedStatusId,
                              'startDate': dateFormat.format(startDate!),
                              'endDate': dateFormat.format(endDate!),
                            });
                            await projectController.loadProjects();
                            Fluttertoast.showToast(
                                msg: "Project created successfully");
                            Navigator.of(context).pop();
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "Failed to create project: $e");
                          }
                        },
                        child: const Text("Create"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final String route;

  const RecentItemCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
