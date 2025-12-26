// controllers/attendance_history_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_history_model.dart';
import '../screens/login_screen.dart';

class AttendanceHistoryController extends GetxController {
  final box = GetStorage();

  final String historyApi =
      "http://115.241.73.226/attendance/api/attendance/history/";
  final String refreshApi =
      "http://115.241.73.226/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<Statistics> statistics = Rxn<Statistics>();
  final RxList<Results> records = <Results>[].obs;

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
        final data = AttendanceHistoryModel.fromJson(decoded);
        print(data);
        

        statistics.value = data.statistics;
        records.assignAll(data.results ?? []);
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
    // First attempt with current access token
    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $_accessToken",
        "Accept": "application/json",
      },
    );

    // If not 401, return as-is
    if (res.statusCode != 401) return res;

    // Try refreshing
    final refreshed = await _refreshAccessToken();
    if (!refreshed) return res;

    // Retry with new access token
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
}
