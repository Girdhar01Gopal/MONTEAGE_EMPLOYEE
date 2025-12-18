// lib/screens/attendance_history_screen.dart

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
      appBar: AppBar(
        title: const Text("Attendance History"),
        actions: [
          IconButton(
            onPressed: c.fetchHistory,
            icon: const Icon(Icons.refresh, color: Colors.green),
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
                  final Results r = c.records[i];
                  return _HistoryCard(r);
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

/// =======================================================
/// HISTORY CARD
/// =======================================================

class _HistoryCard extends StatelessWidget {
  final Results r;
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
                    "${r.date ?? "--"} • ${_time(r.timestamp)}",
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

            Text("Name: ${r.userName ?? "--"}"),
            Text("Employee ID: ${r.employeeId ?? "--"}"),

            const SizedBox(height: 6),

            Text(
              "Confidence: ${(r.confidenceScore ?? 0).toStringAsFixed(3)}",
            ),
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
}
