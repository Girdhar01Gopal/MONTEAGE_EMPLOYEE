import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/task_controller.dart';
import '../controllers/project_controller.dart' hide Data;
import '../models/project_model.dart';

// ─────────────────────────────────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────────────────────────────────

// Role detection lives solely on TaskController (isProjectManager /
// isTeamLeader / isRegularEmployee) — these delegate to it so there is one
// source of truth instead of a second copy of the designation-matching rules.
bool get _isProjectManager => Get.find<TaskController>().isProjectManager;
bool get _isTeamLeader => Get.find<TaskController>().isTeamLeader;
bool get _isRegularEmployee => Get.find<TaskController>().isRegularEmployee;

// ─────────────────────────────────────────────────────────────────────────
// TASK BADGE
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
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EMPLOYEE LIST SHEET
// ─────────────────────────────────────────────────────────────────────────

class _EmployeeListSheet extends StatefulWidget {
  final TaskController controller;
  const _EmployeeListSheet({required this.controller});

  @override
  State<_EmployeeListSheet> createState() => _EmployeeListSheetState();
}

class _EmployeeListSheetState extends State<_EmployeeListSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
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
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Employee List',
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF241917),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8DDD9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18.sp, color: const Color(0xFF6A3027)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF241917)),
              decoration: InputDecoration(
                hintText: 'Search employee…',
                hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF8B7D77)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6A3027)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: Color(0xFFB54A3A), width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(color: Color(0xFFE0D5D0), height: 1),
          Expanded(
            child: Obx(() {
              final c = widget.controller;
              if (c.isLoading.value && c.employees.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF6A3027)));
              }
              final filtered = c.employees
                  .where((e) => e.employeeName.toLowerCase().contains(_search.toLowerCase()))
                  .toList();
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48.sp, color: const Color(0xFF8B7D77)),
                      SizedBox(height: 12.h),
                      Text(
                        _search.isEmpty ? 'No employees found' : 'No results for "$_search"',
                        style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF8B7D77)),
                      ),
                      if (_search.isEmpty) ...[
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Get.back();
                            await c.fetchAll();
                            Get.bottomSheet(
                              _EmployeeListSheet(controller: c),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          icon: Icon(Icons.refresh_rounded, size: 16.sp, color: Colors.white),
                          label: Text('Retry',
                              style: GoogleFonts.manrope(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB54A3A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final emp = filtered[i];
                  final stats = c.taskStatsFor(emp);
                  return GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.bottomSheet(
                        _EmployeeDetailSheet(employee: emp),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor:
                                const Color(0xFFB54A3A).withOpacity(0.12),
                            child: Text(
                              emp.employeeName.isNotEmpty
                                  ? emp.employeeName[0]
                                  : '?',
                              style: GoogleFonts.manrope(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFB54A3A)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(emp.employeeName,
                                    style: GoogleFonts.manrope(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF241917))),
                                SizedBox(height: 3.h),
                                Text('Code: ${emp.employeeCode}',
                                    style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF8B7D77))),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    _miniStat(Icons.check_circle_rounded,
                                        Colors.green, '${stats.completed} done'),
                                    SizedBox(width: 10.w),
                                    _miniStat(Icons.pending_actions_rounded,
                                        Colors.orange, '${stats.pending} pending'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: const Color(0xFF6A3027), size: 20.sp),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 3.w),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────
// EMPLOYEE DETAIL SHEET
// ─────────────────────────────────────────────────────────────────────────

class _EmployeeDetailSheet extends StatelessWidget {
  final EmployeeModel employee;
  const _EmployeeDetailSheet({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.bottomSheet(
                      _EmployeeListSheet(
                          controller: Get.find<TaskController>()),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                        color: Color(0xFFE8DDD9), shape: BoxShape.circle),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16.sp, color: const Color(0xFF6A3027)),
                  ),
                ),
                SizedBox(width: 10.w),
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: const Color(0xFFB54A3A).withOpacity(0.12),
                  child: Text(
                    employee.employeeName.isNotEmpty
                        ? employee.employeeName[0]
                        : '?',
                    style: GoogleFonts.manrope(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB54A3A)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(employee.employeeName,
                      style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF241917))),
                ),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Employee Details',
                      style: GoogleFonts.manrope(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF241917))),
                  SizedBox(height: 20.h),
                  _row('Employee ID', employee.employeeId.toString()),
                  SizedBox(height: 12.h),
                  _row('Employee Code', employee.employeeCode),
                  SizedBox(height: 12.h),
                  _row('Name', employee.employeeName),
                  SizedBox(height: 12.h),
                  _row('Team Lead', employee.isTeamLead ? 'Yes' : 'No'),
                  if (employee.teamLeadId != null) ...[
                    SizedBox(height: 12.h),
                    _row('Team Lead ID', employee.teamLeadId!),
                  ],
                  SizedBox(height: 24.h),
                  Text('Task Workload',
                      style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF241917))),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final stats =
                        Get.find<TaskController>().taskStatsFor(employee);
                    return Row(
                      children: [
                        Expanded(
                          child: _workloadTile(
                            label: 'Completed',
                            value: stats.completed,
                            icon: Icons.check_circle_rounded,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _workloadTile(
                            label: 'Pending',
                            value: stats.pending,
                            icon: Icons.pending_actions_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workloadTile({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(height: 8.h),
          Text('$value',
              style: GoogleFonts.manrope(
                  fontSize: 18.sp, fontWeight: FontWeight.w800, color: color)),
          SizedBox(height: 2.h),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B7D77))),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14.sp, color: const Color(0xFF241917))),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────
// TASK SCREEN
// ─────────────────────────────────────────────────────────────────────────

class TaskScreen extends GetView<TaskController> {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _c = controller;
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
                  _c.isSearchExpanded.value
                      ? Icons.search_off_rounded
                      : Icons.search_rounded,
                  color: const Color(0xFF6A3027),
                ),
                onPressed: _c.toggleSearch,
              )),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6A3027)),
            onPressed: _c.fetchAll,
          ),
        ],
      ),
      body: Obx(() {
        if (_c.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A3027)));
        }
        return _Body(c: _c);
      }),
      floatingActionButton: (_isRegularEmployee || _c.effectiveTab != 0)
          ? null
          : FloatingActionButton(
              onPressed: () => Get.bottomSheet(
                _TaskForm(c: _c),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: const Color(0xFFB54A3A),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final TaskController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    final isManager = _isProjectManager;
    final isTL = _isTeamLeader;
    final isRegular = _isRegularEmployee;

    if (!Get.isRegistered<ProjectController>()) {
      Get.put(ProjectController());
    }

    if (isRegular) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            child: Column(
              children: [
                _TabToggle(c: c),
                SizedBox(height: 12.h),
                Obx(() {
                  if (!c.isSearchExpanded.value) return const SizedBox.shrink();
                  final isProjectsTab = c.effectiveTab == 1;
                  final pc = Get.isRegistered<ProjectController>()
                      ? Get.find<ProjectController>()
                      : null;
                  return Column(
                    children: [
                      _SearchBar(
                        onChanged: isProjectsTab && pc != null
                            ? pc.setTLSearch
                            : c.setSearch,
                        hint: isProjectsTab
                            ? 'Search by project name…'
                            : 'Search by title or date…',
                      ),
                      SizedBox(height: 12.h),
                    ],
                  );
                }),
                Obx(() {
                  if (c.effectiveTab == 1) {
                    final pc = Get.isRegistered<ProjectController>()
                        ? Get.find<ProjectController>()
                        : null;
                    if (pc == null) return const SizedBox.shrink();
                    return _RegularProjectStatsCard(pc: pc);
                  }
                  return _StatsCard(c: c, showEmpTile: false);
                }),
                SizedBox(height: 12.h),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.effectiveTab == 1) {
                final pc = Get.isRegistered<ProjectController>()
                    ? Get.find<ProjectController>()
                    : null;
                if (pc == null) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6A3027)));
                }
                return _RegularProjectList(pc: pc);
              }
              return _RegularTaskList(c: c);
            }),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          child: Obx(() {
            final tab = c.effectiveTab;
            final isPMProjectsTab = isManager && tab == 1;
            final isTLProjectsTab = isTL && tab == 2;
            final pc = Get.find<ProjectController>();

            return Column(
              children: [
                _TabToggle(c: c),
                SizedBox(height: 12.h),
                if (c.isSearchExpanded.value) ...[
                  _SearchBar(
                    onChanged: isPMProjectsTab
                        ? pc.setSearch
                        : isTLProjectsTab
                            ? pc.setTLSearch
                            : c.setSearch,
                    hint: (isPMProjectsTab || isTLProjectsTab)
                        ? 'Search by project name…'
                        : 'Search by title or date…',
                  ),
                  SizedBox(height: 12.h),
                ],
                if (!isPMProjectsTab && !isTLProjectsTab) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                    child: Text(
                      tab == 0 ? 'Given Tasks Overview' : 'Received Tasks Overview',
                      style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B7D77)),
                    ),
                  ),
                ],
                isPMProjectsTab
                    ? _ProjectStatsCard(pc: pc)
                    : isTLProjectsTab
                        ? _TLProjectStatsCard(pc: pc)
                        : _StatsCard(c: c, showEmpTile: isManager),
                SizedBox(height: 12.h),
              ],
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            final tab = c.effectiveTab;
            return _buildList(isManager, isTL, tab);
          }),
        ),
      ],
    );
  }

  Widget _buildList(bool isManager, bool isTL, int tab) {
    if (isManager && tab == 1) {
      if (!Get.isRegistered<ProjectController>()) {
        Get.put(ProjectController());
      }
      final pc = Get.find<ProjectController>();
      return Obx(() {
        final projects = pc.filteredProjects;
        if (pc.isLoading.value && projects.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A3027)));
        }
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
          itemBuilder: (_, i) => _ProjectCard(project: projects[i]),
        );
      });
    }

    if (isTL && tab == 2) {
      if (!Get.isRegistered<ProjectController>()) {
        Get.put(ProjectController());
      }
      final pc = Get.find<ProjectController>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pc.tlAllocateProjects.isEmpty && !pc.isAllocateLoading.value)
          pc.fetchTLAllocateProjects();
      });
      return Obx(() {
        if (pc.isAllocateLoading.value && pc.tlAllocateProjects.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A3027)));
        }
        final projects = pc.filteredTLAllocateProjects;
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined,
                    size: 58.sp, color: const Color(0xFF8B7D77)),
                SizedBox(height: 12.h),
                Text(
                  'No projects found',
                  style: GoogleFonts.manrope(
                      fontSize: 15.sp, color: const Color(0xFF8B7D77)),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: () => pc.fetchTLAllocateProjects(),
                  icon: Icon(Icons.refresh_rounded, size: 16.sp, color: Colors.white),
                  label: Text('Retry',
                      style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB54A3A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: projects.length,
          itemBuilder: (_, i) => _TLAllocateProjectCard(project: projects[i]),
        );
      });
    }

    return Obx(() {
      final tasks = c.filteredTasks;
      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 58.sp, color: const Color(0xFF8B7D77)),
              SizedBox(height: 12.h),
              Text('No tasks found',
                  style: GoogleFonts.manrope(
                      fontSize: 15.sp, color: const Color(0xFF8B7D77))),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: tasks.length,
        itemBuilder: (_, i) => _TaskCard(task: tasks[i], c: c),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REGULAR EMPLOYEE TASK LIST
// ─────────────────────────────────────────────────────────────────────────

class _RegularTaskList extends StatelessWidget {
  final TaskController c;
  const _RegularTaskList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6A3027)));
      }
      final tasks = c.filteredTasks;
      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 58.sp, color: const Color(0xFF8B7D77)),
              SizedBox(height: 12.h),
              Text('No tasks assigned to you',
                  style: GoogleFonts.manrope(
                      fontSize: 15.sp, color: const Color(0xFF8B7D77))),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => c.fetchAll(),
                icon:
                    Icon(Icons.refresh_rounded, size: 16.sp, color: Colors.white),
                label: Text('Refresh',
                    style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB54A3A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: tasks.length,
        itemBuilder: (_, i) => _TaskCard(task: tasks[i], c: c),
      );
    });
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
    final isTL = _isTeamLeader;
    return Obx(() {
      final _ = c.activeTab.value;
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8DDD9),
          borderRadius: BorderRadius.circular(14.r),
        ),
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            if (isManager) ...[
              _tab('Given', 0),
              _tab('Projects', 1),
            ] else if (isTL) ...[
              _tab('Given', 0),
              _tab('Received', 1),
              _tab('Projects', 2),
            ] else ...[
              _tab('Tasks', 0),
              _tab('Projects', 1),
            ],
          ],
        ),
      );
    });
  }

  Widget _tab(String label, int index) {
    final active = c.effectiveTab == index;
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : const Color(0xFF8B7D77),
            ),
          ),
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
  final String hint;
  const _SearchBar({required this.onChanged, this.hint = 'Search…'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style:
          GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF241917)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF8B7D77)),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6A3027)),
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
          borderSide: const BorderSide(color: Color(0xFFB54A3A), width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STATS CARD
// ─────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final TaskController c;
  final bool showEmpTile;
  const _StatsCard({required this.c, this.showEmpTile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
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
              c: c,
              label: 'Total',
              value: () => c.totalCount,
              icon: Icons.view_agenda_rounded,
              color: const Color(0xFF6A3027),
              filter: 'All'),
          _divider(),
          _StatTile(
              c: c,
              label: 'Active',
              value: () => c.activeCount,
              icon: Icons.play_circle_outline_rounded,
              color: Colors.orange,
              filter: 'Active'),
          _divider(),
          _StatTile(
              c: c,
              label: 'Completed',
              value: () => c.approvedCount,
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              filter: 'Approved'),
          _divider(),
          _StatTile(
              c: c,
              label: 'Overdue',
              value: () => c.overdueCount,
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              filter: 'Overdue'),
          if (showEmpTile) ...[_divider(), _EmpTileWidget(c: c)],
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 38.h, width: 1, color: const Color(0xFFE8DDD9));
}

class _StatTile extends StatelessWidget {
  final TaskController c;
  final String label;
  final int Function() value;
  final IconData icon;
  final Color color;
  final String filter;
  const _StatTile({
    required this.c,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = c.selectedFilter.value == filter;
      return GestureDetector(
        onTap: () => c.setFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: active
                ? Border.all(color: color.withOpacity(0.40), width: 1.2)
                : Border.all(color: Colors.transparent, width: 1.2),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 24.sp,
                  color: active ? color : color.withOpacity(0.40)),
              SizedBox(height: 5.h),
              Text('${value()}',
                  style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: active ? color : const Color(0xFF241917))),
              SizedBox(height: 2.h),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: active ? color : const Color(0xFF8B7D77))),
            ],
          ),
        ),
      );
    });
  }
}

class _EmpTileWidget extends StatelessWidget {
  final TaskController c;
  const _EmpTileWidget({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _EmpListTile(
          count: c.employees.length,
          onTap: () => Get.bottomSheet(
            _EmployeeListSheet(controller: c),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          ),
        ));
  }
}

class _EmpListTile extends StatefulWidget {
  final VoidCallback onTap;
  final int count;
  const _EmpListTile({required this.onTap, required this.count});

  @override
  State<_EmpListTile> createState() => _EmpListTileState();
}

class _EmpListTileState extends State<_EmpListTile> {
  bool _pressed = false;
  static const _color = Color(0xFF6A3027);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _pressed ? _color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: _pressed
              ? Border.all(color: _color.withOpacity(0.40), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(Icons.people_alt_rounded,
                size: 24.sp,
                color: _pressed ? _color : _color.withOpacity(0.40)),
            SizedBox(height: 5.h),
            Text('${widget.count}',
                style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: _pressed ? _color : const Color(0xFF241917))),
            SizedBox(height: 2.h),
            Text('Emp List',
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: _pressed ? _color : const Color(0xFF8B7D77))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PROJECT STATS CARD
// ─────────────────────────────────────────────────────────────────────────

class _ProjectStatsCard extends StatelessWidget {
  final ProjectController pc;
  const _ProjectStatsCard({required this.pc});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projects = pc.allProjects;
      final current = pc.selectedFilter.value;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
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
            _pTile('Total', '${projects.length}', Icons.folder_outlined,
                const Color(0xFF6A3027), 'All', current),
            _divider(),
            _pTile(
                'Running',
                '${projects.where((p) => p.projectStatus == 'Running').length}',
                Icons.play_circle_outline_rounded,
                Colors.green,
                'Running',
                current),
            _divider(),
            _pTile(
                'Complete',
                '${projects.where((p) => p.projectStatus == 'Complete').length}',
                Icons.check_circle_outline_rounded,
                Colors.blue,
                'Complete',
                current),
            _divider(),
            _pTile(
                'On Hold',
                '${projects.where((p) => p.projectStatus == 'On Hold').length}',
                Icons.pause_circle_outline_rounded,
                Colors.orange,
                'On Hold',
                current),
          ],
        ),
      );
    });
  }

  Widget _divider() =>
      Container(height: 38.h, width: 1, color: const Color(0xFFE8DDD9));

  Widget _pTile(String label, String value, IconData icon, Color color,
      String filter, String current) {
    final active = current == filter;
    return GestureDetector(
      onTap: () => pc.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: active
              ? Border.all(color: color.withOpacity(0.40), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 24.sp,
                color: active ? color : color.withOpacity(0.40)),
            SizedBox(height: 5.h),
            Text(value,
                style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: active ? color : const Color(0xFF241917))),
            SizedBox(height: 2.h),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: active ? color : const Color(0xFF8B7D77))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TL PROJECT STATS CARD
// ─────────────────────────────────────────────────────────────────────────

class _TLProjectStatsCard extends StatelessWidget {
  final ProjectController pc;
  const _TLProjectStatsCard({required this.pc});

  TaskController get _tc {
    if (!Get.isRegistered<TaskController>()) Get.put(TaskController());
    return Get.find<TaskController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = pc.tlAllocateProjects;
      final uniqueProjects = all.map((p) => p.sProjectId).toSet().length;
      final tc = _tc;
      // Same employee roster TaskController already scopes per role —
      // a team lead only ever gets their own juniors here (see
      // _fetchEmployeesForTL), so reusing it instead of a separate
      // "members" source keeps this number consistent with what tapping
      // it opens.
      final memberCount = tc.employees.length;

      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
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
            _statTile(
              label: 'Total',
              value: '${all.length}',
              icon: Icons.folder_outlined,
              color: const Color(0xFF6A3027),
            ),
            _divider(),
            _statTile(
              label: 'Projects',
              value: '$uniqueProjects',
              icon: Icons.work_outline_rounded,
              color: Colors.blue,
            ),
            _divider(),
            _statTile(
              label: 'My Team',
              value: '$memberCount',
              icon: Icons.people_outline_rounded,
              color: Colors.green,
              onTap: () => Get.bottomSheet(
                _EmployeeListSheet(controller: tc),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _divider() =>
      Container(height: 38.h, width: 1, color: const Color(0xFFE8DDD9));

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final content = Column(
      children: [
        Icon(icon, size: 22.sp, color: color),
        SizedBox(height: 5.h),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917))),
        SizedBox(height: 2.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B7D77))),
            if (onTap != null) ...[
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right_rounded, size: 11.sp, color: color),
            ],
          ],
        ),
      ],
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STATUS HELPERS
// ─────────────────────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status) {
    case 'Approved':
    case 'Done':
    case 'Complete':
      return Colors.green;
    case 'AwaitingLeadApproval':
    case 'AwaitingAssignerApproval':
    case 'AwaitingPMApproval':
    case 'Submitted':
      return Colors.blue;
    case 'LeadRejected':
    case 'AssignerRejected':
    case 'PMRejected':
      return Colors.red;
    case 'Pending':
    default:
      return Colors.orange;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'AwaitingLeadApproval':
      return 'Awaiting TL';
    case 'AwaitingAssignerApproval':
      return 'Awaiting Assigner';
    case 'AwaitingPMApproval':
      return 'Awaiting PM';
    case 'LeadRejected':
      return 'TL Rejected';
    case 'AssignerRejected':
      return 'Assigner Rejected';
    case 'PMRejected':
      return 'PM Rejected';
    default:
      return status;
  }
}

/// Progress for the linear progress bar — based on Data.effectiveStatus.
double _taskProgress(Data t) {
  final hasJunior =
      (t.juniorId ?? '').trim().isNotEmpty && t.juniorId != '0';
  final hasTL = t.teamLeadId.trim().isNotEmpty;
  final totalSteps = (hasJunior && hasTL) ? 3 : 2;

  switch (t.effectiveStatus) {
    case 'Pending':
      return 0.0;
    case 'Submitted':
      return 1 / (totalSteps + 1);
    case 'AwaitingLeadApproval':
      return totalSteps == 3 ? 0.33 : 0.5;
    case 'AwaitingAssignerApproval':
      return totalSteps == 3 ? 0.67 : 0.5;
    case 'AwaitingPMApproval':
      return totalSteps == 3 ? 0.85 : 0.75;
    case 'Approved':
    case 'Done':
    case 'Complete':
      return 1.0;
    case 'LeadRejected':
    case 'AssignerRejected':
    case 'PMRejected':
      return 0.05;
    default:
      return 0.0;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REMARK TILE
// ─────────────────────────────────────────────────────────────────────────

class _RemarkTile extends StatelessWidget {
  final String byLabel;
  final RemarkModel remark;
  const _RemarkTile({required this.byLabel, required this.remark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.red.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.comment_outlined, size: 14.sp, color: Colors.red),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$byLabel: ${remark.rejectedBy}',
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700)),
                SizedBox(height: 3.h),
                Text(remark.remark,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: const Color(0xFF241917))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// API REMARK TILE — shown when rejected with no local remark (fallback)
// ─────────────────────────────────────────────────────────────────────────

class _ApiRemarkTile extends StatelessWidget {
  final String note;
  const _ApiRemarkTile({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.red.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.comment_outlined, size: 14.sp, color: Colors.red),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(note,
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: const Color(0xFF241917))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REJECT DIALOG
// ─────────────────────────────────────────────────────────────────────────

Future<String?> _showRejectDialog(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFF6F1ED),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text('Rejection Remark',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter reason for rejection…',
          hintStyle: GoogleFonts.inter(
              fontSize: 13.sp, color: const Color(0xFF8B7D77)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                const BorderSide(color: Color(0xFFB54A3A), width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.manrope(color: const Color(0xFF8B7D77))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB54A3A),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            elevation: 0,
          ),
          onPressed: () {
            final text = ctrl.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(ctx, text);
          },
          child: Text('Reject',
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// MARK-DONE DIALOG
// ─────────────────────────────────────────────────────────────────────────

Future<String?> _showMarkDoneDialog(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFF6F1ED),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text('Mark as Done',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Describe what you completed (optional)…',
          hintStyle: GoogleFonts.inter(
              fontSize: 13.sp, color: const Color(0xFF8B7D77)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.manrope(color: const Color(0xFF8B7D77))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(
              ctx,
              ctrl.text.trim().isEmpty
                  ? 'Task completed'
                  : ctrl.text.trim()),
          child: Text('Submit',
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<EmployeeModel?> _showDelegateDialog(
    BuildContext context, TaskController c) async {
  if (c.employees.isEmpty) {
    Get.snackbar('No Juniors Found',
        'You have no team members to delegate this task to.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800);
    return null;
  }
  return showDialog<EmployeeModel>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFF6F1ED),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text('Delegate to Junior',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: c.employees.length,
          itemBuilder: (_, i) {
            final emp = c.employees[i];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 16.r,
                backgroundColor: const Color(0xFFB54A3A).withOpacity(0.12),
                child: Text(
                  emp.employeeName.isNotEmpty ? emp.employeeName[0] : '?',
                  style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB54A3A)),
                ),
              ),
              title: Text(emp.employeeName,
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: const Color(0xFF241917))),
              onTap: () => Navigator.pop(ctx, emp),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.manrope(color: const Color(0xFF8B7D77))),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// TASK CARD  — now uses Data instead of old flat TaskModel
// ─────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatefulWidget {
  final Data task;          // ← Data, not old TaskModel
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
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
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

  // Delegates entirely to TaskController so the notification dot always
  // matches the same approval/worker rules used for the action buttons —
  // and now also lights up for workers with something to mark done, not
  // just reviewers.
  bool _needsAction(TaskController c) {
    final t = widget.task;
    return c.canLeadApprove(t) ||
        c.canPMApprove(t) ||
        c.canAssignerApprove(t) ||
        c.canMarkDone(t);
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

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final statusColor = _statusColor(t.effectiveStatus);
    final progress = _taskProgress(t);
    final isApproved = t.isGenuinelyApproved;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: t.isOverdue && !isApproved
            ? Border.all(color: Colors.red.withOpacity(0.45), width: 1.4)
            : Border.all(color: Colors.transparent),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18.r),
              bottom: Radius.circular(_expanded ? 0 : 18.r),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.title,
                          style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF241917)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Obx(() {
                        final _ = widget.c.allTasks.length;
                        if (!_needsAction(widget.c))
                          return const SizedBox.shrink();
                        return Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(right: 4.w),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        );
                      }),
                      SizedBox(width: 2.w),
                      RotationTransition(
                        turns: _rotate,
                        child: Icon(Icons.expand_more_rounded,
                            color: const Color(0xFF6A3027), size: 22.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      TaskBadge(_statusLabel(t.effectiveStatus), statusColor),
                      TaskBadge(t.priority ?? 'Medium', _priorityColor),
                      if (t.isOverdue && !isApproved)
                        TaskBadge('Overdue', Colors.red),
                      if ((t.projectName ?? '').isNotEmpty)
                        TaskBadge(t.projectName!, const Color(0xFF6A3027)),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5.h,
                      backgroundColor: const Color(0xFFE8DDD9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isApproved ? Colors.green : statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ExpandedTaskBody(task: t, c: widget.c),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXPANDED TASK BODY  — uses Data
// ─────────────────────────────────────────────────────────────────────────

class _ExpandedTaskBody extends StatelessWidget {
  final Data task;
  final TaskController c;
  const _ExpandedTaskBody({required this.task, required this.c});

  /// Always resolve the live copy from the observable list.
  /// Uses a Map lookup via uniqueId to avoid O(n) scan on every rebuild.
  Data _live() {
    final idx = c.taskIndex[task.uniqueId];
    if (idx != null && idx < c.allTasks.length) return c.allTasks[idx];
    return task;
  }

  static bool _isRejected(String s) => TaskStatus.isRejected(s);

  static bool _isAssignerChain(Data t) =>
      !taskIs3Way(t) &&
      t.assignedById.isNotEmpty &&
      t.assignedById != '0' &&
      t.assignedById != t.teamLeadId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final live = _live();
      final status = live.effectiveStatus;

      final isTL = _isTeamLeader;
      final isEmp = _isRegularEmployee;
      final currentTab = c.effectiveTab;

      final approved = live.isGenuinelyApproved;
      final rejected = _isRejected(status);

      final hasJunior =
          (live.juniorId ?? '').trim().isNotEmpty && live.juniorId != '0';
      final is3Way = taskIs3Way(live);

      final canDone = c.canMarkDone(live);
      final canDelegate = c.canDelegate(live);
      final delegatedTo = c.delegatedJuniorFor(live.uniqueId);
      final isAwaiting = c.isSubmittedAwaitingReview(live);

      // Approval eligibility is decided once, in the controller.
      // No tab gate here: a 3-way task (PM → TL → junior) is something
      // the TL *received* from the PM, not something the TL gave out, so
      // it lives in the TL's "Received" tab — gating approval on
      // currentTab == 0 would hide the Approve/Reject buttons exactly
      // when the TL needs them. canLeadApprove already requires a junior
      // to exist, so it can never fire for a task where the TL is also
      // the sole worker (no self-review risk).
      final canLApprove = c.canLeadApprove(live);
      final canPApprove = c.canPMApprove(live);
      final canAssignApprove = c.canAssignerApprove(live);
      final anyReviewAction = canLApprove || canPApprove || canAssignApprove;

      // A TL viewing their "Received" tab is usually the worker — except
      // when they're a reviewer on this specific task (3-way TL review OR
      // direct-assign where they're the assigner reviewing the submission).
      // canLApprove and canAssignApprove both gate on the TL being the
      // correct reviewer, so excluding either keeps the worker UI hidden
      // exactly when the review UI should show instead.
      final isWorkerCtx =
          isEmp || (isTL && currentTab == 1 && !canLApprove && !canAssignApprove);

      String reviewerMsg = '';
      if (canLApprove) {
        reviewerMsg =
            'Employee has submitted this task. Review and approve or reject.';
      } else if (canPApprove) {
        reviewerMsg = is3Way
            ? 'Team lead has approved this task. Give your final PM approval.'
            : 'Task submitted by the assignee. Give your final approval.';
      } else if (canAssignApprove) {
        reviewerMsg =
            'Submitted by the assignee. Review before it goes to the PM.';
      }

      String workerWaitMsg = '';
      if (isAwaiting && !canDone) {
        switch (status) {
          case 'Submitted':
          case 'AwaitingPMApproval':
            workerWaitMsg = 'Submitted to PM. Awaiting final approval.';
            break;
          case 'AwaitingAssignerApproval':
            workerWaitMsg = 'Submitted. Awaiting review from your assigner.';
            break;
          case 'AwaitingLeadApproval':
            workerWaitMsg = 'Submitted. Awaiting team lead review.';
            break;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFF0E8E4), height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Approval chain ──────────────────────────────────
                _ApprovalChain(task: live, is3Way: is3Way),
                SizedBox(height: 14.h),

                // ── Description ─────────────────────────────────────
                if (live.description.isNotEmpty) ...[
                  Text('Description',
                      style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B7D77))),
                  SizedBox(height: 4.h),
                  Text(live.description,
                      style: GoogleFonts.inter(
                          fontSize: 13.sp, color: const Color(0xFF241917))),
                  SizedBox(height: 12.h),
                ],

                // ── Meta ────────────────────────────────────────────
                if (live.assignedByName.isNotEmpty)
                  _MetaRow(label: 'Assigned by', value: live.assignedByName)
                else if (live.teamLeadName.isNotEmpty && live.juniorId != null)
                  // Delegated task: TL is in slot 1 (teamLeadName) and is
                  // effectively the assigner even if updateByy is empty.
                  _MetaRow(label: 'Delegated by', value: live.teamLeadName),
                _MetaRow(
                  label: 'Assigned to',
                  value: () {
                    if (hasJunior && (live.juniorName ?? '').isNotEmpty)
                      return live.juniorName!;
                    if (live.teamLeadName.isNotEmpty) return live.teamLeadName;
                    return '—';
                  }(),
                ),
                if (live.startDate.isNotEmpty)
                  _MetaRow(label: 'Start', value: live.startDate),
                if (live.dueDate.isNotEmpty)
                  _MetaRow(label: 'Due', value: live.dueDate),
                if ((live.recurrence ?? '').isNotEmpty &&
                    live.recurrence != 'None')
                  _MetaRow(label: 'Recurrence', value: live.recurrence!),
                SizedBox(height: 10.h),

                // ── Rejection remarks ────────────────────────────────
                if (live.leadRemark != null)
                  _RemarkTile(byLabel: 'TL', remark: live.leadRemark!),
                if (live.assignerRemark != null)
                  _RemarkTile(byLabel: 'Assigner', remark: live.assignerRemark!),
                if (live.pmRemark != null)
                  _RemarkTile(byLabel: 'PM', remark: live.pmRemark!),
                // Fallback: when rejected by API but no local remark synced yet,
                // show EmpDescription (the backend stores our remark there).
                if (rejected &&
                    live.leadRemark == null &&
                    live.assignerRemark == null &&
                    live.pmRemark == null &&
                    (live.empDescription ?? '').trim().isNotEmpty)
                  _ApiRemarkTile(note: live.empDescription!.trim()),

                SizedBox(height: 8.h),

                // ── Status banners ────────────────────────────────────
                // One shared banner style for every informational state
                // below, rather than a near-identical Container+Row+Icon
                // block repeated per case.
                if (approved) ...[
                  _InfoBanner(
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    message: is3Way || _isAssignerChain(live)
                        ? 'Approved by Project Manager ✓'
                        : 'Task completed and approved ✓',
                    bold: true,
                  ),
                  SizedBox(height: 8.h),
                ],
                if (rejected && isWorkerCtx) ...[
                  _InfoBanner(
                    icon: Icons.replay_rounded,
                    color: Colors.orange,
                    message: (live.leadRemark != null ||
                            live.assignerRemark != null ||
                            live.pmRemark != null ||
                            (live.empDescription ?? '').trim().isNotEmpty)
                        ? 'Your submission was rejected. See the remark above and resubmit.'
                        : 'Your submission was rejected. Please review and resubmit.',
                  ),
                  SizedBox(height: 8.h),
                ],
                if (workerWaitMsg.isNotEmpty && !approved) ...[
                  _InfoBanner(
                    icon: Icons.hourglass_empty_rounded,
                    color: Colors.blue,
                    message: workerWaitMsg,
                  ),
                  SizedBox(height: 8.h),
                ],
                if (anyReviewAction) ...[
                  _InfoBanner(
                    icon: Icons.notification_important_rounded,
                    color: Colors.amber.shade800,
                    message: reviewerMsg,
                    bold: true,
                  ),
                  SizedBox(height: 12.h),
                ],

                // ═══════════════════════════════════════════════════════
                // ACTION BUTTONS
                // ═══════════════════════════════════════════════════════
                if (c.isSubmitting.value)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: const CircularProgressIndicator(
                          color: Color(0xFF6A3027), strokeWidth: 2.5),
                    ),
                  )
                else ...[

                  // ── Delegated note (replaces worker/delegate actions) ──
                  if (delegatedTo != null) ...[
                    _InfoBanner(
                      icon: Icons.forward_rounded,
                      color: const Color(0xFF6A3027),
                      message: 'Delegated to $delegatedTo',
                      bold: true,
                    ),
                    SizedBox(height: 8.h),
                  ] else ...[
                    // ── WORKER: Mark Done ────────────────────────────────
                    if (isWorkerCtx) ...[
                      // Only show the action button when the worker can actually
                      // act — pending (first submission) or rejected (resubmit).
                    // When awaiting review the status banner above already
                    // informs the worker; a disabled grey button adds nothing.
                    if (canDone)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final desc = await _showMarkDoneDialog(context);
                            if (desc != null)
                              c.markDone(live.uniqueId, description: desc);
                          },
                          icon: Icon(
                            rejected
                                ? Icons.replay_rounded
                                : Icons.check_rounded,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            rejected ? 'Resubmit task' : 'Mark as done',
                            style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rejected
                                ? Colors.orange
                                : const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    if (canDelegate) ...[
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final junior =
                                await _showDelegateDialog(context, c);
                            if (junior != null) {
                              c.delegateToJunior(live.uniqueId,
                                  junior.employeeId.toString(),
                                  junior.employeeName);
                            }
                          },
                          icon: Icon(Icons.forward_rounded,
                              size: 16.sp, color: const Color(0xFF6A3027)),
                          label: Text(
                            'Delegate to Junior',
                            style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6A3027)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6A3027)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                  ],
                  ],

                  // ── Review sections ───────────────────────────────────
                  // Same shape every time (label + approve/reject row) —
                  // share one widget instead of three hand-rolled copies.
                  if (canLApprove)
                    _ReviewSection(
                      label: 'Team Lead Review',
                      labelColor: const Color(0xFF6A3027),
                      approveColor: const Color(0xFF4CAF50),
                      rejectColor: const Color(0xFFB54A3A),
                      onApprove: () => c.leadApprove(live.uniqueId),
                      onReject: (r) => c.leadReject(live.uniqueId, r),
                    ),

                  // For a 2-way task (no separate junior slot) the worker
                  // didn't create themselves — e.g. a TL who assigned
                  // directly to one junior. Approving here still escalates
                  // to the PM for final sign-off (see assignerApprove()).
                  if (canAssignApprove)
                    _ReviewSection(
                      label: 'Review Submission',
                      labelColor: Colors.blue,
                      approveColor: const Color(0xFF4CAF50),
                      rejectColor: const Color(0xFFB54A3A),
                      onApprove: () => c.assignerApprove(live.uniqueId),
                      onReject: (r) => c.assignerReject(live.uniqueId, r),
                    ),

                  if (canPApprove)
                    _ReviewSection(
                      label: 'PM Final Approval',
                      labelColor: Colors.purple,
                      approveLabel: 'Final Approve',
                      approveIcon: Icons.workspace_premium_rounded,
                      approveColor: Colors.purple,
                      rejectColor: Colors.purple,
                      onApprove: () => c.pmApprove(live.uniqueId),
                      onReject: (r) => c.pmReject(live.uniqueId, r),
                    ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// APPROVAL CHAIN TIMELINE  — uses Data
// ─────────────────────────────────────────────────────────────────────────

class _ApprovalChain extends StatelessWidget {
  final Data task;
  final bool is3Way;
  const _ApprovalChain({required this.task, required this.is3Way});

  // Assigner chain: TL assigned directly to junior (no slot 2, but assigner ≠ worker).
  // Junior marks done → TL (assigner) reviews → PM approves.
  bool get _isAssignerChain =>
      !is3Way &&
      task.assignedById.isNotEmpty &&
      task.assignedById != '0' &&
      task.assignedById != task.teamLeadId;

  @override
  Widget build(BuildContext context) {
    final steps = <_ChainStep>[];

    if (is3Way) {
      steps.addAll([
        _ChainStep(
          label: 'Employee',
          sub: task.juniorName ?? task.teamLeadName,
          state: _empState(task),
        ),
        _ChainStep(
          label: 'TL Review',
          sub: task.teamLeadName,
          state: _tlState(task),
        ),
        _ChainStep(
          label: 'PM Approve',
          sub: 'PM',
          state: _pmState(task),
        ),
      ]);
    } else if (_isAssignerChain) {
      final assignerLabel = task.assignedByName.isNotEmpty ? task.assignedByName : 'TL';
      steps.addAll([
        _ChainStep(
          label: 'Employee',
          sub: task.teamLeadName.isNotEmpty ? task.teamLeadName : '—',
          state: _empState(task),
        ),
        _ChainStep(
          label: 'TL Review',
          sub: assignerLabel,
          state: _assignerReviewState(task),
        ),
        _ChainStep(
          label: 'PM Approve',
          sub: 'PM',
          state: _pmState(task),
        ),
      ]);
    } else {
      steps.addAll([
        _ChainStep(
          label: 'In Progress',
          sub: task.teamLeadName.isNotEmpty ? task.teamLeadName : '—',
          state: _empState(task),
        ),
        _ChainStep(
          label: 'PM Approve',
          sub: 'PM',
          state: _pmState(task),
        ),
      ]);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1ED),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftDone = steps[i ~/ 2].state == _StepState.done;
            return Expanded(
              child: Container(
                height: 2,
                color: leftDone
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE0D5D0),
              ),
            );
          }
          return Flexible(child: _ChainNode(step: steps[i ~/ 2]));
        }),
      ),
    );
  }

  static _StepState _empState(Data task) {
    final s = task.effectiveStatus;
    if (task.isGenuinelyApproved) return _StepState.done;
    if (TaskStatus.isRejected(s)) return _StepState.rejected;
    if (s == 'Pending') return _StepState.pending;
    return _StepState.done;
  }

  static _StepState _tlState(Data task) {
    final s = task.effectiveStatus;
    if (task.isGenuinelyApproved) return _StepState.done;
    if (s == TaskStatus.tlRejected) return _StepState.rejected;
    if (s == TaskStatus.awaitingTL) return _StepState.active;
    if (s == TaskStatus.awaitingPM || s == 'AwaitingAssignerApproval')
      return _StepState.done;
    return _StepState.pending;
  }

  static _StepState _assignerReviewState(Data task) {
    final s = task.effectiveStatus;
    if (task.isGenuinelyApproved) return _StepState.done;
    // Only use the specific local status for assigner rejection — raw 'Rejected'
    // is ambiguous (could be assigner OR PM) so don't misattribute it here.
    if (s == 'AssignerRejected') return _StepState.rejected;
    if (s == 'AwaitingAssignerApproval') return _StepState.active;
    if (s == TaskStatus.awaitingPM) return _StepState.done;
    return _StepState.pending;
  }

  static _StepState _pmState(Data task) {
    final s = task.effectiveStatus;
    if (task.isGenuinelyApproved) return _StepState.done;
    if (s == TaskStatus.pmRejected) return _StepState.rejected;
    if (s == TaskStatus.awaitingPM || s == TaskStatus.submitted)
      return _StepState.active;
    return _StepState.pending;
  }
}

enum _StepState { done, active, pending, rejected }

class _ChainStep {
  final String label;
  final String? sub;
  final _StepState state;
  const _ChainStep({required this.label, this.sub, required this.state});
}

class _ChainNode extends StatelessWidget {
  final _ChainStep step;
  const _ChainNode({required this.step});

  Color get _color {
    switch (step.state) {
      case _StepState.done:
        return Colors.green;
      case _StepState.active:
        return const Color(0xFFB54A3A);
      case _StepState.rejected:
        return Colors.red;
      case _StepState.pending:
        return const Color(0xFFCBC0BA);
    }
  }

  IconData get _icon {
    switch (step.state) {
      case _StepState.done:
        return Icons.check_rounded;
      case _StepState.active:
        return Icons.more_horiz_rounded;
      case _StepState.rejected:
        return Icons.close_rounded;
      case _StepState.pending:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: _color.withOpacity(
                step.state == _StepState.pending ? 0.10 : 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: _color, width: 1.4),
          ),
          child: Icon(_icon, size: 10.sp, color: _color),
        ),
        SizedBox(height: 3.h),
        Text(step.label,
            style: GoogleFonts.inter(
                fontSize: 8.sp, fontWeight: FontWeight.w700, color: _color)),
        if (step.sub != null && step.sub!.isNotEmpty)
          Text(
            step.sub!,
            style: GoogleFonts.inter(
                fontSize: 7.sp, color: const Color(0xFF8B7D77)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SMALL HELPERS
// ─────────────────────────────────────────────────────────────────────────

/// One shared style for every informational/status banner in the task
/// detail view (approved, rejected, waiting, reviewer prompt, delegated),
/// instead of a near-identical Container+Row+Icon block per case.
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final bool bold;
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.message,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, {this.color = const Color(0xFF6A3027)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REVIEW SECTION  — label + approve/reject row, shared by TL / Assigner /
// PM review blocks instead of each hand-rolling the same two widgets.
// ─────────────────────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  final String label;
  final Color labelColor;
  final String approveLabel;
  final IconData approveIcon;
  final Color approveColor;
  final Color rejectColor;
  final VoidCallback onApprove;
  final void Function(String remark) onReject;

  const _ReviewSection({
    required this.label,
    required this.labelColor,
    this.approveLabel = 'Approve',
    this.approveIcon = Icons.thumb_up_alt_rounded,
    required this.approveColor,
    required this.rejectColor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label, color: labelColor),
          SizedBox(height: 8.h),
          _ApproveRejectRow(
            approveLabel: approveLabel,
            approveIcon: approveIcon,
            approveColor: approveColor,
            rejectColor: rejectColor,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// APPROVE / REJECT ROW
// ─────────────────────────────────────────────────────────────────────────

class _ApproveRejectRow extends StatelessWidget {
  final String approveLabel;
  final IconData approveIcon;
  final Color approveColor;
  final Color rejectColor;
  final VoidCallback onApprove;
  final void Function(String remark) onReject;
  // context parameter removed — use build(context) instead to avoid
  // passing a potentially stale context from a parent widget.

  const _ApproveRejectRow({
    required this.approveLabel,
    required this.approveIcon,
    required this.approveColor,
    required this.rejectColor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onApprove,
            icon: Icon(approveIcon, size: 15.sp, color: Colors.white),
            label: Text(approveLabel,
                style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: approveColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 11.h),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final remark = await _showRejectDialog(context);
              if (remark != null) onReject(remark);
            },
            icon: Icon(Icons.cancel_outlined, size: 15.sp, color: rejectColor),
            label: Text('Reject',
                style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: rejectColor)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: rejectColor, width: 1.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(vertical: 11.h),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// META ROW
// ─────────────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B7D77))),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 11.sp, color: const Color(0xFF241917))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TASK FORM  — existing task is now Data
// ─────────────────────────────────────────────────────────────────────────

class _TaskForm extends StatefulWidget {
  final TaskController c;
  final Data? existing;          // ← Data, not old TaskModel
  final String? preselectedProjectId;
  final String? preselectedProjectName;
  const _TaskForm({
    required this.c,
    this.existing,
    this.preselectedProjectId,
    this.preselectedProjectName,
  });

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _startDate;
  late final TextEditingController _dueDate;
  late final TextEditingController _empSearch;

  List<String> _selectedEmployeeIds = [];
  String? _selectedJuniorId;
  String _priority = 'Medium';
  String _recurrence = 'None';
  DateTime _startDt = DateTime.now();
  DateTime? _dueDt;
  String? _projectId;
  String? _projectName;
  final List<Map<String, dynamic>> _attachments = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _dueDate = TextEditingController(text: e?.dueDate ?? '');
    _empSearch = TextEditingController();
    _priority = e?.priority ?? 'Medium';
    _recurrence = e?.recurrence ?? 'None';
    // Pre-fill assigned employee from Data.teamLeadId
    _selectedEmployeeIds =
        (e?.teamLeadId.isNotEmpty == true) ? [e!.teamLeadId] : [];
    _selectedJuniorId = e?.juniorId;
    _projectId = widget.preselectedProjectId ?? e?.sProjectId?.toString();
    _projectName = widget.preselectedProjectName ?? e?.projectName;

    _startDt = e?.startDate.isNotEmpty == true
        ? DateTime.tryParse(e!.startDate) ?? DateTime.now()
        : DateTime.now();
    _startDate = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(_startDt));
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _startDate.dispose();
    _dueDate.dispose();
    _empSearch.dispose();
    super.dispose();
  }

  // Future<void> _pickFiles() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
  //   );
  //   if (result == null) return;
  //   setState(() {
  //     for (final f in result.files) {
  //       if (f.path != null) {
  //         _attachments.add({
  //           'name': f.name,
  //           'path': f.path!,
  //           'type': f.extension?.toLowerCase() == 'pdf' ? 'pdf' : 'image',
  //         });
  //       }
  //     }
  //   });
  // }

  Future<void> _pickCamera() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;
    setState(() => _attachments.add({
          'name': picked.name,
          'path': picked.path,
          'type': 'image',
        }));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scroll) => Container(
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
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit ? 'Edit Task' : 'Assign New Task',
                    style: GoogleFonts.manrope(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF241917)),
                  ),
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
                  if (_isProjectManager || _isTeamLeader) ...[
                    _label('Link to Project'),
                    SizedBox(height: 6.h),
                    _projectDropdown(),
                    SizedBox(height: 14.h),
                  ],
                  _label('Select Employees'),
                  SizedBox(height: 6.h),
                  _employeeSelector(),
                  SizedBox(height: 14.h),
                  _label('Module / Task *'),
                  SizedBox(height: 6.h),
                  _field(_title, 'e.g. Review Q2 report'),
                  SizedBox(height: 14.h),
                  _label('Description'),
                  SizedBox(height: 6.h),
                  _field(_desc, 'Brief details…', maxLines: 3),
                  SizedBox(height: 14.h),
                  _label('Attachments (optional)'),
                  SizedBox(height: 6.h),
                  _attachmentSection(),
                  SizedBox(height: 14.h),
                  _label('Start Date'),
                  SizedBox(height: 6.h),
                  _datePicker(
                    ctrl: _startDate,
                    selected: _startDt,
                    hint: 'Select start date',
                    onPicked: (d) => setState(() {
                      _startDt = d;
                      _startDate.text = DateFormat('dd-MM-yyyy').format(d);
                    }),
                  ),
                  SizedBox(height: 14.h),
                  _label('Due Date'),
                  SizedBox(height: 6.h),
                  _datePicker(
                    ctrl: _dueDate,
                    selected: _dueDt,
                    hint: 'Select due date',
                    onPicked: (d) => setState(() {
                      _dueDt = d;
                      _dueDate.text = DateFormat('dd-MM-yyyy').format(d);
                    }),
                  ),
                  SizedBox(height: 14.h),
                  _label('Recurrence'),
                  SizedBox(height: 8.h),
                  _chips(
                    ['Daily', 'Weekly', 'Alternate', 'Monthly', 'None'],
                    _recurrence,
                    (v) => setState(() => _recurrence = v),
                  ),
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
                    },
                  ),
                  SizedBox(height: 28.h),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              widget.c.isSubmitting.value ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB54A3A),
                            disabledBackgroundColor:
                                const Color(0xFFB54A3A).withOpacity(0.5),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                            elevation: 0,
                          ),
                          child: widget.c.isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isEdit ? 'Save Changes' : 'Assign Task',
                                  style: GoogleFonts.manrope(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _employeeSelector() {
    final employees = widget.c.employees;
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => StatefulBuilder(
            builder: (ctx, setModal) {
              String search = _empSearch.text;
              return Obx(() {
                final emps = widget.c.employees;
                final isLoading = widget.c.isLoading.value;
                final filtered = emps
                    .where((e) => e.employeeName
                        .toLowerCase()
                        .contains(search.toLowerCase()))
                    .toList();

                if (isLoading && emps.isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1ED),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24.r)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                            color: Color(0xFF6A3027)),
                        SizedBox(height: 16.h),
                        Text('Loading employees…',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: const Color(0xFF241917))),
                      ],
                    ),
                  );
                }

                if (emps.isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1ED),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24.r)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 48.sp, color: const Color(0xFF8B7D77)),
                        SizedBox(height: 12.h),
                        Text('No employees loaded yet',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: const Color(0xFF8B7D77))),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () async => widget.c.fetchAll(),
                          icon: Icon(Icons.refresh_rounded,
                              size: 16.sp, color: Colors.white),
                          label: Text('Retry',
                              style: GoogleFonts.manrope(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB54A3A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F1ED),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
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
                      SizedBox(height: 14.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text('Select Employees',
                            style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF241917))),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextField(
                          controller: _empSearch,
                          onChanged: (v) {
                            search = v;
                            setModal(() {});
                          },
                          style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF241917)),
                          decoration: InputDecoration(
                            hintText: 'Search by name…',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF8B7D77)),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFF6A3027)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 11.h),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                  color: Color(0xFFB54A3A), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      const Divider(color: Color(0xFFE0D5D0), height: 1),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 16.w),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final emp = filtered[i];
                            final id = emp.employeeId.toString();
                            final sel = _selectedEmployeeIds.contains(id);
                            return ListTile(
                              onTap: () {
                                setModal(() {
                                  setState(() {
                                    sel
                                        ? _selectedEmployeeIds.remove(id)
                                        : _selectedEmployeeIds.add(id);
                                  });
                                });
                              },
                              leading: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: sel
                                      ? const Color(0xFFB54A3A)
                                      : const Color(0xFFE8DDD9),
                                ),
                                child: sel
                                    ? Icon(Icons.check,
                                        size: 14.sp, color: Colors.white)
                                    : null,
                              ),
                              title: Text(emp.employeeName,
                                  style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF241917))),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 4.w),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB54A3A),
                              padding:
                                  EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14.r)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Done (${_selectedEmployeeIds.length} selected)',
                              style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
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
        child: Row(
          children: [
            Icon(Icons.people_outline_rounded,
                size: 17.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 10.w),
            Expanded(
              child: _selectedEmployeeIds.isEmpty
                  ? Text(
                      employees.isEmpty
                          ? 'Loading employees…'
                          : 'Tap to select employees',
                      style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: const Color(0xFF8B7D77)),
                    )
                  : Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: _selectedEmployeeIds.map((id) {
                        final emp = employees.firstWhereOrNull(
                            (e) => e.employeeId.toString() == id);
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB54A3A).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: const Color(0xFFB54A3A)
                                    .withOpacity(0.35)),
                          ),
                          child: Text(
                            emp?.employeeName ?? id,
                            style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB54A3A)),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF6A3027)),
          ],
        ),
      ),
    );
  }

  Widget _projectDropdown() {
    // When a project was preselected (e.g. "Assign Task" from inside a
    // project card), show a clearly read-only banner instead of a
    // dropdown that looks tappable but silently ignores taps.
    final locked = widget.preselectedProjectId != null;
    if (locked) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EAE6),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0D5D0)),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 16.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                _projectName?.isNotEmpty == true
                    ? _projectName!
                    : 'Selected Project',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF241917)),
              ),
            ),
          ],
        ),
      );
    }

    if (!Get.isRegistered<ProjectController>()) Get.put(ProjectController());
    final pc = Get.find<ProjectController>();
    final isTL = _isTeamLeader;
    final projectOptions = <Map<String, String>>[];
    if (isTL) {
      final seen = <int>{};
      for (final p in pc.tlAllocateProjects) {
        if (p.sProjectId != 0 && seen.add(p.sProjectId)) {
          projectOptions.add({
            'id': p.sProjectId.toString(),
            'name': p.projectName,
          });
        }
      }
    } else {
      for (final p in pc.allProjects) {
        projectOptions.add(
            {'id': p.projectId.toString(), 'name': p.projectName});
      }
    }
    final selectedId = _projectId?.isEmpty == true ? null : _projectId;
    final seenIds = <String>{};

    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: null,
        child: Text('None (standalone task)',
            style: GoogleFonts.inter(fontSize: 13.sp)),
      ),
    ];

    for (final project in projectOptions) {
      final id = project['id'];
      if (id == null || id.isEmpty || seenIds.contains(id)) continue;
      seenIds.add(id);
      items.add(DropdownMenuItem<String>(
        value: id,
        child: Row(
          children: [
            Icon(Icons.folder_outlined,
                size: 14.sp, color: const Color(0xFF6A3027)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(project['name'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13.sp)),
            ),
          ],
        ),
      ));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0D5D0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          onChanged: (v) => setState(() {
            _projectId = v;
            if (v == null) {
              _projectName = null;
              return;
            }
            final sel =
                projectOptions.firstWhereOrNull((p) => p['id'] == v);
            _projectName = sel?['name'] ?? _projectName;
          }),
          hint: Text('None (standalone task)',
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: const Color(0xFF8B7D77))),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6A3027)),
          items: items,
        ),
      ),
    );
  }

  Widget _attachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _attachBtn(Icons.image_outlined, 'Photo / PDF',
                const Color(0xFF6A3027), _pickFiles),
            SizedBox(width: 10.w),
            _attachBtn(Icons.camera_alt_outlined, 'Camera',
                const Color(0xFFB54A3A), _pickCamera),
          ],
        ),
        if (_attachments.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _attachments.asMap().entries.map((e) {
              final i = e.key;
              final a = e.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE0D5D0)),
                    ),
                    child: a['type'] == 'image'
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(9.r),
                            child: Image.file(
                              File(a['path'] as String),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF8B7D77)),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  color: Colors.red.shade400, size: 28.sp),
                              SizedBox(height: 4.h),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text(a['name'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                        fontSize: 9.sp,
                                        color: const Color(0xFF241917))),
                              ),
                            ],
                          ),
                  ),
                  Positioned(
                    top: -6.h,
                    right: -6.w,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _attachments.removeAt(i)),
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Icon(Icons.close,
                            size: 11.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _attachBtn(
          IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      );

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

  Widget _datePicker({
    required TextEditingController ctrl,
    required Function(DateTime) onPicked,
    DateTime? selected,
    String hint = 'Select date',
  }) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(
            context: context,
            initialDate: selected ?? DateTime.now(),
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE0D5D0)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 17.sp, color: const Color(0xFF6A3027)),
              SizedBox(width: 10.w),
              Text(
                ctrl.text.isEmpty ? hint : ctrl.text,
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: ctrl.text.isEmpty
                        ? const Color(0xFF8B7D77)
                        : const Color(0xFF241917)),
              ),
            ],
          ),
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
      Get.snackbar('Missing Info',
          'Title and at least one employee are required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_isEdit) {
      // Use Data.uniqueId as the taskId for the update call
      widget.c.updateTask(widget.existing!.uniqueId, {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'start_date': _startDate.text,
        'due_date': _dueDate.text,
        'priority': _priority,
        'recurrence': _recurrence,
        'team_lead_ids': _selectedEmployeeIds.join(','),
        'junior_id': _selectedJuniorId,
        'project_id': _projectId,
        'project_name': _projectName,
      });
    } else {
      widget.c.assignTask(
        teamLeadId: _selectedEmployeeIds,
        juniorId: _selectedJuniorId,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        startDate: _startDate.text,
        dueDate: _dueDate.text,
        priority: _priority,
        recurrence: _recurrence,
        projectId: _projectId,
        projectName: _projectName,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PROJECT CARD  (PM → Projects tab) — unchanged, uses ProjectModel
// ─────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _anim;
  late final Animation<double> _rotate;
  late String _localStatus;

  static const _toggleMap = {
    'Active': 'Running',
    'Inactive': 'On Hold',
    'Done': 'Complete',
  };
  static const _reverseMap = {
    'Running': 'Active',
    'On Hold': 'Inactive',
    'Complete': 'Done',
  };

  @override
  void initState() {
    super.initState();
    _localStatus = widget.project.projectStatus;
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
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

  Color _statusColor(String s) {
    switch (s) {
      case 'Running':
        return Colors.green;
      case 'Complete':
        return Colors.blue;
      case 'On Hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _setStatus(String label) {
    final ns = _toggleMap[label]!;
    if (_localStatus == ns) return;
    setState(() => _localStatus = ns);
    if (!Get.isRegistered<ProjectController>()) Get.put(ProjectController());
    Get.find<ProjectController>()
        .updateProjectStatus(widget.project.projectId.toString(), ns);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final color = _statusColor(_localStatus);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18.r),
              bottom: Radius.circular(_expanded ? 0 : 18.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                        color: color,
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
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 12.sp, color: const Color(0xFF8B7D77)),
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
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20.r)),
                              child: Text(_localStatus,
                                  style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: color)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22.sp, color: const Color(0xFF6A3027)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ProjectExpandedBody(
              project: p,
              localStatus: _localStatus,
              onStatusChange: _setStatus,
              reverseMap: _reverseMap,
              statusColor: _statusColor,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PROJECT EXPANDED BODY
// ─────────────────────────────────────────────────────────────────────────

class _ProjectExpandedBody extends StatelessWidget {
  final ProjectModel project;
  final String localStatus;
  final void Function(String) onStatusChange;
  final Map<String, String> reverseMap;
  final Color Function(String) statusColor;

  const _ProjectExpandedBody({
    required this.project,
    required this.localStatus,
    required this.onStatusChange,
    required this.reverseMap,
    required this.statusColor,
  });

  ProjectController get _pc {
    if (!Get.isRegistered<ProjectController>()) Get.put(ProjectController());
    return Get.find<ProjectController>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
            color: const Color(0xFFF0E8E4),
            height: 1,
            indent: 14.w,
            endIndent: 14.w),
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(Icons.person_outline_rounded, 'Client', project.clientName),
              SizedBox(height: 8.h),
              _row(Icons.folder_outlined, 'Project', project.projectName),
              SizedBox(height: 8.h),
              if (project.assignedTo.isNotEmpty) ...[
                _row(Icons.assignment_ind_outlined, 'Assigned To',
                    project.assignedTo),
                SizedBox(height: 8.h),
              ],
              _row(Icons.info_outline_rounded, 'Status', localStatus),
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _row(Icons.description_outlined, 'Description',
                    project.description!),
              ],
              SizedBox(height: 14.h),
              Obx(() {
                final pc = _pc;
                final taskWorks = pc
                    .taskWorksByProject(project.projectId.toString());
                if (pc.isTaskWorksLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                          color: Color(0xFF6A3027), strokeWidth: 2),
                    ),
                  );
                }
                if (taskWorks.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work_outline_rounded,
                            size: 13.sp, color: const Color(0xFF6A3027)),
                        SizedBox(width: 6.w),
                        Text('Allocated Work (${taskWorks.length})',
                            style: GoogleFonts.manrope(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF241917))),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ...taskWorks.map((tw) => _TaskWorkTile(taskWork: tw)),
                  ],
                );
              }),
              SizedBox(height: 14.h),
              Text('Change Status',
                  style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8B7D77))),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _chip('Active', Colors.green),
                  SizedBox(width: 8.w),
                  _chip('Inactive', Colors.orange),
                  SizedBox(width: 8.w),
                  _chip('Done', Colors.blue),
                ],
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.find<TaskController>().switchTab(0);
                    Get.bottomSheet(
                      _TaskForm(
                        c: Get.find<TaskController>(),
                        preselectedProjectId:
                            project.projectId.toString(),
                        preselectedProjectName: project.projectName,
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  icon: Icon(Icons.add_task_rounded,
                      size: 16.sp, color: Colors.white),
                  label: Text(
                    localStatus == 'On Hold'
                        ? 'Reassign Task'
                        : 'Assign Task',
                    style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: localStatus == 'On Hold'
                        ? Colors.orange
                        : const Color(0xFFB54A3A),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    final current = reverseMap[localStatus] ?? '';
    final selected = current == label;
    return GestureDetector(
      onTap: () => onStatusChange(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: selected ? color : const Color(0xFFE0D5D0),
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                  color: selected ? color : color.withOpacity(0.4),
                  shape: BoxShape.circle),
            ),
            SizedBox(width: 5.w),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : const Color(0xFF8B7D77))),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF6A3027)),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B7D77)),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: const Color(0xFF241917)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────
// TL ALLOCATE PROJECT CARD  (MobProjectAllocateTL item)
// Mirrors PM's _ProjectCard: tap to expand, full detail + allocated work,
// and a locked "Assign Task" shortcut for this exact project.
// ─────────────────────────────────────────────────────────────────────────

class _TLAllocateProjectCard extends StatefulWidget {
  final TLAllocateProject project;
  final bool showAssignTask;
  const _TLAllocateProjectCard({required this.project, this.showAssignTask = true});

  @override
  State<_TLAllocateProjectCard> createState() =>
      _TLAllocateProjectCardState();
}

class _TLAllocateProjectCardState extends State<_TLAllocateProjectCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _anim;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
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

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final fmt = DateFormat('dd MMM yyyy');
    final dateLabel = p.assignDate != null ? fmt.format(p.assignDate!) : '—';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18.r),
              bottom: Radius.circular(_expanded ? 0 : 18.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                        color: const Color(0xFF6A3027),
                        borderRadius: BorderRadius.circular(4.r)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.projectName.isNotEmpty
                              ? p.projectName
                              : 'Unnamed Project',
                          style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF241917)),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 12.sp, color: const Color(0xFF8B7D77)),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                p.employeeName.isNotEmpty
                                    ? p.employeeName
                                    : '—',
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF241917)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 11.sp, color: const Color(0xFF8B7D77)),
                            SizedBox(width: 4.w),
                            Text(
                              dateLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF8B7D77)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22.sp, color: const Color(0xFF6A3027)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _TLAllocateProjectExpandedBody(
                project: p, showAssignTask: widget.showAssignTask),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TL ALLOCATE PROJECT — EXPANDED BODY
// ─────────────────────────────────────────────────────────────────────────

class _TLAllocateProjectExpandedBody extends StatelessWidget {
  final TLAllocateProject project;
  final bool showAssignTask;
  const _TLAllocateProjectExpandedBody(
      {required this.project, this.showAssignTask = true});

  ProjectController get _pc {
    if (!Get.isRegistered<ProjectController>()) Get.put(ProjectController());
    return Get.find<ProjectController>();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final dateLabel =
        project.assignDate != null ? fmt.format(project.assignDate!) : '—';

    return Column(
      children: [
        Divider(
            color: const Color(0xFFF0E8E4),
            height: 1,
            indent: 14.w,
            endIndent: 14.w),
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(Icons.folder_outlined, 'Project',
                  project.projectName.isNotEmpty
                      ? project.projectName
                      : 'Unnamed Project'),
              SizedBox(height: 8.h),
              _row(Icons.person_outline_rounded, 'Assigned To',
                  project.employeeName.isNotEmpty
                      ? project.employeeName
                      : '—'),
              SizedBox(height: 8.h),
              _row(Icons.assignment_ind_outlined, 'Assigned By',
                  project.assignBy.isNotEmpty ? project.assignBy : '—'),
              SizedBox(height: 8.h),
              _row(Icons.calendar_today_outlined, 'Assigned On', dateLabel),
              SizedBox(height: 14.h),
              Obx(() {
                final pc = _pc;
                final taskWorks =
                    pc.taskWorksByProject(project.sProjectId.toString());
                if (pc.isTaskWorksLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                          color: Color(0xFF6A3027), strokeWidth: 2),
                    ),
                  );
                }
                if (taskWorks.isEmpty) {
                  return Text(
                    'No task details available yet for this project.',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: const Color(0xFF8B7D77)),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work_outline_rounded,
                            size: 13.sp, color: const Color(0xFF6A3027)),
                        SizedBox(width: 6.w),
                        Text('Allocated Work (${taskWorks.length})',
                            style: GoogleFonts.manrope(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF241917))),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ...taskWorks.map((tw) => _TaskWorkTile(taskWork: tw)),
                  ],
                );
              }),
              if (showAssignTask) ...[
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.find<TaskController>().switchTab(0);
                      Get.bottomSheet(
                        _TaskForm(
                          c: Get.find<TaskController>(),
                          preselectedProjectId: project.sProjectId.toString(),
                          preselectedProjectName: project.projectName,
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    icon: Icon(Icons.add_task_rounded,
                        size: 16.sp, color: Colors.white),
                    label: Text(
                      'Assign Task',
                      style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB54A3A),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF6A3027)),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B7D77)),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: const Color(0xFF241917)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────
// REGULAR EMPLOYEE — PROJECT STATS CARD
// ─────────────────────────────────────────────────────────────────────────

class _RegularProjectStatsCard extends StatelessWidget {
  final ProjectController pc;
  const _RegularProjectStatsCard({required this.pc});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Trigger fetch if not yet loaded and not already loading
      if (pc.tlAllocateProjects.isEmpty && !pc.isAllocateLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pc.tlAllocateProjects.isEmpty && !pc.isAllocateLoading.value) {
            pc.fetchTLAllocateProjects();
          }
        });
      }
      final isLoading = pc.isAllocateLoading.value;
      final projects  = pc.tlAllocateProjects;
      final total     = projects.length;
      final uniqueNames = projects.map((p) => p.sProjectId).toSet().length;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 7))
          ],
        ),
        child: isLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Color(0xFF6A3027), strokeWidth: 2),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statTile('Assigned', '$total', Icons.folder_outlined,
                      const Color(0xFF6A3027)),
                  Container(
                      height: 38.h, width: 1, color: const Color(0xFFE8DDD9)),
                  _statTile('Projects', '$uniqueNames',
                      Icons.work_outline_rounded, Colors.blue),
                ],
              ),
      );
    });
  }

  Widget _statTile(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: color),
        SizedBox(height: 5.h),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917))),
        SizedBox(height: 2.h),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B7D77))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REGULAR EMPLOYEE — PROJECT LIST
// ─────────────────────────────────────────────────────────────────────────

class _RegularProjectList extends StatelessWidget {
  final ProjectController pc;
  const _RegularProjectList({required this.pc});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (pc.isAllocateLoading.value && pc.tlAllocateProjects.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6A3027)));
      }
      final projects = pc.filteredTLAllocateProjects;
      if (projects.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_outlined,
                  size: 58.sp, color: const Color(0xFF8B7D77)),
              SizedBox(height: 12.h),
              Text('No projects assigned to you',
                  style: GoogleFonts.manrope(
                      fontSize: 15.sp, color: const Color(0xFF8B7D77))),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => pc.fetchTLAllocateProjects(),
                icon: Icon(Icons.refresh_rounded,
                    size: 16.sp, color: Colors.white),
                label: Text('Refresh',
                    style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB54A3A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: projects.length,
        itemBuilder: (_, i) => _TLAllocateProjectCard(
            project: projects[i], showAssignTask: false),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TASK WORK TILE — unchanged, uses ProjectTaskWork
// ─────────────────────────────────────────────────────────────────────────

class _TaskWorkTile extends StatelessWidget {
  final ProjectTaskWork taskWork;
  const _TaskWorkTile({required this.taskWork});

  Color get _statusColor {
    switch (taskWork.aStatus) {
      case 'Done':
      case 'Complete':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final dueLabel = taskWork.deliveryEstimateDate != null
        ? fmt.format(taskWork.deliveryEstimateDate!)
        : '—';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1ED),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
            color: taskWork.isOverdue
                ? Colors.red.shade200
                : const Color(0xFFE0D5D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  taskWork.taskTittle?.isNotEmpty == true
                      ? taskWork.taskTittle!
                      : taskWork.proDescription ?? 'No title',
                  style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF241917)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text(taskWork.aStatus,
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: _statusColor)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 12.sp, color: const Color(0xFF6A3027)),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  [
                    if (taskWork.employeeName.isNotEmpty)
                      taskWork.employeeName,
                    if (taskWork.employeeName1.isNotEmpty)
                      taskWork.employeeName1,
                  ].join(' → '),
                  style: GoogleFonts.inter(
                      fontSize: 11.sp, color: const Color(0xFF241917)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 11.sp, color: const Color(0xFF8B7D77)),
              SizedBox(width: 4.w),
              Text('Due: $dueLabel',
                  style: GoogleFonts.inter(
                      fontSize: 11.sp, color: const Color(0xFF8B7D77))),
              if (taskWork.isOverdue) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Text('Overdue',
                      style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.red)),
                ),
              ],
              if (taskWork.priority != null) ...[
                const Spacer(),
                Text(
                  taskWork.priority!,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: taskWork.priority == 'High'
                        ? Colors.red
                        : taskWork.priority == 'Low'
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
