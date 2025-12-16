import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceRecord {
  final DateTime date;
  final String inTime;
  final String outTime;
  final String late;   // "HH:MM"
  final String work;   // "HH:MM"
  final String status; // "A", "P", "WO"

  AttendanceRecord({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.late,
    required this.work,
    required this.status,
  });
}

class Employee {
  final int id;
  final String name;

  Employee({required this.id, required this.name});
}

enum AttendanceTab { list, statistical }

class AttendanceController extends GetxController {
  // Filters
  final Rx<DateTime> fromDate = DateTime(2024, 9, 13).obs;
  final Rx<DateTime> toDate = DateTime(2024, 9, 20).obs;
  final Rxn<Employee> selectedEmployee = Rxn<Employee>();

  // Data
  final RxList<Employee> employees = <Employee>[].obs;
  final RxList<AttendanceRecord> records = <AttendanceRecord>[].obs;

  // UI state
  final RxBool isLoading = false.obs;
  final Rx<AttendanceTab> selectedTab = AttendanceTab.list.obs;

  // ======= STATISTICS =======
  int get totalDays => records.length;

  int get presentDays =>
      records.where((r) => r.status.toUpperCase() == 'P').length;

  int get absentDays =>
      records.where((r) => r.status.toUpperCase() == 'A').length;

  int get weeklyOffDays =>
      records.where((r) => r.status.toUpperCase() == 'WO').length;

  // Late in minutes from "HH:MM"
  int get totalLateMinutes => records.fold(0, (sum, r) {
    final parts = r.late.split(':');
    if (parts.length != 2) return sum;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return sum + h * 60 + m;
  });

  // Work minutes from "HH:MM"
  int get totalWorkMinutes => records.fold(0, (sum, r) {
    final parts = r.work.split(':');
    if (parts.length != 2) return sum;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return sum + h * 60 + m;
  });

  String get totalLateHrsStr => _minutesToHHMM(totalLateMinutes);
  String get totalWorkHrsStr => _minutesToHHMM(totalWorkMinutes);

  String _minutesToHHMM(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void onInit() {
    super.onInit();
    _loadEmployees();
    loadAttendance(); // initial load with dummy data
  }

  void _loadEmployees() {
    // TODO: Replace with API
    employees.assignAll([
      Employee(id: 1, name: 'AADITYA RAMLAL'),
      Employee(id: 2, name: 'RAHUL SHARMA'),
      Employee(id: 3, name: 'NEHA GUPTA'),
    ]);
    if (selectedEmployee.value == null && employees.isNotEmpty) {
      selectedEmployee.value = employees.first;
    }
  }

  void changeTab(AttendanceTab tab) {
    selectedTab.value = tab;
  }

  void updateFromDate(DateTime date) {
    fromDate.value = date;
  }

  void updateToDate(DateTime date) {
    toDate.value = date;
  }

  void updateEmployee(Employee? emp) {
    selectedEmployee.value = emp;
  }

  Future<void> loadAttendance() async {
    if (selectedEmployee.value == null) return;
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 400));

    // 🔹 Dummy data matching your screenshot style (13–20 Sept 2024)
    final all = <AttendanceRecord>[
      AttendanceRecord(
        date: DateTime(2024, 9, 20),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'A',
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 19),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'A',
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 18),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'A',
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 17),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'A',
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 16),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'A',
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 15),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'WO', // weekly off like screenshot
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 14),
        inTime: '-',
        outTime: '-',
        late: '00:00',
        work: '00:00',
        status: 'A',
      ),
      AttendanceRecord(
        date: DateTime(2024, 9, 13),
        inTime: '09:45',
        outTime: '18:05',
        late: '00:15',
        work: '08:20',
        status: 'P',
      ),
    ];

    // Filter by selected range
    records.assignAll(
      all.where((r) =>
      !r.date.isBefore(fromDate.value) &&
          !r.date.isAfter(toDate.value)),
    );

    isLoading.value = false;
  }

  String formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }
}
