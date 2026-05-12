import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/project_controller.dart';
import '../models/project_model.dart';

// ─────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────


bool get _isProjectManager {
  final box = GetStorage();
  final raw = (box.read('Designation') ?? box.read('designation') ?? '').toString();
  return raw == 'Project Manager';
}

// ─────────────────────────────────────────────────────────────────────────
// SHARED BADGE WIDGET
// ─────────────────────────────────────────────────────────────────────────

class TaskBadge extends StatelessWidget {
  final String label;
  final Color color;
  const TaskBadge(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TASK SCREEN
// ─────────────────────────────────────────────────────────────────────────

class TaskScreen extends StatelessWidget {
  final c = Get.find<TaskController>();

  TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F1ED),
        elevation: 0,
        title: Text('Tasks',
            style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917))),
        actions: [
          
          Obx(() => IconButton(
                icon: Icon(
                  c.isSearchExpanded.value
                      ? Icons.search_off_rounded
                      : Icons.search_rounded,
                  color: const Color(0xFF6A3027),
                ),
                onPressed: c.toggleSearch,
              )),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6A3027)),
            onPressed: c.fetchAll,
          ),
        ],
      ),
      
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A3027)));
        }
        return _TaskScreenBody(c: c);
      }),
      floatingActionButton: Obx(() {
        final isGiven = c.activeTab.value == 0;
        if (!isGiven) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => _showTaskForm(context),
          backgroundColor: const Color(0xFFB54A3A),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        );
      }),
    );
  }

  void _showTaskForm(BuildContext context, {TaskModel? existing}) {
    Get.bottomSheet(
      _TaskForm(c: c, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TASK SCREEN BODY  (extracted to avoid nested Obx)
// ─────────────────────────────────────────────────────────────────────────

class _TaskScreenBody extends StatelessWidget {
  final TaskController c;
  const _TaskScreenBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isManager = _isProjectManager;
      final activeTab = c.activeTab.value;

      return Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          child: Column(children: [
            _TabToggle(c: c),
            SizedBox(height: 12.h),
            if (c.isSearchExpanded.value) ...[
              _SearchBar(
                onChanged: _getSearchCallback(isManager, activeTab),
                hintText: _getSearchHint(isManager, activeTab),
              ),
              SizedBox(height: 12.h),
            ],
            
            if (isManager && activeTab == 1)
              const _ProjectStatsCard()
            else
              _StatsCard(c: c),
            SizedBox(height: 12.h),
          ]),
        ),
        Expanded(
          child: _buildList(isManager, activeTab),
        ),
      ]);
    });
  }

  Function(String) _getSearchCallback(bool isManager, int activeTab) {
    if (isManager && activeTab == 1) {
      // Projects tab - use ProjectController
      if (!Get.isRegistered<ProjectController>()) {
        Get.put(ProjectController());
      }
      final pc = Get.find<ProjectController>();
      return pc.setSearch;
    } else {
      // Tasks tab - use TaskController
      return c.setSearch;
    }
  }

  String _getSearchHint(bool isManager, int activeTab) {
    if (isManager && activeTab == 1) {
      return 'Search by project name or client…';
    } else {
      return 'Search by title or date…';
    }
  }

  Widget _buildList(bool isManager, int activeTab) {
    if (isManager && activeTab == 1) {
      if (!Get.isRegistered<ProjectController>()) {
        Get.put(ProjectController());
      }
      final pc = Get.find<ProjectController>();
      return Obx(() {
        if (pc.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6A3027)),
          );
        }
        final projects = pc.filteredProjects;
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined,
                    size: 58.sp, color: const Color(0xFF8B7D77)),
                SizedBox(height: 12.h),
                Text('No projects found',
                    style: GoogleFonts.manrope(
                        fontSize: 15.sp, color: const Color(0xFF8B7D77))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: projects.length,
          itemBuilder: (_, i) => _ProjectMiniCard(project: projects[i]),
        );
      });
    }

    // Task list
    final tasks = c.filteredTasks;
    if (tasks.isEmpty) return _EmptyState();
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskCard(task: tasks[i], c: c),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TAB TOGGLE
// ─────────────────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final TaskController c;
  const _TabToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    final isManager = _isProjectManager;
    
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8DDD9),
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(children: [
            _tab('Given', 0),
            _tab(isManager ? 'Projects' : 'Received', 1),
          ]),
        ));
  }

  Widget _tab(String label, int index) {
    final active = c.activeTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFB54A3A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF8B7D77))),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  const _SearchBar({required this.onChanged, this.hintText = 'Search by title or date…'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style:
          GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF241917)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF8B7D77)),
        prefixIcon:
            const Icon(Icons.search_rounded, color: Color(0xFF6A3027)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide:
                const BorderSide(color: Color(0xFFB54A3A), width: 1.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STATS CARD  (tasks tab)
// ─────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final TaskController c;
  const _StatsCard({required this.c});

  @override
  Widget build(BuildContext context) {
    
    return Obx(() {
      final current = c.selectedFilter.value;
      final isGiven = c.activeTab.value == 0;
      
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 7))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tile(
              label: 'Total',
              value: '${c.totalCount}',
              icon: Icons.view_agenda_rounded,
              color: const Color(0xFF6A3027),
              filter: 'All',
              current: current,
            ),
            _divider(),
            _tile(
              label: isGiven ? 'Active' : 'Pending',
              value: isGiven ? '${c.activeCount}' : '${c.pendingCount}',
              icon: isGiven ? Icons.play_circle_outline_rounded : Icons.schedule_rounded,
              color: Colors.orange,
              filter: isGiven ? 'Active' : 'Pending',
              current: current,
            ),
            _divider(),
            _tile(
              label: 'Approved',
              value: '${c.approvedCount}',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              filter: 'Approved',
              current: current,
            ),
            _divider(),
            _tile(
              label: 'Overdue',
              value: '${c.overdueCount}',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              filter: 'Overdue',
              current: current,
            ),
          ],
        ),
      );
    });
  }

  Widget _divider() =>
      Container(height: 38.h, width: 1, color: const Color(0xFFE8DDD9));

  Widget _tile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String filter,
    required String current,
  }) {
    final isActive = current == filter;
    return GestureDetector(
      onTap: () => c.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isActive
              ? Border.all(color: color.withOpacity(0.40), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Column(children: [
          Icon(icon,
              size: 24.sp,
              color: isActive ? color : color.withOpacity(0.40)),
          SizedBox(height: 5.h),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: isActive ? color : const Color(0xFF241917))),
          SizedBox(height: 2.h),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? color : const Color(0xFF8B7D77))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PROJECT STATS CARD  (shown only on Projects tab for managers)
// ─────────────────────────────────────────────────────────────────────────

class _ProjectStatsCard extends StatelessWidget {
  const _ProjectStatsCard();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProjectController>()) {
      Get.put(ProjectController());
    }
    final pc = Get.find<ProjectController>();

    
    return Obx(() {
      final projects = pc.allProjects;
      final total = projects.length;
      final running =
          projects.where((p) => p.projectStatus == 'Running').length;
      final complete =
          projects.where((p) => p.projectStatus == 'Complete').length;
      final onHold =
          projects.where((p) => p.projectStatus == 'On Hold').length;

      final current = pc.selectedFilter.value;

      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 7))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pTile('Total', '$total', Icons.folder_outlined,
                const Color(0xFF6A3027), 'All', current),
            _divider(),
            _pTile('Running', '$running', Icons.play_circle_outline_rounded,
                Colors.green, 'Running', current),
            _divider(),
            _pTile('Complete', '$complete',
                Icons.check_circle_outline_rounded, Colors.blue, 'Complete', current),
            _divider(),
            _pTile('On Hold', '$onHold',
                Icons.pause_circle_outline_rounded, Colors.orange, 'On Hold', current),
          ],
        ),
      );
    });
  }

  Widget _divider() =>
      Container(height: 38.h, width: 1, color: const Color(0xFFE8DDD9));

  Widget _pTile(String label, String value, IconData icon, Color color, String filter, String current) {
    final isActive = current == filter;
    return GestureDetector(
      onTap: () {
        final pc = Get.find<ProjectController>();
        pc.setFilter(filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isActive
              ? Border.all(color: color.withOpacity(0.40), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Column(children: [
          Icon(icon,
              size: 24.sp,
              color: isActive ? color : color.withOpacity(0.40)),
          SizedBox(height: 5.h),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: isActive ? color : const Color(0xFF241917))),
          SizedBox(height: 2.h),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? color : const Color(0xFF8B7D77))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TASK CARD (expandable)
// ─────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatefulWidget {
  final TaskModel task;
  final TaskController c;
  const _TaskCard({required this.task, required this.c});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _anim;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _anim.forward() : _anim.reverse();
  }

  Color get _priorityColor {
    switch (widget.task.priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Color get _statusColor {
    switch (widget.task.overallStatus) {
      case 'Approved':
        return Colors.green;
      case 'LeadRejected':
      case 'AssignerRejected':
        return Colors.red;
      case 'AwaitingLeadApproval':
      case 'AwaitingAssignerApproval':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (widget.task.overallStatus) {
      case 'AwaitingLeadApproval':
        return 'Awaiting Lead';
      case 'AwaitingAssignerApproval':
        return 'Awaiting Approval';
      case 'LeadRejected':
        return 'Lead Rejected';
      case 'AssignerRejected':
        return 'Rejected';
      default:
        return widget.task.overallStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: t.isOverdue
            ? Border.all(color: Colors.red.shade200, width: 1.2)
            : null,
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(children: [
        // ── Collapsed header ─────────────────────────────────────────────
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18.r),
            bottom: Radius.circular(_expanded ? 0 : 18.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            child: Row(children: [
              Container(
                width: 4.w,
                height: 44.h,
                decoration: BoxDecoration(
                    color: _priorityColor,
                    borderRadius: BorderRadius.circular(4.r)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (t.projectName != null && t.projectName!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: TaskBadge(
                                t.projectName!, const Color(0xFF6A3027)),
                          ),
                        Expanded(
                          child: Text(t.title,
                              style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF241917))),
                        ),
                        if (t.isOverdue) TaskBadge('Overdue', Colors.red),
                      ]),
                      SizedBox(height: 6.h),
                      Wrap(spacing: 6.w, runSpacing: 4.h, children: [
                        TaskBadge(t.priority, _priorityColor),
                        TaskBadge(_statusLabel, _statusColor),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 11.sp,
                              color: const Color(0xFF8B7D77)),
                          SizedBox(width: 3.w),
                          Text(t.dueDate,
                              style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF8B7D77))),
                        ]),
                      ]),
                    ]),
              ),
              RotationTransition(
                turns: _rotate,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22.sp, color: const Color(0xFF6A3027)),
              ),
            ]),
          ),
        ),

        // ── Expanded body ────────────────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _ExpandedBody(task: t, c: widget.c),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXPANDED BODY
// ─────────────────────────────────────────────────────────────────────────

class _ExpandedBody extends StatelessWidget {
  final TaskModel task;
  final TaskController c;
  const _ExpandedBody({required this.task, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Divider(
          color: const Color(0xFFF0E8E4),
          height: 1,
          indent: 14.w,
          endIndent: 14.w),
      Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoRow(
              Icons.description_outlined, 'Description', task.description),
          SizedBox(height: 8.h),
          if (task.assignedByName.isNotEmpty)
            _infoRow(Icons.person_outline_rounded, 'Assigned by',
                task.assignedByName),
          SizedBox(height: 4.h),
          _infoRow(
              Icons.star_border_rounded, 'Team Lead', task.teamLeadName),
          if (task.juniorName != null) ...[
            SizedBox(height: 4.h),
            _infoRow(Icons.person_pin_circle_outlined, 'Junior',
                task.juniorName!),
          ],
          if (task.projectName != null && task.projectName!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            _infoRow(Icons.folder_outlined, 'Project', task.projectName!),
          ],
          SizedBox(height: 4.h),
          _infoRow(Icons.repeat_rounded, 'Recurrence', task.recurrence),
          SizedBox(height: 12.h),
          _StatusTimeline(task: task),
          if (task.leadRemark != null) ...[
            SizedBox(height: 10.h),
            _RemarkBox(
                label: 'Lead Rejection Remark', remark: task.leadRemark!),
          ],
          if (task.assignerRemark != null) ...[
            SizedBox(height: 10.h),
            _RemarkBox(
                label: 'Assigner Rejection Remark',
                remark: task.assignerRemark!),
          ],
          SizedBox(height: 14.h),
          _ActionButtons(task: task, c: c),
        ]),
      ),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14.sp, color: const Color(0xFF6A3027)),
      SizedBox(width: 8.w),
      Expanded(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '$label: ',
                style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B7D77))),
            TextSpan(
                text: value,
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: const Color(0xFF241917))),
          ]),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STATUS TIMELINE
// ─────────────────────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  final TaskModel task;
  const _StatusTimeline({required this.task});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _stepData('Junior', task.overallStatus),
      _stepData('Lead', task.overallStatus),
      _stepData('Assigner', task.overallStatus),
    ];

    return Row(
        children: List.generate(steps.length * 2 - 1, (i) {
      if (i.isOdd) {
        return Expanded(
            child: Container(height: 2.h, color: const Color(0xFFE0D5D0)));
      }
      final s = steps[i ~/ 2];
      return Column(children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s['color'] as Color,
              border: Border.all(color: Colors.white, width: 2)),
          child: Icon(s['icon'] as IconData, size: 14.sp, color: Colors.white),
        ),
        SizedBox(height: 4.h),
        Text(s['label'] as String,
            style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B7D77))),
      ]);
    }));
  }

  Map<String, dynamic> _stepData(String role, String status) {
    Color color;
    IconData icon;

    if (role == 'Junior') {
      if (status == 'Pending') {
        color = Colors.grey.shade300;
        icon = Icons.circle_outlined;
      } else {
        color = Colors.green;
        icon = Icons.check_rounded;
      }
    } else if (role == 'Lead') {
      if (status == 'Pending') {
        color = Colors.grey.shade300;
        icon = Icons.circle_outlined;
      } else if (status == 'AwaitingLeadApproval') {
        color = Colors.orange;
        icon = Icons.hourglass_top_rounded;
      } else if (status == 'LeadRejected') {
        color = Colors.red;
        icon = Icons.close_rounded;
      } else {
        color = Colors.green;
        icon = Icons.check_rounded;
      }
    } else {
      if (['Pending', 'AwaitingLeadApproval', 'LeadRejected']
          .contains(status)) {
        color = Colors.grey.shade300;
        icon = Icons.circle_outlined;
      } else if (status == 'AwaitingAssignerApproval') {
        color = Colors.orange;
        icon = Icons.hourglass_top_rounded;
      } else if (status == 'AssignerRejected') {
        color = Colors.red;
        icon = Icons.close_rounded;
      } else {
        color = Colors.green;
        icon = Icons.check_rounded;
      }
    }

    return {'label': role, 'color': color, 'icon': icon};
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REMARK BOX
// ─────────────────────────────────────────────────────────────────────────

class _RemarkBox extends StatelessWidget {
  final String label;
  final RemarkModel remark;
  const _RemarkBox({required this.label, required this.remark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(left: BorderSide(color: Colors.red, width: 3.w)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade700)),
        SizedBox(height: 4.h),
        Text(remark.remark,
            style: GoogleFonts.inter(
                fontSize: 12.sp, color: const Color(0xFF241917))),
        SizedBox(height: 4.h),
        Text(
            '— ${remark.rejectedBy}  •  ${remark.rejectedAt.substring(0, 10)}',
            style: GoogleFonts.inter(
                fontSize: 10.sp, color: const Color(0xFF8B7D77))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final TaskModel task;
  final TaskController c;
  const _ActionButtons({required this.task, required this.c});

  bool get _isGivenTab => c.activeTab.value == 0;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (_isGivenTab) {
      // ── GIVEN TAB ACTIONS ──────────────────────────────────────────
      
      if (task.juniorId == c.myId && 
          (task.overallStatus == 'Pending' || task.overallStatus == 'Active')) {
        buttons.add(_btn('Mark Done', Icons.check_rounded, Colors.green,
            () => c.markDone(task.id)));
      }

      // Team lead approval
      if (c.canLeadApprove(task)) {
        buttons.add(_btn('Approve', Icons.thumb_up_outlined, Colors.green,
            () => c.leadApprove(task.id)));
        buttons.add(_btn('Reject', Icons.thumb_down_outlined, Colors.red,
            () => _showRejectSheet(context, isLead: true)));
      }

      // Assigner approval
      if (c.canAssignerApprove(task)) {
        buttons.add(_btn('Approve', Icons.verified_outlined, Colors.green,
            () => c.assignerApprove(task.id)));
        buttons.add(_btn('Reject', Icons.cancel_outlined, Colors.red,
            () => _showRejectSheet(context, isLead: false)));
      }

      // Edit and delete (only for task creator)
      if (task.assignedById == c.myId) {
        buttons.add(_btn(
            'Edit', Icons.edit_outlined, const Color(0xFF6A3027), () {
          Get.bottomSheet(
            _TaskForm(c: c, existing: task),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        }));
        buttons.add(_btn('Delete', Icons.delete_outline_rounded, Colors.red,
            () => _confirmDelete(context)));
      }
    } else {
      // ── RECEIVED TAB ACTIONS ───────────────────────────────────────
      // Employee can mark done if task is assigned to them
      if (task.juniorId == c.myId && task.overallStatus == 'Pending') {
        buttons.add(_btn('Mark Done', Icons.check_rounded, Colors.green,
            () => c.markDone(task.id)));
      }

      // Show approval/rejection status from lead or assigner
      if (task.leadRemark != null) {
        buttons.add(_btn('Lead Rejected', Icons.close_rounded, Colors.red,
            () => _showRemarkDetails(context, task.leadRemark!, 'Lead')));
      }

      if (task.assignerRemark != null) {
        buttons.add(_btn('Assigner Rejected', Icons.cancel_outlined, Colors.red,
            () => _showRemarkDetails(context, task.assignerRemark!, 'Assigner')));
      }

      if (task.overallStatus == 'Approved') {
        buttons.add(_btn('Approved ✓', Icons.verified_rounded, Colors.green,
            () {}));
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8.w, runSpacing: 8.h, children: buttons);
  }

  Widget _btn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 5.w),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Delete Task',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917))),
        content: Text('Are you sure?',
            style: GoogleFonts.inter(color: const Color(0xFF8B7D77))),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel',
                  style:
                      GoogleFonts.inter(color: const Color(0xFF8B7D77)))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              c.deleteTask(task.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r))),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showRemarkDetails(BuildContext context, RemarkModel remark, String from) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('$from Rejection',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.red.shade700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(remark.remark,
                style: GoogleFonts.inter(
                    fontSize: 13.sp, color: const Color(0xFF241917))),
            SizedBox(height: 12.h),
            Text(
                '— ${remark.rejectedBy} • ${remark.rejectedAt.substring(0, 10)}',
                style: GoogleFonts.inter(
                    fontSize: 11.sp, color: const Color(0xFF8B7D77))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('Close',
                  style: GoogleFonts.inter(color: const Color(0xFF6A3027)))),
        ],
      ),
    );
  }

  void _showRejectSheet(BuildContext context, {required bool isLead}) {
    final ctrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1ED),
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rejection Remark',
                  style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF241917))),
              SizedBox(height: 12.h),
              TextField(
                controller: ctrl,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Explain why you are rejecting this task…',
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF8B7D77)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0D5D0))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0D5D0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                          color: Color(0xFFB54A3A), width: 1.5)),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final remark = ctrl.text.trim();
                    if (remark.isEmpty) {
                      Get.snackbar(
                          'Required', 'Please enter a remark',
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    Get.back();
                    isLead
                        ? c.leadReject(task.id, remark)
                        : c.assignerReject(task.id, remark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text('Submit Rejection',
                      style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ]),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TASK FORM BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────

class _TaskForm extends StatefulWidget {
  final TaskController c;
  final TaskModel? existing;
  final String? preselectedProjectId;
  final String? preselectedProjectName;
  const _TaskForm({required this.c, this.existing,
    this.preselectedProjectId, this.preselectedProjectName});

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _startDate;
  late final TextEditingController _date;

  List<String> _selectedEmployeeIds = [];
  String? _selectedJuniorId;
  String _priority = 'Medium';
  String _recurrence = 'None';
  DateTime _startDateTime = DateTime.now();
  DateTime? _dueDate;

  String? _selectedProjectId;
String? _selectedProjectName;
String? _preselectedProjectId; 

  bool get _isManager => _isProjectManager;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _date = TextEditingController(text: e?.dueDate ?? '');
    _priority = e?.priority ?? 'Medium';
    _recurrence = e?.recurrence ?? 'None';
    _selectedEmployeeIds = e?.teamLeadId != null ? [e!.teamLeadId!] : [];
    _selectedJuniorId = e?.juniorId;
    _selectedProjectId = widget.preselectedProjectId ?? e?.projectId;
_selectedProjectName = widget.preselectedProjectName ?? e?.projectName;
_preselectedProjectId = widget.preselectedProjectId;

    _startDateTime = e?.startDate != null
        ? DateTime.tryParse(e!.startDate!) ?? DateTime.now()
        : DateTime.now();
    _startDate = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(_startDateTime));
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _startDate.dispose();
    _date.dispose();
    super.dispose();
  }

  // List<EmployeeModel> get _juniors =>
  //     _selectedLeadId != null ? widget.c.juniorsOf(_selectedLeadId!) : [];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1ED),
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(children: [
          SizedBox(height: 12.h),
          Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: const Color(0xFFCBC0BA),
                  borderRadius: BorderRadius.circular(2.r))),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isEdit ? 'Edit Task' : 'Assign New Task',
                      style: GoogleFonts.manrope(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF241917))),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                          color: Color(0xFFE8DDD9),
                          shape: BoxShape.circle),
                      child: Icon(Icons.close,
                          size: 18.sp, color: const Color(0xFF6A3027)),
                    ),
                  ),
                ]),
          ),
          SizedBox(height: 10.h),
          const Divider(color: Color(0xFFE0D5D0), height: 1),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
              children: [
                if (_isManager) ...[
                  _label('Link to Project'),
                  SizedBox(height: 6.h),
                  _buildProjectDropdown(),
                  SizedBox(height: 14.h),
                ],

                _label('Select Employees'),
SizedBox(height: 6.h),
Obx(() {
  final employees = widget.c.employees;
  return GestureDetector(
    onTap: () async {
      if (employees.isEmpty) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setModal) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F1ED),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBC0BA),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text('Select Employees',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp, fontWeight: FontWeight.w800,
                    color: const Color(0xFF241917))),
              ),
              SizedBox(height: 10.h),
              const Divider(color: Color(0xFFE0D5D0), height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                  itemCount: employees.length,
                  itemBuilder: (_, i) {
                    final emp = employees[i];
                    final id = emp.employeeId.toString();
                    final selected = _selectedEmployeeIds.contains(id);
                    return ListTile(
                      onTap: () {
                        setModal(() {
                          setState(() {
                            if (selected) {
                              _selectedEmployeeIds.remove(id);
                            } else {
                              _selectedEmployeeIds.add(id);
                            }
                          });
                        });
                      },
                      leading: Container(
                        width: 24.w, height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? const Color(0xFFB54A3A)
                              : const Color(0xFFE8DDD9),
                        ),
                        child: selected
                            ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                            : null,
                      ),
                      title: Text('${emp.employeeId} - ${emp.employeeName}',
                        style: GoogleFonts.inter(fontSize: 13.sp,
                          color: const Color(0xFF241917))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB54A3A),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text('Done (${_selectedEmployeeIds.length} selected)',
                      style: GoogleFonts.manrope(fontSize: 14.sp,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0D5D0)),
      ),
      child: Row(children: [
        Icon(Icons.people_outline_rounded, size: 17.sp,
          color: const Color(0xFF6A3027)),
        SizedBox(width: 10.w),
        Expanded(
          child: _selectedEmployeeIds.isEmpty
              ? Text(employees.isEmpty ? 'Loading employees…' : 'Tap to select employees',
                  style: GoogleFonts.inter(fontSize: 13.sp,
                    color: const Color(0xFF8B7D77)))
              : Wrap(
                  spacing: 6.w, runSpacing: 4.h,
                  children: _selectedEmployeeIds.map((id) {
                    final emp = employees.firstWhereOrNull(
                        (e) => e.employeeId.toString() == id);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB54A3A).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFFB54A3A).withOpacity(0.35)),
                      ),
                      child: Text(emp?.employeeName ?? id,
                        style: GoogleFonts.inter(fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB54A3A))),
                    );
                  }).toList(),
                ),
        ),
        Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF6A3027)),
      ]),
    ),
  );
}),

                // if (_selectedLeadId != null) ...[
                //   SizedBox(height: 14.h),
                //   _label('Assign Employee'),
                //   SizedBox(height: 6.h),
                //   Obx(() {
                //     final employees = widget.c.employees;
                //     return _dropdown<String>(
                //       value: _selectedJuniorId,
                //       hint: employees.isEmpty
                //           ? 'Loading employees…'
                //           : 'Select Employee',
                //       items: [
                //         DropdownMenuItem<String>(
                //           value: null,
                //           child: Text('None',
                //               style: GoogleFonts.inter(fontSize: 13.sp)),
                //         ),
                //         ...employees
                //             .where((employee) =>
                //                 employee.employeeId.toString() !=
                //                 _selectedLeadId)
                //             .map((employee) => DropdownMenuItem<String>(
                //                   value: employee.employeeId.toString(),
                //                   child: Text(employee.employeeName,
                //                       style: GoogleFonts.inter(
                //                           fontSize: 13.sp)),
                //                 ))
                //             .toList(),
                //       ],
                //       onChanged: (value) {
                //         setState(() {
                //           _selectedJuniorId = value;
                //         });
                //       },
                //     );
                //   }),
                // ],

                SizedBox(height: 14.h),
                _label('Task Title *'),
                SizedBox(height: 6.h),
                _field(_title, 'e.g. Review Q2 report'),

                SizedBox(height: 14.h),
                _label('Description'),
                SizedBox(height: 6.h),
                _field(_desc, 'Brief details…', maxLines: 3),

                SizedBox(height: 14.h),
                _label('Start Date'),
                SizedBox(height: 6.h),
                _datePickerWidget(
                  controller: _startDate,
                  selectedDate: _startDateTime,
                  hintText: 'Select start date',
                  onPicked: (p) => setState(() {
                    _startDateTime = p;
                    _startDate.text = DateFormat('dd-MM-yyyy').format(p);
                  }),
                ),

                SizedBox(height: 14.h),
                _label('Due Date'),
                SizedBox(height: 6.h),
                _datePickerWidget(
                  controller: _date,
                  selectedDate: _dueDate,
                  hintText: 'Select due date',
                  onPicked: (p) => setState(() {
                    _dueDate = p;
                    _date.text = DateFormat('dd-MM-yyyy').format(p);
                  }),
                ),

                SizedBox(height: 14.h),
                _label('Recurrence'),
                SizedBox(height: 8.h),
                _chips(
                    ['Daily', 'Weekly', 'Alternate', 'Monthly', 'None'],
                    _recurrence,
                    (v) => setState(() => _recurrence = v)),

                SizedBox(height: 14.h),
                _label('Priority'),
                SizedBox(height: 8.h),
                _chips(
                    ['High', 'Medium', 'Low'],
                    _priority,
                    (v) => setState(() => _priority = v),
                    colors: {
                      'High': Colors.red,
                      'Medium': Colors.orange,
                      'Low': Colors.green
                    }),

                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB54A3A),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text(
                        _isEdit ? 'Save Changes' : 'Assign Task',
                        style: GoogleFonts.manrope(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  
  Widget _buildProjectDropdown() {
    if (!Get.isRegistered<ProjectController>()) {
      Get.put(ProjectController());
    }
    final pc = Get.find<ProjectController>();
    
    final projects = pc.allProjects;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0D5D0)),
      ),
      child: DropdownButtonHideUnderline(
  child: DropdownButton<String>(
    value: _selectedProjectId,
    // locked when opened from a project card
    onChanged: _preselectedProjectId != null ? null : (v) => setState(() {
      _selectedProjectId = v;
      _selectedProjectName = v == null
          ? null
          : Get.find<ProjectController>()
              .allProjects
              .firstWhereOrNull((p) => p.projectId.toString() == v)
              ?.projectName;
    }),
    hint: Text('None (standalone task)',
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: const Color(0xFF8B7D77))),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6A3027)),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('None (standalone task)',
                  style: GoogleFonts.inter(fontSize: 13.sp)),
            ),
            ...projects.map((p) => DropdownMenuItem<String>(
                  value: p.projectId.toString(),
                  child: Row(children: [
                    Icon(Icons.folder_outlined,
                        size: 14.sp, color: const Color(0xFF6A3027)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(p.projectName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 13.sp)),
                    ),
                  ]),
                )),
          ],
          // onChanged: (v) => setState(() {
          //   _selectedProjectId = v;
          //   _selectedProjectName = v == null
          //       ? null
          //       : projects
          //           .firstWhereOrNull(
          //               (p) => p.projectId.toString() == v)
          //           ?.projectName;
          // }),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.manrope(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF241917)));

  Widget _field(TextEditingController ctrl, String hint,
          {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: GoogleFonts.inter(
            fontSize: 14.sp, color: const Color(0xFF241917)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              fontSize: 13.sp, color: const Color(0xFF8B7D77)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE0D5D0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE0D5D0))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  const BorderSide(color: Color(0xFFB54A3A), width: 1.5)),
        ),
      );

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0D5D0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint,
                style: GoogleFonts.inter(
                    fontSize: 13.sp, color: const Color(0xFF8B7D77))),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6A3027)),
            items: items,
            onChanged: onChanged,
          ),
        ),
      );

  Widget _datePickerWidget({
    required TextEditingController controller,
    required Function(DateTime) onPicked,
    DateTime? selectedDate,
    String hintText = 'Select date',
  }) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Color(0xFFB54A3A))),
              child: child!,
            ),
          );
          if (p != null) onPicked(p);
        },
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE0D5D0)),
          ),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded,
                size: 17.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 10.w),
            Text(
              controller.text.isEmpty ? hintText : controller.text,
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: controller.text.isEmpty
                      ? const Color(0xFF8B7D77)
                      : const Color(0xFF241917)),
            ),
          ]),
        ),
      );

  Widget _chips(
    List<String> opts,
    String selected,
    ValueChanged<String> onSel, {
    Map<String, Color>? colors,
  }) =>
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: opts.map((o) {
          final sel = selected == o;
          final color = colors?[o] ?? const Color(0xFFB54A3A);
          return GestureDetector(
            onTap: () => onSel(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: sel ? color.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                    color: sel ? color : const Color(0xFFE0D5D0)),
              ),
              child: Text(o,
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: sel ? color : const Color(0xFF241917))),
            ),
          );
        }).toList(),
      );

  void _submit() {
    if (_title.text.trim().isEmpty || _selectedEmployeeIds.isEmpty) {
  Get.snackbar('Missing Info', 'Title and at least one employee are required',
      snackPosition: SnackPosition.BOTTOM);
  return;
}
if (_isEdit) {
  widget.c.updateTask(widget.existing!.id, {
    'title': _title.text.trim(),
    'description': _desc.text.trim(),
    'start_date': _startDate.text,
    'due_date': _date.text,
    'priority': _priority,
    'recurrence': _recurrence,
    'team_lead_ids': _selectedEmployeeIds.join(','),
    'junior_id': _selectedJuniorId,
    'project_id': _selectedProjectId,
    'project_name': _selectedProjectName,
  });
} else {
  widget.c.assignTask(
    teamLeadId: _selectedEmployeeIds,
    juniorId: _selectedJuniorId,
    title: _title.text.trim(),
    description: _desc.text.trim(),
    startDate: _startDate.text,
    dueDate: _date.text,
    priority: _priority,
    recurrence: _recurrence,
    projectId: _selectedProjectId,
    projectName: _selectedProjectName,
  );
}
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.assignment_outlined,
            size: 58.sp, color: const Color(0xFF8B7D77)),
        SizedBox(height: 12.h),
        Text('No tasks found',
            style: GoogleFonts.manrope(
                fontSize: 15.sp, color: const Color(0xFF8B7D77))),
      ]),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────
// PROJECT MINI CARD (EXPANDABLE)
// ─────────────────────────────────────────────────────────────────────────

class _ProjectMiniCard extends StatefulWidget {
  final ProjectModel project;
  const _ProjectMiniCard({required this.project});

  @override
  State<_ProjectMiniCard> createState() => _ProjectMiniCardState();
}

class _ProjectMiniCardState extends State<_ProjectMiniCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _anim;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _anim.forward() : _anim.reverse();
  }

  Color get _statusColor {
    switch (widget.project.projectStatus) {
      case 'Running':
        return Colors.green;
      case 'Complete':
        return Colors.blue;
      case 'On Hold':
        return Colors.orange;
      case 'Pending':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(children: [
        // ── Collapsed header ─────────────────────────────────────────────
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18.r),
            bottom: Radius.circular(_expanded ? 0 : 18.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(children: [
              Container(
                width: 4.w,
                height: 44.h,
                decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(4.r)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.projectName,
                          style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF241917))),
                      SizedBox(height: 4.h),
                      Row(children: [
                        Icon(Icons.person_outline_rounded,
                            size: 12.sp,
                            color: const Color(0xFF8B7D77)),
                        SizedBox(width: 4.w),
                        Text(p.clientName,
                            style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: const Color(0xFF8B7D77))),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(p.projectStatus,
                              style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor)),
                        ),
                      ]),
                    ]),
              ),
              RotationTransition(
                turns: _rotate,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22.sp, color: const Color(0xFF6A3027)),
              ),
            ]),
          ),
        ),

        // ── Expanded body ────────────────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _ExpandedProjectBody(project: p),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXPANDED PROJECT BODY
// ─────────────────────────────────────────────────────────────────────────

class _ExpandedProjectBody extends StatelessWidget {
  final ProjectModel project;
  const _ExpandedProjectBody({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Divider(
          color: const Color(0xFFF0E8E4),
          height: 1,
          indent: 14.w,
          endIndent: 14.w),
      Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoRow(Icons.person_outline_rounded, 'Client', project.clientName),
          SizedBox(height: 8.h),
          _infoRow(Icons.folder_outlined, 'Project', project.projectName),
          SizedBox(height: 8.h),
          if (project.assignedTo.isNotEmpty)
            _infoRow(Icons.assignment_ind_outlined, 'Assigned To',
                project.assignedTo),
          if (project.assignedTo.isNotEmpty) SizedBox(height: 8.h),
          _infoRow(Icons.info_outline_rounded, 'Status', project.projectStatus),
          if (project.description != null && project.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _infoRow(Icons.description_outlined, 'Description',
                project.description!),
          ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.find<TaskController>().switchTab(0);
                // close expansion, open FAB form with project preselected
                Get.bottomSheet(
                  _TaskForm(
                    c: Get.find<TaskController>(),
                    preselectedProjectId: project.projectId.toString(),
                    preselectedProjectName: project.projectName,
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              icon: Icon(Icons.add_task_rounded,
                  size: 16.sp, color: Colors.white),
              label: Text(
                project.projectStatus == 'On Hold'
                    ? 'Reassign Task'
                    : 'Assign Task',
                style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: project.projectStatus == 'On Hold'
                    ? Colors.orange
                    : const Color(0xFFB54A3A),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14.sp, color: const Color(0xFF6A3027)),
      SizedBox(width: 8.w),
      Expanded(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '$label: ',
                style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B7D77))),
            TextSpan(
                text: value,
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: const Color(0xFF241917))),
          ]),
        ),
      ),
    ]);
  }
}