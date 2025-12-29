import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/attendance_history_model.dart';
import '../screens/login_screen.dart';

class AttendanceHistoryController extends GetxController {
  final box = GetStorage();

  final String baseUrl = "http://103.251.143.196";
  final String historyApi =
      "http://103.251.143.196/attendance/api/attendance/history/";
  final String refreshApi =
      "http://103.251.143.196/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<Statistics> statistics = Rxn<Statistics>();

  // ✅ main data
  final RxList<Result> records = <Result>[].obs;

  // ✅ filtered data (search)
  final RxList<Result> filteredRecords = <Result>[].obs;
  final TextEditingController searchDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  @override
  void onClose() {
    searchDateController.dispose();
    super.onClose();
  }

  String get _accessToken => (box.read("access_token") ?? "").toString().trim();
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
        filteredRecords.assignAll(data.results); // ✅ always reset list after refresh

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

  /// ---------------- FILTER BY DATE (dd-MM-yyyy) ----------------
  void applyDateFilter(String ddMMyyyy) {
    final q = ddMMyyyy.trim();
    if (q.isEmpty) {
      filteredRecords.assignAll(records);
      return;
    }

    filteredRecords.assignAll(
      records.where((r) => formatToDdMmYyyy(r.date) == q).toList(),
    );
  }

  void clearFilter() {
    searchDateController.clear();
    filteredRecords.assignAll(records);
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

  /// ---------------- HELPERS ----------------
  String fullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    if (path.startsWith("http://") || path.startsWith("https://")) return path;
    return "$baseUrl$path";
  }

  // ✅ Title Case (Name + Username)
  String titleCase(String? input) {
    final s = (input ?? "").trim();
    if (s.isEmpty) return "--";
    return s
        .split(RegExp(r"\s+"))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1).toLowerCase() : ""))
        .join(" ");
  }

  // ✅ Date to dd-MM-yyyy (works for YYYY-MM-DD & ISO)
  String formatToDdMmYyyy(String? isoOrDate) {
    if (isoOrDate == null || isoOrDate.trim().isEmpty) return "--";
    try {
      DateTime d;
      if (isoOrDate.length == 10 && isoOrDate.contains("-")) {
        d = DateTime.parse(isoOrDate);
      } else {
        d = DateTime.parse(isoOrDate).toLocal();
      }
      return DateFormat("dd-MM-yyyy").format(d.toLocal());
    } catch (_) {
      return "--";
    }
  }

  // ✅ Time hh:mm a (Indian local)
  String formatIsoTime(String? iso) {
    if (iso == null || iso.trim().isEmpty) return "--";
    try {
      final d = DateTime.parse(iso).toLocal();
      return DateFormat("hh:mm a").format(d);
    } catch (_) {
      return "--";
    }
  }

  // ✅ dd-MM-yyyy hh:mm a (Indian local)
  String formatIsoDateTime(String? iso) {
    if (iso == null || iso.trim().isEmpty) return "--";
    try {
      final d = DateTime.parse(iso).toLocal();
      return DateFormat("dd-MM-yyyy hh:mm a").format(d);
    } catch (_) {
      return "--";
    }
  }
}
