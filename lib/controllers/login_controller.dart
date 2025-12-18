import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../screens/FaceRegisterScreen.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  final box = GetStorage();

  // ✅ Your login API
  final String loginApi = "http://115.241.73.226/attendance/api/auth/login/";

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;

  void onForgotPassword() {
    Get.snackbar(
      "Info",
      "Forgot password flow not connected yet.",
      snackPosition: SnackPosition.TOP,
    );
  }

  /// ✅ Call this in Splash or in LoginScreen init if you want auto-skip login
  bool get isLoggedIn => box.read("isLoggedIn") == true;

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
      final res = await http.post(
        Uri.parse(loginApi),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint("LOGIN STATUS: ${res.statusCode}");
        debugPrint("LOGIN BODY: ${res.body}");
      }

      dynamic body;
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = null;
      }

      if (res.statusCode != 200) {
        final msg =
            _extractErrorMessage(body) ?? "Login failed (HTTP ${res.statusCode})";
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

      if (body is! Map) {
        Get.snackbar(
          "Login Failed",
          "Unexpected response: ${res.body}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Your response format: { "refresh": "...", "access": "..." }
      final access = body["access"]?.toString() ?? "";
      final refresh = body["refresh"]?.toString() ?? "";

      if (access.isEmpty || refresh.isEmpty) {
        Get.snackbar(
          "Login Failed",
          "Access/Refresh token missing from server.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ CONSISTENT KEYS — use these everywhere in app
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

      Get.offAll(() => const FaceRegisterScreen());
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

  String? _extractErrorMessage(dynamic body) {
    if (body == null) return null;

    if (body is Map) {
      if (body["detail"] != null) return body["detail"].toString();
      if (body["message"] != null) return body["message"].toString();
      if (body["error"] != null) return body["error"].toString();

      // field errors: {"username":["..."], "password":["..."]}
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
