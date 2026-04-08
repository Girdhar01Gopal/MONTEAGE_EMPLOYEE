/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_today.dart';
import '../screens/login_screen.dart';

class AttendanceTodayController extends GetxController {
  final box = GetStorage();

  final String baseUrl = "http://att.monteage.co.in/";
  final String todayApi = "http://att.monteage.co.in/attendance/api/attendance/today/";
  final String refreshApi = "http://att.monteage.co.in/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<AttendanceToday> today = Rxn<AttendanceToday>();

  String get _access => (box.read("access_token") ?? "").toString().trim();
  String get _refresh => (box.read("refresh_token") ?? "").toString().trim();

  @override
  void onInit() {
    super.onInit();
    fetchToday();
  }

  Future<void> fetchToday() async {
    isLoading.value = true;
    try {
      final res = await _authorizedGet(Uri.parse(todayApi));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        today.value = AttendanceToday.fromJson(decoded);
        return;
      }

      if (res.statusCode == 401) {
        _logout();
        return;
      }

      Get.snackbar(
        "Error",
        "Failed (HTTP ${res.statusCode})",
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
      headers: {"Authorization": "Bearer $_access", "Accept": "application/json"},
    );

    if (res.statusCode != 401) return res;

    final ok = await _refreshToken();
    if (!ok) return res;

    return http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${(box.read("access_token") ?? "").toString()}",
        "Accept": "application/json"
      },
    );
  }

  Future<bool> _refreshToken() async {
    if (_refresh.isEmpty) return false;

    final res = await http.post(
      Uri.parse(refreshApi),
      headers: const {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({"refresh": _refresh}),
    );

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(res.body);
    final newAccess = decoded["access"]?.toString() ?? "";
    if (newAccess.isEmpty) return false;

    await box.write("access_token", newAccess);
    return true;
  }

  void _logout() {
    box.erase();
    Get.offAll(() => const LoginScreen());
    Get.snackbar("Session Expired", "Please login again");
  }

  // ✅ clean address (removes extra quotes)
  String cleanAddress(String? a) {
    final s = (a ?? "").trim();
    if (s.isEmpty) return "--";
    return s.replaceAll('\\"', '"').replaceAll('"', '').trim();
  }

  // (optional) if you ever need full image url later
  String fullImageUrl(String? path) {
    final p = (path ?? "").trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http://") || p.startsWith("https://")) return p;
    return "$baseUrl$p";
  }
}
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

import '../models/attendance_today.dart';
import '../screens/login_screen.dart';

class AttendanceTodayController extends GetxController {
  final box = GetStorage();

  final String baseUrl = "http://att.monteage.co.in/";
  final String todayApi = "http://att.monteage.co.in/attendance/api/attendance/today/";
  final String refreshApi = "http://att.monteage.co.in/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<AttendanceToday> today = Rxn<AttendanceToday>();
  final resolvedAddress = "--".obs;

  String get _access => (box.read("access_token") ?? "").toString().trim();
  String get _refresh => (box.read("refresh_token") ?? "").toString().trim();

  @override
  void onInit() {
    super.onInit();
    fetchToday();
  }

  Future<void> fetchToday() async {
    isLoading.value = true;
    try {
      final res = await _authorizedGet(Uri.parse(todayApi));

      if (res.statusCode == 200) {
        final decoded = Map<String, dynamic>.from(jsonDecode(res.body));
        today.value = AttendanceToday.fromJson(decoded);

        await _resolveLocationAddress(
          today.value?.location.latitude,
          today.value?.location.longitude,
          fallbackAddress: today.value?.location.address,
        );

        return;
      }

      if (res.statusCode == 401) {
        _logout();
        return;
      }

      Get.snackbar(
        "Error",
        "Failed (HTTP ${res.statusCode})",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Attendance",
        "Please mark your attendance first",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
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
        "Authorization": "Bearer $_access",
        "Accept": "application/json",
      },
    );

    if (res.statusCode != 401) return res;

    final ok = await _refreshToken();
    if (!ok) return res;

    return http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${(box.read("access_token") ?? "").toString()}",
        "Accept": "application/json",
      },
    );
  }

  Future<bool> _refreshToken() async {
    if (_refresh.isEmpty) return false;

    final res = await http.post(
      Uri.parse(refreshApi),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"refresh": _refresh}),
    );

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(res.body);
    final newAccess = decoded["access"]?.toString() ?? "";
    if (newAccess.isEmpty) return false;

    await box.write("access_token", newAccess);
    return true;
  }

  Future<void> _resolveLocationAddress(
      double? latitude,
      double? longitude, {
        String? fallbackAddress,
      }) async {
    try {
      if (latitude == null || longitude == null) {
        resolvedAddress.value = cleanAddress(fallbackAddress);
        return;
      }

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[
          if ((p.name ?? '').trim().isNotEmpty) p.name!.trim(),
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty) p.administrativeArea!.trim(),
          if ((p.postalCode ?? '').trim().isNotEmpty) p.postalCode!.trim(),
          if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
        ];

        resolvedAddress.value =
        parts.isNotEmpty ? parts.join(', ') : cleanAddress(fallbackAddress);
      } else {
        resolvedAddress.value = cleanAddress(fallbackAddress);
      }
    } catch (_) {
      resolvedAddress.value = cleanAddress(fallbackAddress);
    }
  }

  void _logout() {
    box.erase();
    Get.offAll(() => const LoginScreen());
    Get.snackbar("Session Expired", "Please login again");
  }

  String cleanAddress(String? a) {
    final s = (a ?? "").trim();
    if (s.isEmpty) return "--";
    return s.replaceAll('\\"', '"').replaceAll('"', '').trim();
  }

  String fullImageUrl(String? path) {
    final p = (path ?? "").trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http://") || p.startsWith("https://")) return p;
    return "$baseUrl$p";
  }
}