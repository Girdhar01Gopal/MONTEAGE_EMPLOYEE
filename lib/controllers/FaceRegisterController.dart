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

  final String faceRegisterUrl = "http://103.251.143.196/attendance/api/face/register/";
  final String refreshApi = "http://103.251.143.196/attendance/api/auth/refresh/";

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
  String get _accessToken => (box.read("access_token") ?? "").toString().trim();
  String get _refreshToken => (box.read("refresh_token") ?? "").toString().trim();

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

  // ---------- Refresh Access Token ----------
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
    final newAccess = decoded["access"]?.toString() ?? "";
    if (newAccess.isEmpty) return false;

    await box.write("access_token", newAccess);
    return true;
  }

  // ---------- Submit ----------
  Future<void> submitRegistration() async {
    final img = selectedImage.value;
    if (img == null) {
      _snackError("Please upload your face image first.");
      return;
    }

    if (_accessToken.isEmpty) {
      _snackError("Access token missing. Please login again.");
      return;
    }

    isSubmitting.value = true;

    try {
      // 1st attempt
      final first = await _uploadFace(img, token: _accessToken);

      if (first.statusCode == 200 || first.statusCode == 201) {
        _snackSuccess("Face registered successfully!");
        Get.back(result: true); // ✅ return to profile screen
        return;
      }

      // If unauthorized -> refresh token -> retry once
      if (first.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (!refreshed) {
          _snackError("Session expired. Please login again.");
          Get.back(result: false);
          return;
        }

        final retryToken = (box.read("access_token") ?? "").toString().trim();
        final second = await _uploadFace(img, token: retryToken);

        if (second.statusCode == 200 || second.statusCode == 201) {
          _snackSuccess("Face registered successfully!");
          Get.back(result: true);
          return;
        }

        _snackError("Failed to register face: (${second.statusCode}) ${second.message}");
        return;
      }

      _snackError("Failed to register face: (${first.statusCode}) ${first.message}");
    } catch (e) {
      _snackError("Face registration failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  // ---------- Actual Multipart Upload ----------
  Future<_UploadResult> _uploadFace(File img, {required String token}) async {
    final req = http.MultipartRequest("POST", Uri.parse(faceRegisterUrl));
    req.headers["Authorization"] = "Bearer $token";
    req.headers["Accept"] = "application/json";

    // backend expects "image" (you already used it)
    req.files.add(await http.MultipartFile.fromPath("image", img.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    String msgFromServer = body;
    try {
      final decoded = body.isNotEmpty ? jsonDecode(body) : null;
      if (decoded is Map<String, dynamic>) {
        msgFromServer = (decoded["message"] ?? decoded["detail"] ?? decoded["error"] ?? body).toString();
      }
    } catch (_) {}

    return _UploadResult(statusCode: res.statusCode, message: msgFromServer);
  }
}

class _UploadResult {
  final int statusCode;
  final String message;
  _UploadResult({required this.statusCode, required this.message});
}
