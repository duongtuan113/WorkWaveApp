// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../api/controllers/projectController.dart';
// import '../../../api/controllers/spinController.dart';
// import '../../widgets/project_tab_bar.dart';
//
// class SummaryPage extends StatelessWidget {
//   final String projectId;
//   const SummaryPage({required this.projectId, super.key});
//
//   void _showSprintSelector(BuildContext context, SprintController controller) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         final sprints = controller.sprints;
//
//         return ListView.separated(
//           padding: const EdgeInsets.all(16),
//           itemCount: sprints.length,
//           separatorBuilder: (_, __) => const Divider(),
//           itemBuilder: (_, index) {
//             final sprint = sprints[index];
//             return ListTile(
//               title: Text(sprint.name),
//               subtitle: Text(
//                 "${sprint.startDate.substring(0, 10)} → ${sprint.endDate.substring(0, 10)}",
//               ),
//               onTap: () {
//                 controller.selectSprint(sprint);
//                 Navigator.pop(context);
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final projectCtrl = context.watch<ProjectController>();
//     final sprintCtrl = context.watch<SprintController>();
//     final project = projectCtrl.projects.firstWhere(
//       (p) => p.projectId == projectId,
//       orElse: () => projectCtrl.selectedProject!,
//     );
//     final sprint = sprintCtrl.selectedSprint;
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         iconTheme: const IconThemeData(color: Colors.black),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             if (Navigator.of(context).canPop()) {
//               Navigator.of(context).pop();
//             } else {
//               Navigator.of(context).pushReplacementNamed('/');
//             }
//           },
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(project.name,
//                 style: const TextStyle(fontSize: 14, color: Colors.grey)),
//             InkWell(
//               onTap: () => _showSprintSelector(context, sprintCtrl),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     sprint?.name ?? 'Select Sprint',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   const Icon(Icons.expand_more, size: 22, color: Colors.black),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: const [Icon(Icons.more_vert)],
//         bottom: ProjectTabBar(selectedIndex: 0, projectId: projectId),
//         scrolledUnderElevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(12),
//         children: [
//           _buildTopStats(),
//           const SizedBox(height: 16),
//           _buildStatusOverview(),
//           const SizedBox(height: 16),
//           _buildPriorityBreakdown(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTopStats() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _statCard("0 created", "in the last 7 days", Icons.add),
//         _statCard("0 due", "in the next 7 days", Icons.calendar_today),
//       ],
//     );
//   }
//
//   Widget _statCard(String title, String subtitle, IconData icon) {
//     return Expanded(
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Icon(icon, size: 24, color: Colors.grey),
//               const SizedBox(height: 8),
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               Text(subtitle,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusOverview() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Status overview",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const Text("in the last 14 days",
//                 style: TextStyle(color: Colors.grey)),
//             const SizedBox(height: 16),
//             Center(
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   SizedBox(
//                     height: 120,
//                     width: 120,
//                     child: CircularProgressIndicator(
//                       value: 1 / 8,
//                       strokeWidth: 10,
//                       backgroundColor: Colors.grey[300],
//                       valueColor:
//                           const AlwaysStoppedAnimation<Color>(Colors.blue),
//                     ),
//                   ),
//                   const Text("8\nWork items", textAlign: TextAlign.center),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: const [
//                 _LegendDot(color: Colors.grey, label: "To Do", count: 7),
//                 _LegendDot(color: Colors.blue, label: "In Progress", count: 1),
//                 _LegendDot(color: Colors.green, label: "Done", count: 0),
//               ],
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPriorityBreakdown() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Priority breakdown",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const Text("in the last 14 days",
//                 style: TextStyle(color: Colors.grey)),
//             const SizedBox(height: 16),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: const [
//                 _PriorityBar(height: 100, color: Colors.red),
//                 _PriorityBar(height: 60, color: Colors.orange),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LegendDot extends StatelessWidget {
//   final Color color;
//   final String label;
//   final int count;
//
//   const _LegendDot(
//       {required this.color, required this.label, required this.count});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(radius: 5, backgroundColor: color),
//         const SizedBox(width: 6),
//         Text("$label  $count"),
//       ],
//     );
//   }
// }
//
// class _PriorityBar extends StatelessWidget {
//   final double height;
//   final Color color;
//
//   const _PriorityBar({required this.height, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 20,
//       height: height,
//       color: color,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../api/controllers/projectController.dart';
import '../../../api/controllers/spinController.dart';
import '../../../api/controllers/userStoryController.dart';
import '../../widgets/project_tab_bar.dart';

class SummaryPage extends StatefulWidget {
  final String projectId;
  const SummaryPage({required this.projectId, super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  void _showSprintSelector(BuildContext context, SprintController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final sprints = controller.sprints;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sprints.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, index) {
            final sprint = sprints[index];
            return ListTile(
              title: Text(sprint.name),
              subtitle: Text(
                "${sprint.startDate.substring(0, 10)} → ${sprint.endDate.substring(0, 10)}",
              ),
              onTap: () {
                controller.selectSprint(sprint);
                context
                    .read<UserStoryController>()
                    .loadStories(widget.projectId, sprint.sprintId);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     final sprintCtrl = context.read<SprintController>();
  //     final storyCtrl = context.read<UserStoryController>();
  //     storyCtrl.loadStories(
  //         widget.projectId, sprintCtrl.selectedSprint?.sprintId);
  //   });
  // }
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final sprintCtrl = context.read<SprintController>();
      final storyCtrl = context.read<UserStoryController>();

      await sprintCtrl.loadAllSprints(widget.projectId);

      // Nếu chưa có selectedSprint, gán sprint đầu tiên làm mặc định
      if (sprintCtrl.selectedSprint == null && sprintCtrl.sprints.isNotEmpty) {
        sprintCtrl.selectSprint(sprintCtrl.sprints.first);
      }

      // Sau đó gọi loadStories theo selectedSprint mới
      storyCtrl.loadStories(
          widget.projectId, sprintCtrl.selectedSprint?.sprintId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectCtrl = context.watch<ProjectController>();
    final sprintCtrl = context.watch<SprintController>();
    final storyCtrl = context.watch<UserStoryController>();
    final project = projectCtrl.projects.firstWhere(
      (p) => p.projectId == widget.projectId,
      orElse: () => projectCtrl.selectedProject!,
    );
    final sprint = sprintCtrl.selectedSprint;
    final stories = storyCtrl.stories;

    final todo = stories.where((s) => s.statusId == 1).length;
    final inProgress = stories.where((s) => s.statusId == 2).length;
    final done = stories.where((s) => s.statusId == 3).length;

    final p1 = stories.where((s) => s.priorityId == 1).length;
    final p2 = stories.where((s) => s.priorityId == 2).length;
    final p3 = stories.where((s) => s.priorityId == 3).length;
    final p4 = stories.where((s) => s.priorityId == 4).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 16, // Tăng từ 14 → 16
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: () => _showSprintSelector(context, sprintCtrl),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sprint?.name ?? 'Select Sprint',
                    style: const TextStyle(
                      fontSize: 18, // Tăng từ 16 → 18
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
        bottom: ProjectTabBar(selectedIndex: 0, projectId: widget.projectId),
        scrolledUnderElevation: 0,
      ),
      body: storyCtrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildTopStats(),
                const SizedBox(height: 16),
                _buildStatusOverview(todo, inProgress, done),
                const SizedBox(height: 16),
                _buildPriorityBreakdown(p1, p2, p3, p4),
              ],
            ),
    );
  }

  Widget _buildTopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("0 created", "in the last 7 days", Icons.add),
        _statCard("0 due", "in the next 7 days", Icons.calendar_today),
      ],
    );
  }

  Widget _statCard(String title, String subtitle, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 24, color: Colors.grey),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverview(int todo, int inProgress, int done) {
    final total = todo + inProgress + done;
    final percent = total == 0 ? 0.0 : (inProgress / total);

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Status overview",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("in the last 14 days",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text("$total\nWork items",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendDot(color: Colors.grey, label: "To Do", count: todo),
                _LegendDot(
                    color: Colors.blue,
                    label: "In Progress",
                    count: inProgress),
                _LegendDot(color: Colors.green, label: "Done", count: done),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBreakdown(int p1, int p2, int p3, int p4) {
    final maxHeight = 100.0;
    final maxValue =
        [p1, p2, p3, p4].reduce((a, b) => a > b ? a : b).toDouble();
    double getHeight(int v) => maxValue == 0 ? 0 : (v / maxValue) * maxHeight;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Priority breakdown",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("in the last 14 days",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // 🟦 Biểu đồ cột (bar chart)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tooltip(
                  message: "High ($p3)",
                  child:
                      _PriorityBar(height: getHeight(p3), color: Colors.orange),
                ),
                Tooltip(
                  message: "Highest ($p4)",
                  child: _PriorityBar(height: getHeight(p4), color: Colors.red),
                ),
                Tooltip(
                  message: "Low ($p1)",
                  child:
                      _PriorityBar(height: getHeight(p1), color: Colors.green),
                ),
                Tooltip(
                  message: "Medium ($p2)",
                  child:
                      _PriorityBar(height: getHeight(p2), color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🟨 Icon biểu tượng cho từng priority
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.arrow_drop_up, color: Colors.orange), // High
                Icon(Icons.keyboard_double_arrow_up,
                    color: Colors.red), // Highest
                Icon(Icons.arrow_drop_down, color: Colors.green), // Low
                Icon(Icons.lens, size: 12, color: Colors.blue), // Medium
              ],
            ),

            // 🟩 Text nhãn dưới biểu đồ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text("High", style: TextStyle(fontSize: 12)),
                Text("Highest", style: TextStyle(fontSize: 12)),
                Text("Low", style: TextStyle(fontSize: 12)),
                Text("Medium", style: TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendDot(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Text("$label  $count"),
      ],
    );
  }
}

class _PriorityBar extends StatelessWidget {
  final double height;
  final Color color;

  const _PriorityBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: height,
      color: color,
    );
  }
}
