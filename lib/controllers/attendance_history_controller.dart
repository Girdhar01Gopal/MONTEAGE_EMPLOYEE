import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_history_model.dart';

class AttendanceHistoryController extends GetxController {
  final box = GetStorage();

  final String apiUrl =
      "http://115.241.73.226/attendance/api/attendance/history/";

  final isLoading = false.obs;
  final RxList<AttendanceHistoryItem> list = <AttendanceHistoryItem>[].obs;

  // ✅ Correct type
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  String _token() {
    final t = (box.read("access_token") ?? "").toString().trim();
    if (t.isEmpty) throw Exception("Access token missing in GetStorage('access_token')");
    return t;
  }

  String _fmt(DateTime d) => d.toIso8601String().split("T").first; // YYYY-MM-DD

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;

      final qp = <String, String>{};
      if (fromDate.value != null) qp["from"] = _fmt(fromDate.value!);
      if (toDate.value != null) qp["to"] = _fmt(toDate.value!);

      final uri = Uri.parse(apiUrl).replace(queryParameters: qp);

      final res = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer ${_token()}",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        final List data = decoded is List
            ? decoded
            : (decoded["data"] ?? decoded["results"] ?? []);

        if (data.isEmpty) {
          _loadDummyData();
        } else {
          list.assignAll(
            data.whereType<Map<String, dynamic>>().map(
                  (e) => AttendanceHistoryItem.fromJson(e),
            ),
          );
        }
      } else {
        _loadDummyData();
      }
    } catch (_) {
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyData() {
    list.assignAll([
      AttendanceHistoryItem(
        date: "2025-01-10",
        status: "Present",
        checkIn: "09:05 AM",
        checkOut: "06:10 PM",
        address: "Noida Sector 62, UP",
        latitude: "28.6280",
        longitude: "77.3649",
        remarks: "On time",
      ),
      AttendanceHistoryItem(
        date: "2025-01-09",
        status: "Late",
        checkIn: "09:45 AM",
        checkOut: "06:00 PM",
        address: "Noida Sector 62, UP",
        latitude: "28.6280",
        longitude: "77.3649",
        remarks: "Traffic issue",
      ),
      AttendanceHistoryItem(
        date: "2025-01-08",
        status: "Absent",
        checkIn: "--",
        checkOut: "--",
        address: "--",
        latitude: "--",
        longitude: "--",
        remarks: "Leave",
      ),
    ]);
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      // if toDate is before fromDate, reset it (clean UX)
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
      fetchHistory();
    }
  }

  Future<void> pickToDate() async {
    final base = fromDate.value ?? DateTime(2023);
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: toDate.value ?? DateTime.now(),
      firstDate: base,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      toDate.value = picked;
      fetchHistory();
    }
  }

  void clearDates() {
    fromDate.value = null;
    toDate.value = null;
    fetchHistory();
  }
}
