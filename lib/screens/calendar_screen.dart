import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  // Mock attendance data: date -> status
  final Map<String, String> _attendanceData = {
    _fmt(DateTime.now().subtract(const Duration(days: 1))): 'present',
    _fmt(DateTime.now().subtract(const Duration(days: 2))): 'present',
    _fmt(DateTime.now().subtract(const Duration(days: 3))): 'absent',
    _fmt(DateTime.now().subtract(const Duration(days: 5))): 'present',
    _fmt(DateTime.now().subtract(const Duration(days: 6))): 'present',
    _fmt(DateTime.now().subtract(const Duration(days: 7))): 'leave',
    _fmt(DateTime.now().subtract(const Duration(days: 8))): 'present',
    _fmt(DateTime.now().subtract(const Duration(days: 9))): 'present',
    _fmt(DateTime.now().subtract(const Duration(days: 10))): 'absent',
  };

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    final List<DateTime?> days = [];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    return days;
  }

  Color _dayColor(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFF1E8E5A);
      case 'absent':
        return const Color(0xFFB54545);
      case 'leave':
        return const Color(0xFF2563EB);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final monthName =
        ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_focusedMonth.month];

    // Stats for current month
    final monthDays = _attendanceData.entries.where((e) {
      final d = DateTime.tryParse(e.key);
      return d != null &&
          d.month == _focusedMonth.month &&
          d.year == _focusedMonth.year;
    });
    final presentCount =
        monthDays.where((e) => e.value == 'present').length;
    final absentCount =
        monthDays.where((e) => e.value == 'absent').length;
    final leaveCount =
        monthDays.where((e) => e.value == 'leave').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 72.h,
        backgroundColor: const Color(0xFFF6F1ED),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar',
              style: GoogleFonts.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917),
              ),
            ),
            Text(
              'Your attendance overview',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF756A66),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
          child: Column(
            children: [
              // ── Stats Row ──────────────────────────────────────
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                      label: 'Present',
                      value: '$presentCount',
                      color: const Color(0xFF1E8E5A),
                      icon: Icons.check_circle_rounded,
                    ),
                    Container(
                        width: 1,
                        height: 36.h,
                        color: const Color(0xFFE8DDD9)),
                    _StatChip(
                      label: 'Absent',
                      value: '$absentCount',
                      color: const Color(0xFFB54545),
                      icon: Icons.cancel_rounded,
                    ),
                    Container(
                        width: 1,
                        height: 36.h,
                        color: const Color(0xFFE8DDD9)),
                    _StatChip(
                      label: 'Leave',
                      value: '$leaveCount',
                      color: const Color(0xFF2563EB),
                      icon: Icons.beach_access_rounded,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── Calendar Card ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month navigator
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 12.w, 0),
                      child: Row(
                        children: [
                          Text(
                            '$monthName ${_focusedMonth.year}',
                            style: GoogleFonts.manrope(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF241917),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded,
                                color: Color(0xFF6A3027)),
                            onPressed: _previousMonth,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF6A3027)),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Weekday headers
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                            .map(
                              (d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF8B7D77),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Calendar grid
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 4.h),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        children: days.map((day) {
                          if (day == null) return const SizedBox();
                          final key = _fmt(day);
                          final status = _attendanceData[key];
                          final isToday = _fmt(day) == _fmt(DateTime.now());
                          final isSelected = _selectedDay != null &&
                              _fmt(day) == _fmt(_selectedDay!);
                          final bgColor = status != null
                              ? _dayColor(status)
                              : Colors.transparent;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDay = day),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              margin: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF241917)
                                    : status != null
                                        ? bgColor.withOpacity(0.15)
                                        : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(10.r),
                                border: isToday
                                    ? Border.all(
                                        color: const Color(0xFF6A3027),
                                        width: 1.5)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.day}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12.sp,
                                      fontWeight: isToday || isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : status != null
                                              ? _dayColor(status)
                                              : const Color(0xFF241917),
                                    ),
                                  ),
                                  if (status != null)
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 2.h),
                                      width: 4.w,
                                      height: 4.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : _dayColor(status),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Legend
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(
                              color: const Color(0xFF1E8E5A),
                              label: 'Present'),
                          SizedBox(width: 16.w),
                          _LegendDot(
                              color: const Color(0xFFB54545),
                              label: 'Absent'),
                          SizedBox(width: 16.w),
                          _LegendDot(
                              color: const Color(0xFF2563EB),
                              label: 'Leave'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Selected Day Detail ────────────────────────────
              if (_selectedDay != null) ...[
                SizedBox(height: 16.h),
                _DayDetailCard(
                  day: _selectedDay!,
                  status: _attendanceData[_fmt(_selectedDay!)],
                  statusColor: _attendanceData[_fmt(_selectedDay!)] != null
                      ? _dayColor(_attendanceData[_fmt(_selectedDay!)]!)
                      : const Color(0xFF8B7D77),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label, value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: color),
        SizedBox(height: 4.h),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917))),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B7D77))),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF756A66))),
      ],
    );
  }
}

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({
    required this.day,
    required this.status,
    required this.statusColor,
  });

  final DateTime day;
  final String? status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final dayNames = [
      '', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${day.day}',
              style: GoogleFonts.manrope(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dayNames[day.weekday]}, ${monthNames[day.month]} ${day.year}',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF241917),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status != null
                        ? status![0].toUpperCase() + status!.substring(1)
                        : 'No Record',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}