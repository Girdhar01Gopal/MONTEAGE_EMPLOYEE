import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_history_controller.dart';
import '../models/attendance_history_model.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AttendanceHistoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        actions: [
          IconButton(
            onPressed: c.fetchHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => InkWell(
                    onTap: c.pickFromDate,
                    child: _dateBox("From Date", c.fromDate.value),
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => InkWell(
                    onTap: c.pickToDate,
                    child: _dateBox("To Date", c.toDate.value),
                  )),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: c.list.length,
                itemBuilder: (_, i) {
                  final AttendanceHistoryItem item = c.list[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(item.date.isEmpty ? "--" : item.date),
                      subtitle: Text(item.status.isEmpty ? "--" : item.status),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openDetails(item),
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

  Widget _dateBox(String label, DateTime? date) {
    final text = (date == null)
        ? label
        : date.toIso8601String().split("T").first; // YYYY-MM-DD

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openDetails(AttendanceHistoryItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv("Date", item.date),
            _kv("Status", item.status),
            _kv("Check In", item.checkIn),
            _kv("Check Out", item.checkOut),
            _kv("Address", item.address),
            _kv("Latitude", item.latitude),
            _kv("Longitude", item.longitude),
            _kv("Remarks", item.remarks),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(v.isEmpty ? "--" : v)),
        ],
      ),
    );
  }
}
