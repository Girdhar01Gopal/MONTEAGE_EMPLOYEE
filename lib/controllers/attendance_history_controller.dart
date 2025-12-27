import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for date formatting
import '../models/attendance_history_model.dart';
import '../screens/login_screen.dart';

class AttendanceHistoryController extends GetxController {
  final box = GetStorage();

  final String historyApi =
      "http://103.251.143.196/attendance/api/attendance/history/";
  final String refreshApi =
      "http://103.251.143.196/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<Statistics> statistics = Rxn<Statistics>();
  final RxList<Result> records = <Result>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  String get _accessToken =>
      (box.read("access_token") ?? "").toString().trim();

  String get _refreshToken =>
      (box.read("refresh_token") ?? "").toString().trim();

  /// ---------------- FETCH HISTORY ----------------
  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final res = await _authorizedGet(Uri.parse(historyApi));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final data = AttendanceResponse.fromJson(decoded);

        statistics.value = data.statistics;
        records.assignAll(data.results);
        return;
      }

      if (res.statusCode == 401) {
        _forceLogout();
        return;
      }

      Get.snackbar(
        "Error",
        "Failed to load attendance history (HTTP ${res.statusCode})",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- AUTH GET WITH AUTO REFRESH ----------------
  Future<http.Response> _authorizedGet(Uri uri) async {
    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $_accessToken",
        "Accept": "application/json",
      },
    );

    if (res.statusCode != 401) return res;

    final refreshed = await _refreshAccessToken();
    if (!refreshed) return res;

    return http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${box.read("access_token")}",
        "Accept": "application/json",
      },
    );
  }

  /// ---------------- REFRESH TOKEN ----------------
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken.isEmpty) return false;

    final res = await http.post(
      Uri.parse(refreshApi),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"refresh": _refreshToken}),
    );

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(res.body);
    final newAccess = decoded['access']?.toString() ?? "";

    if (newAccess.isEmpty) return false;

    await box.write("access_token", newAccess);
    return true;
  }

  /// ---------------- FORCE LOGOUT ----------------
  void _forceLogout() {
    box.erase();
    Get.offAll(() => const LoginScreen());

    Get.snackbar(
      "Session Expired",
      "Please login again",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// ---------------- DATE FORMATTERS ----------------
  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd-MM-yyyy').format(parsedDate); // Format as dd-MM-yyyy
    } catch (e) {
      return date; // In case of an error, return original date
    }
  }

  String formatTime(String time) {
    try {
      final parsedDate = DateTime.parse(time).toLocal();
      return DateFormat('hh:mm a').format(parsedDate); // Format as hh:mm AM/PM
    } catch (e) {
      return time; // In case of an error, return original time
    }
  }
}
