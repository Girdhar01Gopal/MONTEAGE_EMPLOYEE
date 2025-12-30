/*import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class FaceRegisterController extends GetxController {
  var selectedImage = Rx<File?>(null);
  var isSubmitting = false.obs;

  final String faceRegisterUrl = "http://103.251.143.196/attendance/api/face/register/";

  // To pick the image from the camera
  Future<void> takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // To clear the selected image
  void clearPhoto() {
    selectedImage.value = null;
  }

  // To submit the face registration
  Future<void> submitRegistration() async {
    if (selectedImage.value == null) {
      Get.snackbar('Error', 'Please upload your face image first.');
      return;
    }

    isSubmitting.value = true;

    try {
      // Prepare the multipart request
      final request = http.MultipartRequest('POST', Uri.parse(faceRegisterUrl));
      final token = _getToken();  // Get the saved token

      // Add the headers and image file
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage.value!.path));

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Face registered successfully!');
        isSubmitting.value = false;
        // Navigate to HomeScreen after successful registration
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Failed to register face: $responseBody');
        isSubmitting.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Face registration failed: $e');
      isSubmitting.value = false;
    }
  }

  // Function to get the access token
  String _getToken() {
    final token = GetStorage().read('access_token') ?? '';
    if (token.isEmpty) {
      throw Exception('Access token missing');
    }
    return token;
  }
}
*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FaceRegisterController extends GetxController {
  final box = GetStorage();
  final ImagePicker _picker = ImagePicker();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isSubmitting = false.obs;

  final String faceRegisterUrl =
      "http://103.251.143.196/attendance/api/face/register/";

  // ---------- Snackbars ----------
  void _snackSuccess(String msg) {
    Get.snackbar(
      "Success",
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
    );
  }

  void _snackError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ---------- Token ----------
  String _tokenOrThrow() {
    final token = (box.read("access_token") ?? "").toString().trim();
    if (token.isEmpty) throw Exception("Access token missing");
    return token;
  }

  // ---------- Pick/Clear ----------
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image == null) return;
      selectedImage.value = File(image.path);
    } catch (e) {
      _snackError("Camera failed: $e");
    }
  }

  void clearPhoto() => selectedImage.value = null;

  // ---------- Submit ----------
  Future<void> submitRegistration() async {
    final img = selectedImage.value;

    if (img == null) {
      _snackError("Please upload your face image first.");
      return;
    }

    isSubmitting.value = true;

    try {
      final token = _tokenOrThrow();

      final req = http.MultipartRequest("POST", Uri.parse(faceRegisterUrl));
      req.headers["Authorization"] = "Bearer $token";
      req.headers["Accept"] = "application/json";

      req.files.add(await http.MultipartFile.fromPath("image", img.path));

      final res = await req.send();
      final body = await res.stream.bytesToString();

      // Parse message safely
      String msgFromServer = body;
      try {
        final decoded = body.isNotEmpty ? jsonDecode(body) : null;
        if (decoded is Map<String, dynamic>) {
          msgFromServer = (decoded["message"] ??
              decoded["detail"] ??
              decoded["error"] ??
              body)
              .toString();
        }
      } catch (_) {}

      if (res.statusCode == 200 || res.statusCode == 201) {
        _snackSuccess("Face registered successfully!");
        // Navigate home
        Get.offAllNamed("/home");
      } else {
        _snackError("Failed to register face: (${"${res.statusCode}"}) $msgFromServer");
      }
    } catch (e) {
      _snackError("Face registration failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }
}
