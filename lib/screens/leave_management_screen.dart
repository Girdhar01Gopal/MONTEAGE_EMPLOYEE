import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/bottom_nav_wrapper.dart';

// ── Static preview leave data ─────────────────────────────────────────────
final List<Map<String, dynamic>> _staticLeaves = [
  {
    "id": "1",
    "leave_type": "Sick Leave",
    "reason": "Medical leave due to fever and weakness.",
    "work_handover_to": "Aman Verma",
    "from_date": "2026-04-21",
    "to_date": "2026-04-23",
    "status": "Pending",
    "approved_to": "Rahul Sharma, Priya Mehta",
    "applied_on": "2026-04-20",
    "remarks": "",
  },
  {
    "id": "2",
    "leave_type": "Casual Leave",
    "reason": "Family function leave request.",
    "work_handover_to": "Meera Iyer",
    "from_date": "2026-04-10",
    "to_date": "2026-04-12",
    "status": "Approved",
    "approved_to": "Aman Verma",
    "applied_on": "2026-04-08",
    "remarks": "",
  },
  {
    "id": "3",
    "leave_type": "Casual Leave",
    "reason": "Personal work outside city.",
    "work_handover_to": "Rahul Sharma",
    "from_date": "2026-03-28",
    "to_date": "2026-03-29",
    "status": "Rejected",
    "approved_to": "Sneha Joshi",
    "applied_on": "2026-03-25",
    "remarks": "Insufficient reason provided.",
  },
];

// ── Employee list ─────────────────────────────────────────────────────────
final List<Map<String, String>> _employeeList = [
  {"id": "1", "name": "Rahul Sharma"},
  {"id": "2", "name": "Priya Mehta"},
  {"id": "3", "name": "Aman Verma"},
  {"id": "4", "name": "Sneha Joshi"},
  {"id": "5", "name": "Meera Iyer"},
];

// ── Static approvers (simulating backend assignment) ──────────────────────
const List<String> _staticApprovers = [
  "Rahul Sharma",
  "Priya Mehta",
];

// ── Helper: format "yyyy-MM-dd" → "28-04-2026" ───────────────────────────
String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  return DateFormat('dd-MM-yyyy').format(dt);
}

class LeaveManagementScreen extends StatefulWidget {
  LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();

  String approverName = 'John Doe';
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  List<Map<String, dynamic>> leaves = List.from(_staticLeaves);
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searchVisible = false;
  int _balanceLeaves = 12;

  // ── Active filter: 'Total' | 'Pending' | 'Approved' | 'Rejected' ─────
  String _selectedFilter = 'Total';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _calcDays(Map<String, dynamic> leave) {
    final from = DateTime.tryParse(leave['from_date'] ?? '');
    final to = DateTime.tryParse(leave['to_date'] ?? '');
    if (from != null && to != null) {
      final days = to.difference(from).inDays + 1;
      return days > 0 ? days : 0;
    }
    return 0;
  }

  void _openLeaveForm() {
    Get.bottomSheet(
      LeaveFormBottomSheet(
        balanceLeaves: _balanceLeaves,
        approvers: _staticApprovers,
        onSave: (newLeave) {
          setState(() => leaves.insert(0, newLeave));
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  List<Map<String, dynamic>> get filteredLeaves {
    final query = _searchCtrl.text.trim().toLowerCase();

    // First apply status filter
    List<Map<String, dynamic>> statusFiltered;
    if (_selectedFilter == 'Total') {
      statusFiltered = List.from(leaves);
    } else {
      statusFiltered =
          leaves.where((l) => l['status'] == _selectedFilter).toList();
    }

    // Then apply search query
    if (query.isEmpty) return statusFiltered;
    return statusFiltered.where((leave) {
      final leaveType = (leave['leave_type'] ?? '').toString().toLowerCase();
      final fromDate = (leave['from_date'] ?? '').toString().toLowerCase();
      final toDate = (leave['to_date'] ?? '').toString().toLowerCase();
      final appliedOn = (leave['applied_on'] ?? '').toString().toLowerCase();
      final fromFormatted = _formatDate(leave['from_date']).toLowerCase();
      final toFormatted = _formatDate(leave['to_date']).toLowerCase();
      return leaveType.contains(query) ||
          fromDate.contains(query) ||
          toDate.contains(query) ||
          appliedOn.contains(query) ||
          fromFormatted.contains(query) ||
          toFormatted.contains(query);
    }).toList();
  }

  void _onApprove(String id) {
    setState(() {
      final idx = leaves.indexWhere((l) => l['id'] == id);
      if (idx != -1) {
        final leave = leaves[idx];
        leaves[idx] = {...leave, 'status': 'Approved', 'remarks': ''};
        final days = _calcDays(leave);
        _balanceLeaves = (_balanceLeaves - days).clamp(0, 999);
      }
    });
    Get.snackbar(
      "Approved",
      "Leave request has been approved.",
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _onReject(String id) {
    final remarksCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: const Color(0xFFF6F1ED),
        title: Text(
          "Rejection Remarks",
          style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF241917)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide a reason for rejection:",
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: const Color(0xFF8B7D77)),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: remarksCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: const Color(0xFF241917)),
              decoration: InputDecoration(
                hintText: "Enter rejection remarks...",
                hintStyle: GoogleFonts.inter(
                    fontSize: 12.sp, color: const Color(0xFF8B7D77)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE0D5D0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE0D5D0))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                        color: Color(0xFFB54A3A), width: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: const Color(0xFF8B7D77),
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              final remarks = remarksCtrl.text.trim();
              if (remarks.isEmpty) {
                Get.snackbar("Required", "Please enter rejection remarks.",
                    backgroundColor: Colors.orange.shade50,
                    colorText: Colors.orange.shade800,
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              setState(() {
                final idx = leaves.indexWhere((l) => l['id'] == id);
                if (idx != -1) {
                  leaves[idx] = {
                    ...leaves[idx],
                    'status': 'Rejected',
                    'remarks': remarks
                  };
                }
              });
              Get.back();
              Get.snackbar("Rejected", "Leave request has been rejected.",
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB54A3A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: Text("Reject",
                style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleLeaves = filteredLeaves;
    return BottomNavWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F1ED),
        appBar: AppBar(
          title: _searchVisible
              ? TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: const Color(0xFF241917)),
                  decoration: InputDecoration(
                    hintText: "Search by type or date...",
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13.sp, color: const Color(0xFF8B7D77)),
                    border: InputBorder.none,
                  ),
                )
              : Text("Leave Approval",
                  style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF241917))),
          backgroundColor: const Color(0xFFF6F1ED),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _searchVisible ? Icons.close_rounded : Icons.search_rounded,
                color: const Color(0xFF6A3027),
              ),
              onPressed: () {
                setState(() {
                  _searchVisible = !_searchVisible;
                  if (!_searchVisible) {
                    _searchCtrl.clear();
                  }
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 4.h),
              _LeaveStatsCard(
                leaves: leaves,
                balanceLeaves: _balanceLeaves,
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
              SizedBox(height: 14.h),
              Row(children: [
                Text(
                  _selectedFilter == 'Total'
                      ? "View Leaves"
                      : "$_selectedFilter Leaves",
                  style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF241917)),
                ),
                SizedBox(width: 8.w),
                // Show count badge when filtered
                if (_selectedFilter != 'Total')
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _filterColor(_selectedFilter).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "${visibleLeaves.length}",
                      style: GoogleFonts.manrope(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _filterColor(_selectedFilter),
                      ),
                    ),
                  ),
              ]),
              SizedBox(height: 12.h),
              Expanded(
                child: visibleLeaves.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        itemCount: visibleLeaves.length,
                        itemBuilder: (_, i) => _LeaveCard(
                          leave: visibleLeaves[i],
                          onApprove: _onApprove,
                          onReject: _onReject,
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openLeaveForm,
          backgroundColor: const Color(0xFFB54A3A),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Color _filterColor(String filter) {
    switch (filter) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return const Color(0xFF6A3027);
    }
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 56.sp, color: const Color(0xFF8B7D77)),
            SizedBox(height: 12.h),
            Text(
              _selectedFilter == 'Total'
                  ? "No leave history found"
                  : "No $_selectedFilter leaves found",
              style: GoogleFonts.manrope(
                  fontSize: 15.sp, color: const Color(0xFF8B7D77)),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────
// EXPANDABLE LEAVE CARD (inline accordion)
// ─────────────────────────────────────────────────────────────────────────

class _LeaveCard extends StatefulWidget {
  final Map<String, dynamic> leave;
  final Function(String) onApprove;
  final Function(String) onReject;

  const _LeaveCard({
    required this.leave,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_LeaveCard> createState() => _LeaveCardState();
}

class _LeaveCardState extends State<_LeaveCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  Color get _statusColor {
    switch (widget.leave['status']) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData get _statusIcon {
    switch (widget.leave['status']) {
      case 'Approved':
        return Icons.check_circle_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leave = widget.leave;
    final leaveType = (leave['leave_type'] ?? '').toString();
    final fromFormatted = _formatDate(leave['from_date']);
    final toFormatted = _formatDate(leave['to_date']);
    final isPending = leave['status'] == 'Pending';
    final remarks = (leave['remarks'] ?? '').toString().trim();
    final workHandover = (leave['work_handover_to'] ?? '').toString().trim();

    String numberOfDays = '';
    final from = DateTime.tryParse(leave['from_date'] ?? '');
    final to = DateTime.tryParse(leave['to_date'] ?? '');
    if (from != null && to != null) {
      final days = to.difference(from).inDays + 1;
      numberOfDays = days > 0 ? '$days day${days > 1 ? 's' : ''}' : '1 day';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _expanded
                ? _statusColor.withOpacity(0.10)
                : const Color(0x0A000000),
            blurRadius: _expanded ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: _expanded
            ? Border.all(color: _statusColor.withOpacity(0.25), width: 1.2)
            : Border.all(color: Colors.transparent, width: 1.2),
      ),
      child: Column(
        children: [
          // ── Header row ───────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  // Leave type chip
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1ED),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFE0D5D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 12.sp,
                            color: const Color(0xFF6A3027)),
                        SizedBox(width: 4.w),
                        Text(
                          leaveType.isEmpty ? 'Leave' : leaveType,
                          style: GoogleFonts.manrope(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6A3027)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Date range
                  Expanded(
                    child: Text(
                      (fromFormatted.isNotEmpty && toFormatted.isNotEmpty)
                          ? '$fromFormatted – $toFormatted'
                          : '',
                      style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: const Color(0xFF8B7D77)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Status badge
                  _StatusBadge(
                      label: leave['status'] ?? 'Pending',
                      color: _statusColor,
                      icon: _statusIcon),
                  SizedBox(width: 6.w),
                  // Animated chevron
                  RotationTransition(
                    turns: _rotateAnim,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20.sp, color: const Color(0xFFCBC0BA)),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail body ────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                    color: _statusColor.withOpacity(0.15),
                    height: 1,
                    indent: 14.w,
                    endIndent: 14.w),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info rows
                      _infoRow(Icons.description_outlined, "Reason",
                          leave['reason'] ?? ''),
                      if (workHandover.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        _infoRow(Icons.swap_horiz_rounded,
                            "Work Handled By", workHandover),
                      ],
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                              child: _smallInfoBox(
                                  icon: Icons.calendar_month_rounded,
                                  label: "From",
                                  value: fromFormatted)),
                          SizedBox(width: 8.w),
                          Expanded(
                              child: _smallInfoBox(
                                  icon: Icons.event_available_rounded,
                                  label: "To",
                                  value: toFormatted)),
                        ],
                      ),
                      if (numberOfDays.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        _infoRow(Icons.timelapse_rounded, "Duration",
                            numberOfDays),
                      ],
                      SizedBox(height: 10.h),
                      _infoRow(Icons.people_alt_outlined, "Approval To",
                          leave['approved_to'] ?? ''),
                      SizedBox(height: 10.h),
                      _infoRow(Icons.access_time_rounded, "Applied On",
                          _formatDate(leave['applied_on'])),

                      // Rejection remark
                      if (leave['status'] == 'Rejected' &&
                          remarks.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                            border:
                                Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 13.sp,
                                  color: Colors.red.shade600),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "Remark: ",
                                      style: GoogleFonts.manrope(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red.shade700),
                                    ),
                                    TextSpan(
                                      text: remarks,
                                      style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          color: Colors.red.shade800),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Approve / Reject buttons for pending
                      if (isPending) ...[
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    widget.onReject(leave['id']),
                                icon: Icon(Icons.close_rounded,
                                    size: 14.sp,
                                    color: Colors.red.shade700),
                                label: Text("Reject",
                                    style: GoogleFonts.manrope(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red.shade700)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.red.shade300),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.r)),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.h),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    widget.onApprove(leave['id']),
                                icon: Icon(Icons.check_rounded,
                                    size: 14.sp, color: Colors.white),
                                label: Text("Approve",
                                    style: GoogleFonts.manrope(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.r)),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.h),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: const Color(0xFF6A3027)),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "$label: ",
                style: GoogleFonts.manrope(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B7D77)),
              ),
              TextSpan(
                text: value,
                style: GoogleFonts.inter(
                    fontSize: 11.sp, color: const Color(0xFF241917)),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _smallInfoBox(
      {required IconData icon,
      required String label,
      required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1ED),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0D5D0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF6A3027)),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: const Color(0xFF8B7D77),
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(value,
                    style: GoogleFonts.manrope(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF241917))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STATS CARD — clickable tiles with active highlight
// ─────────────────────────────────────────────────────────────────────────

class _LeaveStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> leaves;
  final int balanceLeaves;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _LeaveStatsCard({
    required this.leaves,
    required this.balanceLeaves,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = leaves.length;
    final pending = leaves.where((e) => e['status'] == 'Pending').length;
    final approved = leaves.where((e) => e['status'] == 'Approved').length;
    final rejected = leaves.where((e) => e['status'] == 'Rejected').length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 7))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatTile(
            label: "Total",
            value: "$total",
            icon: Icons.view_agenda_rounded,
            color: const Color(0xFF6A3027),
            isSelected: selectedFilter == 'Total',
            onTap: () => onFilterChanged('Total'),
          ),
          _vDivider(),
          _StatTile(
            label: "Pending",
            value: "$pending",
            icon: Icons.pending_actions_rounded,
            color: Colors.orange,
            isSelected: selectedFilter == 'Pending',
            onTap: () => onFilterChanged('Pending'),
          ),
          _vDivider(),
          _StatTile(
            label: "Approved",
            value: "$approved",
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            isSelected: selectedFilter == 'Approved',
            onTap: () => onFilterChanged('Approved'),
          ),
          _vDivider(),
          _StatTile(
            label: "Rejected",
            value: "$rejected",
            icon: Icons.cancel_rounded,
            color: Colors.red,
            isSelected: selectedFilter == 'Rejected',
            onTap: () => onFilterChanged('Rejected'),
          ),
          _vDivider(),
          // Balance — not clickable, no onTap
          _StatTile(
            label: "Balance",
            value: "$balanceLeaves",
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF1565C0),
            isSelected: false,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(height: 40.h, width: 1, color: const Color(0xFFE8DDD9));
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap; // null = not clickable (Balance)

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.35), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 22.sp,
                color: isSelected ? color : color.withOpacity(0.65)),
            SizedBox(height: 6.h),
            Text(value,
                style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? color
                        : const Color(0xFF241917))),
            SizedBox(height: 2.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? color
                            : const Color(0xFF8B7D77))),
                if (isClickable && isSelected) ...[
                  SizedBox(width: 2.w),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 10.sp, color: color),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET FORM
// ─────────────────────────────────────────────────────────────────────────

class LeaveFormBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final int balanceLeaves;
  final List<String> approvers;

  const LeaveFormBottomSheet({
    super.key,
    required this.onSave,
    required this.balanceLeaves,
    required this.approvers,
  });

  @override
  State<LeaveFormBottomSheet> createState() => _LeaveFormBottomSheetState();
}

class _LeaveFormBottomSheetState extends State<LeaveFormBottomSheet> {
  late TextEditingController _reasonCtrl;
  late TextEditingController _fromDateCtrl;
  late TextEditingController _toDateCtrl;
  late TextEditingController _workHandoverCtrl;

  String? _leaveType;
  DateTime? _fromDate;
  DateTime? _toDate;

  String? _prescriptionFileName;

  static const _handoverTypes = ['Casual Leave', 'Sick Leave', 'Short Leave'];

  bool get _needsHandover =>
      _leaveType != null && _handoverTypes.contains(_leaveType);
  bool get _needsPrescription => _leaveType == 'Sick Leave';

  int get _numberOfDays {
    if (_fromDate != null && _toDate != null) {
      final diff = _toDate!.difference(_fromDate!).inDays + 1;
      return diff > 0 ? diff : 0;
    }
    return 0;
  }

  int get _balanceLeaves => widget.balanceLeaves;

  @override
  void initState() {
    super.initState();
    _reasonCtrl = TextEditingController();
    _fromDateCtrl = TextEditingController();
    _toDateCtrl = TextEditingController();
    _workHandoverCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _fromDateCtrl.dispose();
    _toDateCtrl.dispose();
    _workHandoverCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final firstDate = isFrom ? today : (_fromDate ?? today);
    final initialDate =
        isFrom ? (_fromDate ?? today) : (_toDate ?? firstDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFFB54A3A))),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          _fromDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = null;
            _toDateCtrl.clear();
          }
        } else {
          _toDate = picked;
          _toDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _pickPrescription() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F1ED),
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upload Prescription",
                  style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF241917))),
              SizedBox(height: 16.h),
              ListTile(
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await ImagePicker()
                      .pickImage(
                          source: ImageSource.camera, imageQuality: 85);
                  if (image != null) {
                    setState(() => _prescriptionFileName = image.name);
                  }
                },
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB54A3A).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: const Color(0xFFB54A3A), size: 20.sp),
                ),
                title: Text("Take a Photo",
                    style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF241917))),
                subtitle: Text("Use camera to capture prescription",
                    style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF8B7D77))),
              ),
              SizedBox(height: 4.h),
              ListTile(
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await ImagePicker().pickImage(
                      source: ImageSource.gallery, imageQuality: 85);
                  if (image != null) {
                    setState(() => _prescriptionFileName = image.name);
                  }
                },
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB54A3A).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: const Color(0xFFB54A3A), size: 20.sp),
                ),
                title: Text("Choose from Gallery",
                    style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF241917))),
                subtitle: Text("Select an existing image from gallery",
                    style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF8B7D77))),
              ),
              SizedBox(height: 4.h),
              ListTile(
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    setState(
                        () => _prescriptionFileName = result.files.first.name);
                  }
                },
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB54A3A).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded,
                      color: const Color(0xFFB54A3A), size: 20.sp),
                ),
                title: Text("Upload PDF",
                    style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF241917))),
                subtitle: Text("Pick a PDF from your files",
                    style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF8B7D77))),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F1ED),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: const Color(0xFFCBC0BA),
                    borderRadius: BorderRadius.circular(2.r)),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Apply Leave",
                        style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF241917))),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                            color: Color(0xFFE8DDD9), shape: BoxShape.circle),
                        child: Icon(Icons.close,
                            size: 18.sp, color: const Color(0xFF6A3027)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              const Divider(color: Color(0xFFE0D5D0), height: 1),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
                  children: [
                    _label("Leave Type *"),
                    SizedBox(height: 6.h),
                    _leaveTypeDropdown(),
                    SizedBox(height: 16.h),
                    _label("Leave Reason *"),
                    SizedBox(height: 6.h),
                    _field(_reasonCtrl, "Enter leave reason...", maxLines: 4),
                    SizedBox(height: 16.h),
                    if (_needsHandover) ...[
                      _label("Work will be handled by *"),
                      SizedBox(height: 4.h),
                      Text(
                        "Mention the colleague who will manage your responsibilities during the leave.",
                        style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF8B7D77)),
                      ),
                      SizedBox(height: 6.h),
                      _field(_workHandoverCtrl, "E.g. Aman Verma"),
                      SizedBox(height: 16.h),
                    ],
                    _label("From Date *"),
                    SizedBox(height: 6.h),
                    _dateBox(
                        controller: _fromDateCtrl,
                        hint: "Select from date",
                        onTap: () => _pickDate(isFrom: true)),
                    SizedBox(height: 16.h),
                    _label("To Date *"),
                    SizedBox(height: 6.h),
                    _dateBox(
                        controller: _toDateCtrl,
                        hint: "Select to date",
                        onTap: () => _pickDate(isFrom: false)),
                    SizedBox(height: 16.h),
                    _label("Number of Days"),
                    SizedBox(height: 6.h),
                    _readOnlyBox(
                      icon: Icons.timelapse_rounded,
                      value: _numberOfDays > 0
                          ? "$_numberOfDays day${_numberOfDays > 1 ? 's' : ''}"
                          : "—",
                      valueColor:
                          _numberOfDays > _balanceLeaves && _numberOfDays > 0
                              ? Colors.red.shade700
                              : null,
                    ),
                    if (_numberOfDays > _balanceLeaves &&
                        _numberOfDays > 0) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 14.sp, color: Colors.red.shade700),
                          SizedBox(width: 6.w),
                          Text(
                            "Exceeds balance by ${_numberOfDays - _balanceLeaves} day(s)",
                            style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16.h),
                    _label("Balance Leaves"),
                    SizedBox(height: 6.h),
                    _readOnlyBox(
                      icon: Icons.account_balance_wallet_rounded,
                      value: "$_balanceLeaves leaves remaining",
                      valueColor: _balanceLeaves < 3
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                    SizedBox(height: 24.h),
                    if (_needsPrescription) ...[
                      _label("Doctor's Prescription"),
                      SizedBox(height: 4.h),
                      Text(
                        "Please upload a valid prescription from a registered doctor.",
                        style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF8B7D77)),
                      ),
                      SizedBox(height: 6.h),
                      _prescriptionUploadBox(),
                      SizedBox(height: 24.h),
                    ],
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
                        child: Text("Submit Leave Request",
                            style: GoogleFonts.manrope(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _prescriptionUploadBox() {
    final hasFile = _prescriptionFileName != null;
    return GestureDetector(
      onTap: _pickPrescription,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: hasFile ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                hasFile ? Colors.green.shade400 : const Color(0xFFB54A3A),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: hasFile
                    ? Colors.green.shade100
                    : const Color(0xFFB54A3A).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                size: 20.sp,
                color: hasFile
                    ? Colors.green.shade700
                    : const Color(0xFFB54A3A),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile
                        ? "Prescription uploaded"
                        : "Tap to upload prescription",
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: hasFile
                          ? Colors.green.shade700
                          : const Color(0xFF241917),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hasFile
                        ? _prescriptionFileName!
                        : "Camera · Gallery · PDF",
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: hasFile
                          ? Colors.green.shade600
                          : const Color(0xFF8B7D77),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasFile)
              GestureDetector(
                onTap: () => setState(() => _prescriptionFileName = null),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(Icons.close_rounded,
                      size: 18.sp, color: Colors.red.shade400),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _leaveTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _leaveType != null
              ? const Color(0xFFB54A3A)
              : const Color(0xFFE0D5D0),
          width: _leaveType != null ? 1.5 : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _leaveType,
          isExpanded: true,
          hint: Text("Select Leave Type",
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: const Color(0xFF8B7D77))),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF6A3027), size: 20.sp),
          style: GoogleFonts.inter(
              fontSize: 14.sp, color: const Color(0xFF241917)),
          onChanged: (newValue) {
            setState(() {
              _leaveType = newValue;
              if (newValue != 'Sick Leave') _prescriptionFileName = null;
              if (newValue == 'Work From Home') _workHandoverCtrl.clear();
            });
          },
          items: [
            'Casual Leave',
            'Sick Leave',
            'Short Leave',
            'Work From Home'
          ]
              .map((type) =>
                  DropdownMenuItem<String>(value: type, child: Text(type)))
              .toList(),
        ),
      ),
    );
  }

  Widget _readOnlyBox(
      {required IconData icon, required String value, Color? valueColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0D5D0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.sp, color: const Color(0xFF6A3027)),
          SizedBox(width: 10.w),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? const Color(0xFF241917))),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.manrope(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF241917)));

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style:
          GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF241917)),
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
  }

  Widget _dateBox(
      {required TextEditingController controller,
      required String hint,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: controller.text.isNotEmpty
                ? const Color(0xFFB54A3A)
                : const Color(0xFFE0D5D0),
            width: controller.text.isNotEmpty ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 17.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 10.w),
            Text(
              controller.text.isEmpty ? hint : controller.text,
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: controller.text.isEmpty
                      ? const Color(0xFF8B7D77)
                      : const Color(0xFF241917)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final reason = _reasonCtrl.text.trim();
    final workHandover = _workHandoverCtrl.text.trim();

    String? missingField;
    if (_leaveType == null) {
      missingField = "Please select a Leave Type.";
    } else if (reason.isEmpty) {
      missingField = "Please enter a Leave Reason.";
    } else if (_needsHandover && workHandover.isEmpty) {
      missingField = "Please enter the colleague who will handle your work.";
    } else if (_fromDateCtrl.text.isEmpty) {
      missingField = "Please select a From Date.";
    } else if (_toDateCtrl.text.isEmpty) {
      missingField = "Please select a To Date.";
    }

    if (missingField != null) {
      Get.snackbar("Missing Info", missingField,
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade800,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
      return;
    }

    if (_fromDate != null && _toDate != null && _toDate!.isBefore(_fromDate!)) {
      Get.snackbar("Invalid Dates", "To date cannot be before from date.",
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_numberOfDays > _balanceLeaves) {
      Get.snackbar(
        "Insufficient Balance",
        "You only have $_balanceLeaves leave(s) remaining, but requested $_numberOfDays day(s).",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final newLeave = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "leave_type": _leaveType,
      "reason": reason,
      if (workHandover.isNotEmpty) "work_handover_to": workHandover,
      "from_date": _fromDate != null
          ? DateFormat('yyyy-MM-dd').format(_fromDate!)
          : '',
      "to_date":
          _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '',
      "status": "Pending",
      "approved_to": widget.approvers.join(', '),
      "applied_on": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "remarks": "",
      if (_prescriptionFileName != null) "prescription": _prescriptionFileName,
    };

    widget.onSave(newLeave);
    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar("Submitted", "Leave request submitted successfully.",
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.BOTTOM);
    });
  }
}
