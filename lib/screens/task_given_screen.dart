import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ── Static preview data (replace with real API call) ──────────────────────
final List<Map<String, dynamic>> _staticTasks = [
  {
    "id": "1",
    "title": "Update Client Dashboard",
    "description": "Revamp the analytics dashboard with new KPI widgets and charts.",
    "due_date": "2026-04-28",
    "status": "Pending",
    "assigned_to": "Rahul Sharma, Priya Mehta",
    "priority": "High",
    "recurrence": "Weekly",
  },
  {
    "id": "2",
    "title": "Fix Login Bug",
    "description": "Resolve OTP screen crash on Android 13 devices immediately.",
    "due_date": "2026-04-25",
    "status": "Completed",
    "assigned_to": "Priya Mehta",
    "priority": "High",
    "recurrence": "Daily",
  },
  {
    "id": "3",
    "title": "Write API Docs",
    "description": "Document all v2 endpoints with request/response examples and error codes.",
    "due_date": "2026-05-02",
    "status": "Pending",
    "assigned_to": "Aman Verma",
    "priority": "Medium",
    "recurrence": "Monthly",
  },
  {
    "id": "4",
    "title": "Team Status Meeting",
    "description": "Conduct weekly sync and share progress updates with all stakeholders.",
    "due_date": "2026-04-20",
    "status": "Missed",
    "assigned_to": "Sneha Joshi",
    "priority": "Low",
    "recurrence": "Weekly",
  },
];

// ── Employee list (replace with API) ─────────────────────────────────────
final List<Map<String, String>> _employeeList = [
  {"id": "1", "name": "Rahul Sharma"},
  {"id": "2", "name": "Priya Mehta"},
  {"id": "3", "name": "Aman Verma"},
  {"id": "4", "name": "Sneha Joshi"},
  {"id": "5", "name": "Meera Iyer"},
];

// ─────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────

class TaskGivenScreen extends StatefulWidget {
  @override
  State<TaskGivenScreen> createState() => _TaskGivenScreenState();
}

class _TaskGivenScreenState extends State<TaskGivenScreen> {
  List<Map<String, dynamic>> tasks = List.from(_staticTasks);

  void _deleteTask(String id) {
    setState(() => tasks.removeWhere((t) => t['id'] == id));
    Get.snackbar("Deleted", "Task removed successfully",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM);
  }

  void _openForm({Map<String, dynamic>? existing}) {
    Get.bottomSheet(
      TaskForm(
        existingTask: existing,
        onSave: (updated) {
          setState(() {
            if (existing != null) {
              final idx = tasks.indexWhere((t) => t['id'] == existing['id']);
              if (idx != -1) tasks[idx] = updated;
            } else {
              tasks.add(updated);
            }
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        title: Text("Tasks You Assigned",
            style: GoogleFonts.manrope(
                fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
        backgroundColor: const Color(0xFFF6F1ED),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(children: [
          SizedBox(height: 4.h),
          _StatsCard(tasks: tasks),
          SizedBox(height: 20.h),
          Expanded(
            child: tasks.isEmpty
                ? _emptyState()
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) => _ExpandableTaskCard(
                      task: tasks[i],
                      onDelete: () => _deleteTask(tasks[i]['id']),
                      onEdit: () => _openForm(existing: tasks[i]),
                    ),
                  ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFFB54A3A),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.assignment_outlined, size: 56.sp, color: const Color(0xFF8B7D77)),
          SizedBox(height: 12.h),
          Text("No tasks assigned yet",
              style: GoogleFonts.manrope(fontSize: 15.sp, color: const Color(0xFF8B7D77))),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────
// STATS CARD
// ─────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const _StatsCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total     = tasks.length;
    final pending   = tasks.where((t) => t['status'] == 'Pending').length;
    final completed = tasks.where((t) => t['status'] == 'Completed').length;
    final missed    = tasks.where((t) => t['status'] == 'Missed').length;

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
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────────────────────────────────────────────────────
// EXPANDABLE TASK CARD
// ─────────────────────────────────────────────────────────────────────────

class _ExpandableTaskCard extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _ExpandableTaskCard({required this.task, required this.onDelete, required this.onEdit});

  @override
  State<_ExpandableTaskCard> createState() => _ExpandableTaskCardState();
}

class _ExpandableTaskCardState extends State<_ExpandableTaskCard>
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
          secondChild: _ExpandedBody(task: task, onEdit: widget.onEdit, onDelete: _confirmDelete),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ]),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text("Delete Task",
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
        content: Text("Are you sure you want to delete this task?",
            style: GoogleFonts.inter(color: const Color(0xFF8B7D77))),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel",
                  style: GoogleFonts.inter(color: const Color(0xFF8B7D77)))),
          ElevatedButton(
            onPressed: () { Get.back(); widget.onDelete(); },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
            child: Text("Delete",
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ExpandedBody({required this.task, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Divider(color: const Color(0xFFF0E8E4), height: 1, indent: 14.w, endIndent: 14.w),
      Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Description
          _infoRow(Icons.description_outlined, "Description", task['description'] ?? ''),
          SizedBox(height: 10.h),
          // Assigned to
          _infoRow(Icons.people_outline_rounded, "Assigned to", task['assigned_to'] ?? ''),
          SizedBox(height: 10.h),
          // Recurrence
          if ((task['recurrence'] ?? '').isNotEmpty)
            _infoRow(Icons.repeat_rounded, "Recurrence", task['recurrence']),
          SizedBox(height: 14.h),
          // Action buttons
          Row(children: [
            Expanded(child: _ActionBtn(label: "Edit", icon: Icons.edit_outlined, color: const Color(0xFF6A3027), onTap: onEdit)),
            SizedBox(width: 10.w),
            Expanded(child: _ActionBtn(label: "Delete", icon: Icons.delete_outline_rounded, color: Colors.red, onTap: onDelete)),
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

// ─────────────────────────────────────────────────────────────────────────
// TASK FORM BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────

class TaskForm extends StatefulWidget {
  final Map<String, dynamic>? existingTask;
  final Function(Map<String, dynamic>) onSave;
  const TaskForm({this.existingTask, required this.onSave});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _dueDateCtrl;

  List<String> _selectedIds = [];
  String _priority   = "Medium";
  String _recurrence = "Weekly";
  DateTime? _dueDate;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleCtrl   = TextEditingController(text: t?['title'] ?? '');
    _descCtrl    = TextEditingController(text: t?['description'] ?? '');
    _dueDateCtrl = TextEditingController(text: t?['due_date'] ?? '');
    _priority    = t?['priority'] ?? 'Medium';
    _recurrence  = t?['recurrence'] ?? 'Weekly';
    if (t != null && t['assigned_to'] != null) {
      final names = (t['assigned_to'] as String).split(', ');
      _selectedIds = _employeeList
          .where((e) => names.contains(e['name']))
          .map((e) => e['id']!)
          .toList();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  String get _selectedNames => _employeeList
      .where((e) => _selectedIds.contains(e['id']))
      .map((e) => e['name']!)
      .join(', ');

  void _toggleEmployee(String id) =>
      setState(() => _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id));

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F1ED),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(children: [
            SizedBox(height: 12.h),
            Container(width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: const Color(0xFFCBC0BA), borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_isEditing ? "Edit Task" : "Assign New Task",
                    style: GoogleFonts.manrope(
                        fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(color: Color(0xFFE8DDD9), shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 18.sp, color: const Color(0xFF6A3027)),
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

                  _label("Select Employees"),
                  SizedBox(height: 8.h),
                  _employeePicker(),
                  SizedBox(height: 16.h),

                  _label("Task Title"),
                  SizedBox(height: 6.h),
                  _field(_titleCtrl, "e.g. Review Q2 report"),
                  SizedBox(height: 16.h),

                  _label("Task Description"),
                  SizedBox(height: 6.h),
                  _field(_descCtrl, "Brief details...", maxLines: 3),
                  SizedBox(height: 16.h),

                  _label("Due Date"),
                  SizedBox(height: 6.h),
                  _datePicker(),
                  SizedBox(height: 16.h),

                  _label("Recurrence"),
                  SizedBox(height: 8.h),
                  _chipRow(['Daily', 'Weekly', 'Alternate', 'Monthly'], _recurrence,
                      (v) => setState(() => _recurrence = v)),
                  SizedBox(height: 16.h),

                  _label("Priority"),
                  SizedBox(height: 8.h),
                  _chipRow(['High', 'Medium', 'Low'], _priority,
                      (v) => setState(() => _priority = v),
                      colorMap: {'High': Colors.red, 'Medium': Colors.orange, 'Low': Colors.green}),
                  SizedBox(height: 28.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB54A3A),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                      child: Text(_isEditing ? "Save Changes" : "Assign Task",
                          style: GoogleFonts.manrope(
                              fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── Multi-select employee picker ─────────────────────────────────────────
  Widget _employeePicker() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE0D5D0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_selectedIds.isNotEmpty) ...[
          Row(children: [
            Icon(Icons.people_rounded, size: 13.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(_selectedNames,
                  style: GoogleFonts.inter(
                      fontSize: 11.sp, color: const Color(0xFF6A3027), fontWeight: FontWeight.w600)),
            ),
          ]),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFF0E8E4), height: 1),
          SizedBox(height: 10.h),
        ],
        Wrap(
          spacing: 8.w, runSpacing: 8.h,
          children: _employeeList.map((emp) {
            final selected = _selectedIds.contains(emp['id']);
            return GestureDetector(
              onTap: () => _toggleEmployee(emp['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFB54A3A) : const Color(0xFFF6F1ED),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                      color: selected ? const Color(0xFFB54A3A) : const Color(0xFFE0D5D0)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (selected) ...[
                    Icon(Icons.check_rounded, size: 13.sp, color: Colors.white),
                    SizedBox(width: 4.w),
                  ],
                  Text(emp['name']!,
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : const Color(0xFF241917))),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.manrope(
          fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF241917)));

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) => TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF241917)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF8B7D77)),
          filled: true, fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE0D5D0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE0D5D0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFB54A3A), width: 1.5)),
        ),
      );

  Widget _datePicker() => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _dueDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(primary: Color(0xFFB54A3A))),
              child: child!,
            ),
          );
          if (picked != null) {
            setState(() {
              _dueDate = picked;
              _dueDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE0D5D0)),
          ),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded, size: 17.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 10.w),
            Text(
              _dueDateCtrl.text.isEmpty ? "Select due date" : _dueDateCtrl.text,
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: _dueDateCtrl.text.isEmpty ? const Color(0xFF8B7D77) : const Color(0xFF241917)),
            ),
          ]),
        ),
      );

  Widget _chipRow(List<String> options, String selected, ValueChanged<String> onSelect,
      {Map<String, Color>? colorMap}) {
    return Wrap(
      spacing: 8.w, runSpacing: 8.h,
      children: options.map((opt) {
        final isSel  = selected == opt;
        final color = colorMap?[opt] ?? const Color(0xFFB54A3A);
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: isSel ? color.withOpacity(0.12) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: isSel ? color : const Color(0xFFE0D5D0)),
            ),
            child: Text(opt,
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSel ? color : const Color(0xFF241917))),
          ),
        );
      }).toList(),
    );
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _selectedIds.isEmpty) {
      Get.snackbar("Missing Info", "Please fill title and select at least one employee.",
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade800,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    widget.onSave({
      "id": widget.existingTask?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "title": _titleCtrl.text.trim(),
      "description": _descCtrl.text.trim(),
      "due_date": _dueDateCtrl.text,
      "status": widget.existingTask?['status'] ?? "Pending",
      "assigned_to": _selectedNames,
      "priority": _priority,
      "recurrence": _recurrence,
    });
    Get.back();
    Get.snackbar(
      _isEditing ? "Updated" : "Assigned",
      _isEditing ? "Task updated successfully" : "Task assigned successfully",
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}