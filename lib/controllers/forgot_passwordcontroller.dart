import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordController extends GetxController {
  final emailC = TextEditingController();
  final isLoading = false.obs;

  // ✅ CHANGE THIS to your real forgot-password endpoint
  // Your screenshot shows you're wrongly hitting /auth/login/
  final String forgotUrl = "http://att.monteage.co.in/attendance/api/auth/forgot-password/";

  Future<void> sendResetLink() async {
    final email = emailC.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Email is required");
      return;
    }

    try {
      isLoading.value = true;

      final res = await http.post(
        Uri.parse(forgotUrl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": email,
        },
      );

      if (res.statusCode == 200) {
        Get.snackbar("Success", "Reset instructions sent to your email");
      } else {
        Get.snackbar("Error", "Server error: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Network/Server issue: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }
}
