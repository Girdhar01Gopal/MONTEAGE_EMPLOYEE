/*import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/attendance_history_controller.dart';
import '../models/attendance_history_model.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceHistoryController());

    return Scaffold(
      backgroundColor: Colors.white,  // Set screen background color to white
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Attendance History",
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Set back arrow color to white
          ),
          onPressed: () {
            // Add your back button functionality here
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: c.fetchHistory,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),

      body: Column(
        children: [
          /// ---------------- STATISTICS BAR ----------------
          Obx(() {
            final s = c.statistics.value;
            if (s == null) return const SizedBox();

            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat("Total", s.total),
                  _stat("Verified", s.verified),
                  _stat("Pending", s.pending),
                  _stat("Rejected", s.rejected),
                ],
              ),
            );
          }),

          /// ---------------- LIST ----------------
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.records.isEmpty) {
                return const Center(child: Text("No attendance history"));
              }

              return ListView.builder(
                itemCount: c.records.length,
                itemBuilder: (_, i) {
                  final Result r = c.records[i];
                  return _HistoryCard(r, c);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  static Widget _stat(String title, int? value) {
    return Column(
      children: [
        Text(
          value?.toString() ?? "0",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Result r;
  final AttendanceHistoryController c;
  const _HistoryCard(this.r, this.c);

  Color _statusColor(String? s) {
    switch (s?.toUpperCase()) {
      case "VERIFIED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(r.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DATE + STATUS
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${c.formatDate(r.date)} • ${c.formatTime(r.timestamp)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: statusColor.withOpacity(0.15),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    r.status ?? "--",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text("Name: ${r.employeeName ?? "--"}"),
            Text("Employee ID: ${r.employeeId ?? "--"}"),
            Text("Username: ${r.username ?? "--"}"),
            Text("Department: ${r.department ?? "--"}"),
            Text("Confidence: ${(r.confidenceScore ?? 0).toStringAsFixed(3)}"),
            Text("Face Detected: ${r.faceDetected == true ? "Yes" : "No"}"),
            Text("Verified: ${r.isVerified == true ? "Yes" : "No"}"),

            const SizedBox(height: 6),

            Text(
              "Lat: ${r.latitude ?? 0}, Lng: ${r.longitude ?? 0} | Accuracy: ${r.locationAccuracy ?? 0}m",
            ),

            if (r.isSuspicious == true) ...[
              const SizedBox(height: 6),
              Text(
                "Suspicious: ${r.suspiciousReason ?? "Yes"}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


String _time(String? iso) {
    if (iso == null || iso.isEmpty) return "--";
    try {
      final d = DateTime.parse(iso).toLocal();
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return "$hh:$mm";
    } catch (_) {
      return "--";
    }
  }*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_history_controller.dart';
import '../models/attendance_history_model.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceHistoryController());

    return Scaffold(
      backgroundColor: Colors.white, // Set screen background color to white
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          "Attendance History",
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Set back arrow color to white
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: c.fetchHistory,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),

      body: Column(
        children: [
          // ---------------- STATISTICS BAR ----------------
          Obx(() {
            final s = c.statistics.value;
            if (s == null) return const SizedBox();

            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("Total", s.total),
                  _stat("Verified", s.verified),
                  _stat("Rejected", s.rejected),
                  _pendingStatus(s.pending),
                ],
              ),
            );
          }),

          // ---------------- LIST ----------------
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.records.isEmpty) {
                return const Center(child: Text("No attendance history"));
              }

              return ListView.builder(
                itemCount: c.records.length,
                itemBuilder: (_, i) {
                  final Result r = c.records[i];
                  return _HistoryCard(r); // Card UI for each record
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Helper widget to display the stats in card format
  static Widget _stat(String title, int? value) {
    return Column(
      children: [
        Text(
          value?.toString() ?? "0",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // Helper widget for Pending Status
  static Widget _pendingStatus(int? pending) {
    return Column(
      children: [
        Text(
          pending?.toString() ?? "0",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Pending",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Result r;
  const _HistoryCard(this.r);

  Color _statusColor(String? s) {
    switch (s?.toUpperCase()) {
      case "VERIFIED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formattedDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";
    } catch (_) {
      return "--";
    }
  }

  String _formattedTime(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final hour = d.hour > 12 ? d.hour - 12 : d.hour;
      final period = d.hour >= 12 ? 'PM' : 'AM';
      return "${hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $period";
    } catch (_) {
      return "--";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(r.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Header ----------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF5A52E0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formattedDate(r.date), // Formatted date
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formattedTime(r.timestamp), // Formatted time with AM/PM
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ---------------- Verified Status ----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                r.status ?? "--",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ---------------- Employee Information ----------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${r.employeeName ?? "--"}"),
                Text("Username: ${r.username ?? "--"}"),
                Text("Employee ID: ${r.employeeId ?? "--"}"),
               // Text("Department: ${r.department ?? "--"}"),
                Text("Confidence: ${(r.confidenceScore ?? 0).toStringAsFixed(3)}"),
                Text("Face Detected: ${r.faceDetected == true ? "Yes" : "No"}"),
              ],
            ),
            const SizedBox(height: 12),

            // ---------------- Location ----------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${r.latitude ?? 0}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          'Lng: ${r.longitude ?? 0}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          'Accuracy: ${r.locationAccuracy ?? 0}m',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (r.isSuspicious == true) ...[
              const SizedBox(height: 6),
              Text(
                "Suspicious: ${r.suspiciousReason ?? "Yes"}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _time(String? iso) {
  if (iso == null || iso.isEmpty) return "--";
  try {
    final d = DateTime.parse(iso).toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  } catch (_) {
    return "--";
  }
}
