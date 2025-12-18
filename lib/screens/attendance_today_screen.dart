import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_today_controller.dart';
import '../models/attendance_today.dart';

class AttendanceTodayScreen extends StatelessWidget {
  const AttendanceTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AttendanceTodayController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Attendance"),
        actions: [
          IconButton(
            onPressed: c.fetchToday,
            icon: const Icon(Icons.refresh, color: Colors.green),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final AttendanceToday? data = c.today.value;
        if (data == null) {
          return const Center(child: Text("Attendance not marked today"));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _TodayAttendanceCard(data),
          ],
        );
      }),
    );
  }
}

/// =======================================================
/// SMALL COMPACT CARD (HISTORY STYLE)
/// =======================================================

class _TodayAttendanceCard extends StatelessWidget {
  final AttendanceToday data;
  const _TodayAttendanceCard(this.data);

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
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
    final statusColor = _statusColor(data.status);

    return Card(
      elevation: 2, // 🔹 small elevation
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 ROW 1: DATE + TIME + STATUS
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${_ddMMyyyy(data.timestamp)} • ${_timeHHmm(data.timestamp)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Marked: ${data.marked ? "Yes" : "No"}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  "Verified: ${data.isVerified ? "Yes" : "No"}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: data.isVerified ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// 🔹 ROW 3: CONFIDENCE
            Text(
              "Confidence: ${data.confidenceScore.toStringAsFixed(3)}",
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 6),

            /// 🔹 ROW 4: LOCATION
            Text(
              "Lat: ${data.location.latitude}, Lng: ${data.location.longitude}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 2025-12-18T06:01:50+00:00 → 18-12-2025
  String _ddMMyyyy(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";
    } catch (_) {
      return "--";
    }
  }

  /// → 06:01
  String _timeHHmm(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return "${d.hour.toString().padLeft(2, '0')}:"
          "${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "--";
    }
  }
}
