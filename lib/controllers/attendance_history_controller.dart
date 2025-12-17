import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_history_model.dart';

class AttendanceHistoryController extends GetxController {
  final box = GetStorage();
  final String apiUrl = "http://115.241.73.226/attendance/api/attendance/history/";

  final isLoading = false.obs;
  final RxList<AttendanceHistory> list = <AttendanceHistory>[].obs;

  // Date filters
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

  // Fetch attendance history from API
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

        final List data = decoded['results'] ?? [];

        // Only populate the list with actual API data
        list.assignAll(
          data.whereType<Map<String, dynamic>>().map(
                (e) => AttendanceHistory.fromJson(e),
          ),
        );
      } else {
        // Handle error response, you can display an error message if necessary
        Get.snackbar("Error", "Failed to fetch attendance history",
            snackPosition: SnackPosition.TOP);
      }
    } catch (_) {
      // Handle error when API call fails
      Get.snackbar("Error", "An error occurred while fetching data",
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // Date picker for "From Date"
  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
      fetchHistory();
    }
  }

  // Date picker for "To Date"
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

  // Clear date filters
  void clearDates() {
    fromDate.value = null;
    toDate.value = null;
    fetchHistory();
  }
}
