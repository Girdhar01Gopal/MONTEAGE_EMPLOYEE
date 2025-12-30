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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Today Attendance",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: c.fetchToday,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading attendance...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          );
        }

        final AttendanceToday? data = c.today.value;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No attendance marked today",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mark your attendance to see details",
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ Image/CircleAvatar removed as requested
                _TodayAttendanceCard(data, c),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TodayAttendanceCard extends StatelessWidget {
  final AttendanceToday data;
  final AttendanceTodayController c;
  const _TodayAttendanceCard(this.data, this.c);

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "VERIFIED":
        return const Color(0xFF10B981);
      case "REJECTED":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case "VERIFIED":
        return Icons.check_circle_rounded;
      case "REJECTED":
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(data.status);
    final statusIcon = _statusIcon(data.status);

    final lat = data.location.latitude;
    final lng = data.location.longitude;
    final acc = data.location.accuracy;

    final address = c.cleanAddress(data.location.address);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
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
                    child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ddMMyyyy(data.timestamp),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timeAmPm(data.timestamp),
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          data.status,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Marked',
                    value: data.marked ? 'Yes' : 'No',
                    valueColor: data.marked ? const Color(0xFF10B981) : Colors.grey[600]!,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.verified_outlined,
                    label: 'Verified',
                    value: data.isVerified ? 'Yes' : 'No',
                    valueColor: data.isVerified ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),

                  // Confidence
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology_rounded, size: 20, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Confidence Score',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: data.confidenceScore,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    data.confidenceScore > 0.7
                                        ? const Color(0xFF10B981)
                                        : data.confidenceScore > 0.4
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(data.confidenceScore * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: data.confidenceScore > 0.7
                                    ? const Color(0xFF10B981)
                                    : data.confidenceScore > 0.4
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location + Address
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
                          child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                              ),
                              const SizedBox(height: 6),
                              Text(address, style: TextStyle(fontSize: 13, color: Colors.blue[800])),
                              const SizedBox(height: 6),
                              Text('Lat: ${lat == null ? "--" : lat.toStringAsFixed(6)}',
                                  style: TextStyle(fontSize: 13, color: Colors.blue[800])),
                              Text('Lng: ${lng == null ? "--" : lng.toStringAsFixed(6)}',
                                  style: TextStyle(fontSize: 13, color: Colors.blue[800])),
                              Text('Accuracy: ${acc == null ? "--" : acc.toStringAsFixed(0)} m',
                                  style: TextStyle(fontSize: 13, color: Colors.blue[800])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Face Analysis
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.face_retouching_natural, size: 20, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              "Face Analysis",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text("Quality Score: ${data.faceAnalysis.qualityScore.toStringAsFixed(2)}"),
                        Text("Landmarks Detected: ${data.faceAnalysis.landmarksDetected}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ddMMyyyy(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    } catch (_) {
      return "--";
    }
  }

  String _timeAmPm(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final ampm = d.hour >= 12 ? "PM" : "AM";
      return "${hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) {
      return "--";
    }
  }
}

// Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: valueColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
        ),
      ],
    );
  }
}
