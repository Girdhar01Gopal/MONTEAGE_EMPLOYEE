import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/profile_model.dart';
import '../screens/login_screen.dart';

class EmployeeProfileController extends GetxController {
  final box = GetStorage();

  final String baseUrl = "http://103.251.143.196";
  final String profileApi =
      "http://103.251.143.196/attendance/api/auth/profile/";
  final String refreshApi =
      "http://103.251.143.196/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();

  String get _accessToken => (box.read("access_token") ?? "").toString().trim();
  String get _refreshToken =>
      (box.read("refresh_token") ?? "").toString().trim();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final res = await _authorizedGet(Uri.parse(profileApi));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        profile.value = ProfileModel.fromJson(decoded);
        return;
      }

      if (res.statusCode == 401) {
        _forceLogout();
        return;
      }

      Get.snackbar(
        "Error",
        "Profile load failed (HTTP ${res.statusCode})",
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

  // ---------- UI helpers ----------
  String fullImageUrl(String? path) {
    final p = (path ?? "").trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http://") || p.startsWith("https://")) return p;
    return "$baseUrl$p";
  }

  String titleCase(String? input) {
    final s = (input ?? "").trim();
    if (s.isEmpty) return "--";
    return s
        .split(RegExp(r"\s+"))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1).toLowerCase() : ""))
        .join(" ");
  }

  // ✅ NEW: dd-MM-yyyy hh:mm a (Indian local)
  String formatDateTimeIndian(DateTime? dt) {
    if (dt == null) return "--";
    final local = dt.toLocal();
    return DateFormat("dd-MM-yyyy hh:mm a").format(local);
  }

  // ✅ NEW: dd-MM-yyyy only
  String formatDateOnlyIndian(DateTime? dt) {
    if (dt == null) return "--";
    final local = dt.toLocal();
    return DateFormat("dd-MM-yyyy").format(local);
  }
}
