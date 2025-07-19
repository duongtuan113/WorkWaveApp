import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ FIXED
import 'package:provider/provider.dart';

import '../../../api/controllers/auth_controller.dart';
import '../../../api/controllers/bugController.dart';
import '../../../api/controllers/projectController.dart';
import '../../../api/controllers/spinController.dart';
import '../../../api/models/bug/bug.dart';
import '../../widgets/project_tab_bar.dart';

typedef BugBarsLayout = ({List<Widget> bars, int laneCount});

class BugTimelinePage extends StatefulWidget {
  final String projectId;
  const BugTimelinePage({super.key, required this.projectId});

  @override
  State<BugTimelinePage> createState() => _BugTimelinePageState();
}

class _BugTimelinePageState extends State<BugTimelinePage> {
  static const double pixelsPerTwoMonths = 250.0;
  final double barHeight = 60.0;
  final double barVerticalPadding = 30.0;
  final double timelineWidth = 6 * pixelsPerTwoMonths;

  final DateTime minDate = DateTime(DateTime.now().year, 1, 1);
  final DateTime maxDate = DateTime(DateTime.now().year, 12, 31);

  late ScrollController _scrollController;

  // @override
  // void initState() {
  //   super.initState();
  //   _scrollController = ScrollController();
  //   Future.microtask(() async {
  //     await context.read<BugController>().loadBug(widget.projectId);
  //     await context.read<SprintController>().loadAllSprints(widget.projectId);
  //
  //     _scrollToToday();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    Future.microtask(() async {
      final authCtrl = context.read<AuthController>();
      final token = authCtrl.accessToken; // ✅ Sửa tại đây

      if (token != null) {
        await context
            .read<BugController>()
            .loadBug(widget.projectId, token); // ✅ Truyền token
      } else {
        print("❌ Token không tồn tại, cần login lại");
        context.go('/login'); // hoặc xử lý lỗi khác
      }

      await context.read<SprintController>().loadAllSprints(widget.projectId);
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    final totalDays = DateTime(minDate.year + 1).difference(minDate).inDays;
    final daysElapsed = DateTime.now().difference(minDate).inDays;
    final left = (daysElapsed / totalDays) * timelineWidth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          max(0, left - 150),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        style: const TextStyle(fontSize: 12),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final bugCtrl = context.watch<BugController>();
    final projectController = context.watch<ProjectController>(); // ✅ FIXED
    final sprintController = context.watch<SprintController>(); // ✅ FIXED
    final bugs = bugCtrl.bug;

    final project = projectController.projects.firstWhere(
      (p) => p.projectId == widget.projectId,
      orElse: () =>
          projectController.selectedProject ?? projectController.projects.first,
    );

    final bugLayout = _buildBugBars(bugs);
    final bugBarWidgets = bugLayout.bars;
    final double stackHeight =
        bugLayout.laneCount * (barHeight + barVerticalPadding) + 60.0;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/');
        }
        return false;
      },
      child: Scaffold(
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
                    const Icon(Icons.expand_more,
                        size: 22, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
          actions: const [Icon(Icons.more_vert)],
          bottom: ProjectTabBar(selectedIndex: 3, projectId: widget.projectId),
          scrolledUnderElevation: 0,
        ),
        body: bugCtrl.isLoading
            ? const Center(child: CircularProgressIndicator())
            : bugs.isEmpty
                ? const Center(child: Text("Không tìm thấy bug nào."))
                : SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: timelineWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthHeader(),
                          const Divider(height: 1, thickness: 1),
                          SizedBox(
                            height: stackHeight,
                            child: Stack(
                              children: [
                                _buildFullHeightMonthLines(stackHeight),
                                _buildTodayLine(stackHeight),
                                ...bugBarWidgets,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: List.generate(6, (index) {
        final firstMonth = index * 2 + 1;
        final secondMonth = index * 2 + 2;
        return Container(
          width: pixelsPerTwoMonths,
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Center(
            child: Text(
              'Tháng $firstMonth - $secondMonth',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFullHeightMonthLines(double height) {
    final double pixelsPerMonth = pixelsPerTwoMonths / 2;
    return Positioned.fill(
      child: Row(
        children: List.generate(12, (index) {
          return Container(
            width: pixelsPerMonth,
            height: height,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTodayLine(double height) {
    final today = DateTime.now();
    final totalDays = DateTime(minDate.year + 1).difference(minDate).inDays;
    final daysElapsed = today.difference(minDate).inDays;
    final left = (daysElapsed / totalDays) * timelineWidth;

    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 2,
        height: height,
        color: Colors.amber,
      ),
    );
  }

  BugBarsLayout _buildBugBars(List<Bug> bugs) {
    final List<Widget> barWidgets = [];
    final List<List<DateTimeRange>> occupiedLanes = [];
    final totalDaysInYear =
        DateTime(minDate.year + 1, 1, 1).difference(minDate).inDays;

    final validBugs = bugs
        .where((b) =>
            DateTime.tryParse(b.createdAt) != null &&
            DateTime.tryParse(b.updatedAt) != null)
        .toList();

    validBugs.sort((a, b) =>
        DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));

    int maxLane = 0;

    for (final bug in validBugs) {
      final created = DateTime.parse(bug.createdAt);
      final updated = DateTime.parse(bug.updatedAt);
      if (created.year != minDate.year && updated.year != minDate.year) {
        continue;
      }

      final bugEndDate = updated.isBefore(created) ? created : updated;
      final bugRange = DateTimeRange(start: created, end: bugEndDate);

      int laneIndex = 0;
      while (true) {
        if (laneIndex >= occupiedLanes.length) occupiedLanes.add([]);
        bool overlaps = occupiedLanes[laneIndex].any((range) =>
            bugRange.start.isBefore(range.end) &&
            bugRange.end.isAfter(range.start));
        if (!overlaps) {
          occupiedLanes[laneIndex].add(bugRange);
          break;
        }
        laneIndex++;
      }

      if (laneIndex > maxLane) maxLane = laneIndex;

      final startDayOfYear = created.difference(minDate).inDays;
      final durationDays = max(1, updated.difference(created).inDays + 1);

      final left = (startDayOfYear / totalDaysInYear) * timelineWidth;
      final width = (durationDays / totalDaysInYear) * timelineWidth;
      final top = (laneIndex * (barHeight + barVerticalPadding)) + 20.0;

      barWidgets.add(
        Positioned(
          left: left,
          top: top,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/bug/${bug.bugId}?projectId=${widget.projectId}');
                },
                child: _BugTimelineBar(
                  bug: bug,
                  width: width,
                  height: barHeight,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bug.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black),
                  ),
                  Text(
                    '${bug.createdAt.split("T")[0]} → ${bug.updatedAt.split("T")[0]}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return (bars: barWidgets, laneCount: maxLane + 1);
  }
}

class _BugTimelineBar extends StatelessWidget {
  const _BugTimelineBar({
    required this.bug,
    required this.width,
    required this.height,
  });

  final Bug bug;
  final double width;
  final double height;

  Color _getPriorityColor(int? priorityId) {
    switch (priorityId) {
      case 1:
        return Colors.green.shade400;
      case 2:
        return Colors.blue.shade400;
      case 3:
        return Colors.orange.shade400;
      case 4:
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(bug.priorityId),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(1, 1),
          )
        ],
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        bug.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
