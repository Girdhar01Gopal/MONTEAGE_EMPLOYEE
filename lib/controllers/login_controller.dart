import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../screens/home_screen.dart';

class LoginController extends GetxController {
  final companyCodeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  final box = GetStorage();

  final String loginApi =
      "https://montgymapi.eduagentapp.com/api/MonteageGymApp/Logins";

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;

  void onForgotPassword() {
    Get.snackbar(
      "Info",
      "Forgot password flow not connected yet.",
      snackPosition: SnackPosition.TOP,
    );
  }

  void onRegister() {
    Get.snackbar(
      "Info",
      "Register flow not connected yet.",
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> loginUser() async {
    final companyCode = companyCodeController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (companyCode.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Company Code, Email and Password are required",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(loginApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "companyCode": companyCode, // keep only if backend supports it
        }),
      );

      dynamic jsonBody;
      try {
        jsonBody = jsonDecode(response.body);
      } catch (_) {
        jsonBody = null;
      }

      final ok = response.statusCode == 200 &&
          jsonBody is Map &&
          (jsonBody["statuscode"] == 200);

      if (ok) {
        box.write("isLoggedIn", true);

        Get.snackbar(
          "Success",
          "Login Successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 400));
        Get.off(() => HomeScreen());
      } else {
        Get.snackbar(
          "Login Failed",
          (jsonBody is Map && jsonBody["message"] != null)
              ? jsonBody["message"].toString()
              : "Invalid credentials",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
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

  @override
  void onClose() {
    companyCodeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
