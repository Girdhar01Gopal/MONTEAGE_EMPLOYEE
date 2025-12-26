// controllers/register_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../screens/login_screen.dart'; // Import LoginScreen for navigation after successful registration

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final EmployeeIdc = TextEditingController();

  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final departmentController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isPassword2Hidden = true.obs;
  var isLoading = false.obs;

  // Toggle password visibility
  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void togglePassword2() {
    isPassword2Hidden.value = !isPassword2Hidden.value;
  }

  // Register User
  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    final body = {
      "username": firstNameController.text.trim(),
      "email": emailController.text.trim(),
      "employee_id": "EMP0${EmployeeIdc.text.trim()}",  // Employee ID is hardcoded as per your provided body
      "password": passwordController.text.trim(),
      "confirm_password": password2Controller.text.trim(),
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),  // Optional last name (empty allowed)
      "department": departmentController.text.trim(),
    };
print(body);
    try {
      final response = await http.post(
        Uri.parse('http://115.241.73.226/attendance/api/auth/register/'), // Ensure full URL
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30)); // Added a timeout to handle slow server responses

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        if (responseData['message'] == 'User registered successfully. Please register your face.') {
          // Save tokens in GetStorage after successful registration
          final accessToken = responseData['tokens']['access'];
          final refreshToken = responseData['tokens']['refresh'];
          final empid = responseData['user']['employee_id'];

          final box = GetStorage();
          await box.write("access_token", accessToken);
          await box.write("refresh_token", refreshToken);
          await box.write("empid",empid);
          await box.write("isLoggedIn", true);

          Get.snackbar("Success", "Registration successful! Please register your face.");
          Get.back(); // Go back to the previous screen
          Get.offAll(() => LoginScreen());  // Navigate to Login screen
        } else {
          Get.snackbar("Error", "Registration failed: ${responseData['message']}");
        }
      } else {
        // Handle status code 400 or other errors
        final errorBody = json.decode(response.body);
        final errorMessage = _extractErrorMessage(errorBody);
        Get.snackbar("Error", errorMessage ?? "Registration failed with status code: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      // Handle timeout error
      Get.snackbar("Error", "The request timed out. Please try again.");
    } on ClientException catch (_) {
      // Handle connection issues
      Get.snackbar("Error", "Failed to connect to the server. Please check your internet connection.");
    } catch (e) {
      // Catch any other exceptions
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Extract detailed error messages from the response body
  String? _extractErrorMessage(dynamic body) {
    if (body == null) return null;

    if (body is Map) {
      // Most common error from API
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
}
