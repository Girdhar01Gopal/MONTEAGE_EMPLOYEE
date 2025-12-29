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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          "Attendance History",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // ✅ Search icon (dd-MM-yyyy)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Search by Date"),
                  content: TextField(
                    controller: c.searchDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      hintText: "dd-MM-yyyy",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        c.clearFilter();
                        Get.back();
                      },
                      child: const Text("Clear"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        c.applyDateFilter(c.searchDateController.text.trim());
                        Get.back();
                      },
                      child: const Text("Search"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // -------- Statistics --------
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
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("Total", s.total),
                  _stat("Verified", s.verified),
                  _stat("Rejected", s.rejected),
                  _pendingStat(s.pending),
                ],
              ),
            );
          }),

          // -------- List --------
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // ✅ use filteredRecords (search result)
              if (c.filteredRecords.isEmpty) {
                return const Center(child: Text("No attendance history"));
              }

              return RefreshIndicator(
                onRefresh: c.fetchHistory,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: c.filteredRecords.length,
                  itemBuilder: (_, i) =>
                      _HistoryCard(record: c.filteredRecords[i], c: c),
                ),
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
          (value ?? 0).toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  static Widget _pendingStat(int? value) {
    return Column(
      children: [
        Text(
          (value ?? 0).toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        const Text("Pending", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Result record;
  final AttendanceHistoryController c;

  const _HistoryCard({required this.record, required this.c});

  Color _statusColor(String? s) {
    switch ((s ?? "").toUpperCase()) {
      case "VERIFIED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      case "PENDING":
      default:
        return Colors.orange;
    }
  }

  Widget _kv(String k, String v, {Color? vColor, FontWeight? vWeight}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                color: vColor ?? Colors.black87,
                fontWeight: vWeight ?? FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBlock(String title, String? url) {
    final full = c.fullImageUrl(url);
    if (full.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              full,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Text("Image not available"),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkInColor = _statusColor(record.status);
    final checkOutColor = _statusColor(record.checkoutStatus);

    final checkInTime = c.formatIsoTime(record.timestamp);
    final checkOutTime = c.formatIsoTime(record.checkoutTimestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${c.titleCase(record.employeeName)} (${record.employeeId})",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: checkInColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: checkInColor),
                  ),
                  child: Text(
                    record.status,
                    style: TextStyle(
                      color: checkInColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),

            // ✅ Username first letter capital + date dd-MM-yyyy
            _kv("Username", c.titleCase(record.username)),
            _kv("Check-in Date", c.formatToDdMmYyyy(record.date)),
            _kv("Check-in Time", checkInTime),
            _kv("Confidence", record.confidenceScore.toStringAsFixed(3)),
            _kv("Face Detected", record.faceDetected ? "Yes" : "No"),
            _kv("Verified", record.isVerified ? "Yes" : "No"),

            const Divider(height: 20),

            // Location (Check-in)
            const Text("Check-in Location",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _kv("Latitude", (record.latitude ?? 0).toString()),
            _kv("Longitude", (record.longitude ?? 0).toString()),
            _kv("Accuracy (m)", (record.locationAccuracy ?? 0).toString()),
            _imageBlock("Check-in Image", record.imageUrl),

            const Divider(height: 22),

            // Checkout Section
            Row(
              children: [
                const Expanded(
                  child: Text("Check-out Details",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: checkOutColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: checkOutColor),
                  ),
                  child: Text(
                    (record.checkoutStatus ?? "--"),
                    style: TextStyle(
                      color: checkOutColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),

            _kv("Checkout Date", c.formatToDdMmYyyy(record.checkoutDate)),
            _kv("Checkout Time", checkOutTime),
            _kv(
              "Checkout Confidence",
              record.checkoutConfidenceScore == null
                  ? "--"
                  : record.checkoutConfidenceScore!.toStringAsFixed(3),
            ),

            const SizedBox(height: 10),
            const Text("Check-out Location",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _kv("Latitude", (record.checkoutLatitude ?? 0).toString()),
            _kv("Longitude", (record.checkoutLongitude ?? 0).toString()),
            _kv("Accuracy (m)", (record.checkoutLocationAccuracy ?? 0).toString()),
            _imageBlock("Check-out Image", record.checkoutImageUrl),

            const Divider(height: 22),

            // Duration
            _kv("Duration", record.duration?.formatted ?? "--",
                vWeight: FontWeight.bold),
            _kv("Total Seconds", record.duration?.seconds.toString() ?? "--"),

            // Suspicious
            if (record.isSuspicious) ...[
              const SizedBox(height: 8),
              Text(
                "Suspicious: ${record.suspiciousReason ?? "Yes"}",
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],

            const Divider(height: 22),

            // ✅ Created/Updated in dd-MM-yyyy hh:mm a (India local)
            _kv("Created At", c.formatIsoDateTime(record.createdAt)),
            _kv("Updated At", c.formatIsoDateTime(record.updatedAt)),
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
