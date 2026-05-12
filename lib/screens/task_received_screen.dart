import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Static preview data (replace with real API call) ──────────────────────
final List<Map<String, dynamic>> _staticReceivedTasks = [
  {
    "id": "1",
    "title": "Prepare Monthly Report",
    "description": "Prepare and submit the monthly financial report by end of day.",
    "due_date": "2026-04-30",
    "status": "Pending",
    "assigned_by": "Rohan Kapoor",
    "priority": "High",
    "recurrence": "Monthly",
  },
  {
    "id": "2",
    "title": "Design New Landing Page",
    "description": "Create Figma mockups for the redesigned homepage with new branding.",
    "due_date": "2026-04-27",
    "status": "Completed",
    "assigned_by": "Neha Singh",
    "priority": "Medium",
    "recurrence": "Weekly",
  },
  {
    "id": "3",
    "title": "Database Backup",
    "description": "Run and verify full production database backup and store securely.",
    "due_date": "2026-04-22",
    "status": "Missed",
    "assigned_by": "Rohan Kapoor",
    "priority": "High",
    "recurrence": "Daily",
  },
  {
    "id": "4",
    "title": "Write Unit Tests",
    "description": "Add test coverage for the auth module — target 80% coverage.",
    "due_date": "2026-05-05",
    "status": "Pending",
    "assigned_by": "Meera Iyer",
    "priority": "Low",
    "recurrence": "Alternate",
  },
];

// ─────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────

class TaskReceivedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        title: Text("Tasks Assigned to You",
            style: GoogleFonts.manrope(
                fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
        backgroundColor: const Color(0xFFF6F1ED),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(children: [
          SizedBox(height: 4.h),
          _StatsCard(),
          SizedBox(height: 20.h),
          Expanded(child: _TaskList()),
        ]),
      ),
    );
  }

  Widget _StatsCard() {
    final total     = _staticReceivedTasks.length;
    final pending   = _staticReceivedTasks.where((t) => t['status'] == 'Pending').length;
    final completed = _staticReceivedTasks.where((t) => t['status'] == 'Completed').length;
    final missed    = _staticReceivedTasks.where((t) => t['status'] == 'Missed').length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 7))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _StatTile(label: "Total",     value: "$total",     icon: Icons.view_agenda_rounded,  color: const Color(0xFF6A3027)),
        _vDivider(),
        _StatTile(label: "Pending",   value: "$pending",   icon: Icons.schedule_rounded,      color: Colors.orange),
        _vDivider(),
        _StatTile(label: "Completed", value: "$completed", icon: Icons.check_circle_rounded,  color: Colors.green),
        _vDivider(),
        _StatTile(label: "Missed",    value: "$missed",    icon: Icons.cancel_rounded,        color: Colors.red),
      ]),
    );
  }

  Widget _vDivider() => Container(height: 40.h, width: 1, color: const Color(0xFFE8DDD9));

  Widget _StatTile({required String label, required String value, required IconData icon, required Color color}) {
    return Column(children: [
      Icon(icon, size: 26.sp, color: color),
      SizedBox(height: 6.h),
      Text(value,
          style: GoogleFonts.manrope(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
      SizedBox(height: 2.h),
      Text(label,
          style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF8B7D77))),
    ]);
  }

  Widget _TaskList() {
    return FutureBuilder(
      future: _fetchTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6A3027)));
        }
        final tasks = snapshot.data as List<Map<String, dynamic>>;
        if (tasks.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox_outlined, size: 56.sp, color: const Color(0xFF8B7D77)),
              SizedBox(height: 12.h),
              Text("No tasks assigned to you yet",
                  style: GoogleFonts.manrope(fontSize: 15.sp, color: const Color(0xFF8B7D77))),
            ]),
          );
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, i) => _ExpandableReceivedCard(task: tasks[i]),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTasks() async {
    // TODO: replace with real API call
    await Future.delayed(const Duration(milliseconds: 400));
    return _staticReceivedTasks;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXPANDABLE RECEIVED TASK CARD
// ─────────────────────────────────────────────────────────────────────────

class _ExpandableReceivedCard extends StatefulWidget {
  final Map<String, dynamic> task;
  const _ExpandableReceivedCard({required this.task});

  @override
  State<_ExpandableReceivedCard> createState() => _ExpandableReceivedCardState();
}

class _ExpandableReceivedCardState extends State<_ExpandableReceivedCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  Color get _statusColor {
    switch (widget.task['status']) {
      case 'Completed': return Colors.green;
      case 'Missed':    return Colors.red;
      default:          return Colors.orange;
    }
  }

  Color get _priorityColor {
    switch (widget.task['priority']) {
      case 'High': return Colors.red;
      case 'Low':  return Colors.green;
      default:     return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(children: [
        // ── Collapsed header ──────────────────────────────────────────
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18.r),
            bottom: Radius.circular(_expanded ? 0 : 18.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(children: [
              // Priority accent bar
              Container(
                width: 4.w, height: 42.h,
                decoration: BoxDecoration(
                    color: _priorityColor, borderRadius: BorderRadius.circular(4.r)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task['title'],
                      style: GoogleFonts.manrope(
                          fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF241917))),
                  SizedBox(height: 6.h),
                  Wrap(spacing: 6.w, runSpacing: 4.h, children: [
                    _Badge(task['priority'] ?? 'Medium', _priorityColor),
                    _Badge(task['status'], _statusColor),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.calendar_today_rounded, size: 11.sp, color: const Color(0xFF8B7D77)),
                      SizedBox(width: 3.w),
                      Text(task['due_date'] ?? '',
                          style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF8B7D77))),
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

        // ── Expanded body ─────────────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _expandedBody(task),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ]),
    );
  }

  Widget _expandedBody(Map<String, dynamic> task) {
    return Column(children: [
      Divider(color: const Color(0xFFF0E8E4), height: 1, indent: 14.w, endIndent: 14.w),
      Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Description
          _infoRow(Icons.description_outlined, "Description", task['description'] ?? ''),
          SizedBox(height: 10.h),
          // Assigned by
          _infoRow(Icons.person_outline_rounded, "Assigned by", task['assigned_by'] ?? ''),
          SizedBox(height: 10.h),
          // Recurrence
          if ((task['recurrence'] ?? '').isNotEmpty)
            _infoRow(Icons.repeat_rounded, "Recurrence", task['recurrence']),
          SizedBox(height: 14.h),
          // Mark as done / View actions
          Row(children: [
            Expanded(
              child: _ActionBtn(
                label: "Mark Done",
                icon: Icons.check_rounded,
                color: Colors.green,
                onTap: () {
                  // TODO: call your controller to update status
                  Get.snackbar("Updated", "Task marked as completed",
                      backgroundColor: Colors.green.shade50,
                      colorText: Colors.green.shade800,
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _ActionBtn(
                label: "Mark Missed",
                icon: Icons.cancel_outlined,
                color: Colors.red,
                onTap: () {
                  // TODO: call your controller to update status
                  Get.snackbar("Updated", "Task marked as missed",
                      backgroundColor: Colors.red.shade50,
                      colorText: Colors.red,
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ),
          ]),
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
                text: "$label: ",
                style: GoogleFonts.manrope(
                    fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF8B7D77))),
            TextSpan(
                text: value,
                style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF241917))),
          ]),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20.r)),
      child: Text(label,
          style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(label,
              style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}