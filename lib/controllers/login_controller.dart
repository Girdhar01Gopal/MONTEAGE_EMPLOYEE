import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../screens/home_screen.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  final box = GetStorage();

  // ✅ Your API
  final String loginApi = "http://115.241.73.226/attendance/api/auth/login/";

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;

  void onForgotPassword() {
    Get.snackbar(
      "Info",
      "Forgot password flow not connected yet.",
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> loginUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Username and Password are required",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final payload = {"username": username, "password": password};

      final res = await http
          .post(
        Uri.parse(loginApi),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 20));

      // ✅ Always decode safely
      dynamic body;
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = null;
      }

      // ✅ Debug (shows you real reason)
      if (kDebugMode) {
        debugPrint("LOGIN STATUS: ${res.statusCode}");
        debugPrint("LOGIN BODY: ${res.body}");
        debugPrint("LOGIN HEADERS: ${res.headers}");
      }

      // ✅ Show server response in snackbar if not 200 (so you don't stay blind)
      if (res.statusCode != 200) {
        final msg = _extractErrorMessage(body) ??
            "Login failed (HTTP ${res.statusCode}).";

        Get.snackbar(
          "Login Failed",
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // ✅ success response: expects access + refresh
      if (body is! Map || body["access"] == null || body["refresh"] == null) {
        // Sometimes backend returns something else => show it
        Get.snackbar(
          "Login Failed",
          "Unexpected response: ${res.body}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      final access = body["access"].toString();
      final refresh = body["refresh"].toString();

      if (access.isEmpty || refresh.isEmpty) {
        Get.snackbar(
          "Login Failed",
          "Token missing/empty from server.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Store tokens
      await box.write("access_token", access);
      await box.write("refresh_token", refresh);
      await box.write("isLoggedIn", true);

      Get.snackbar(
        "Success",
        "Login Successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => HomeScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network/Server issue: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Handles Django SimpleJWT errors + other formats
  String? _extractErrorMessage(dynamic body) {
    if (body == null) return null;

    if (body is Map) {
      // Most common Django message
      if (body["detail"] != null) return body["detail"].toString();
      if (body["message"] != null) return body["message"].toString();
      if (body["error"] != null) return body["error"].toString();

      // Field validation errors: {"username":["..."], "password":["..."]}
      final buf = <String>[];
      body.forEach((k, v) {
        if (v is List && v.isNotEmpty) buf.add("$k: ${v.first}");
        if (v is String) buf.add("$k: $v");
      });
      if (buf.isNotEmpty) return buf.join("\n");
    }

    return body.toString();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
