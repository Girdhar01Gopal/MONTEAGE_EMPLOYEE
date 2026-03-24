import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:monteage_employee/infrastructure/routes/admin_routes.dart';

class FaceIdLoginController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final GetStorage box = GetStorage();

  final Rxn<File> selectedImage = Rxn<File>();
  final RxBool isChecking = false.obs;
  final RxBool isFaceDetected = false.obs;
  final RxBool isFaceMatched = false.obs;
  final RxString statusMessage = "Capture your face to login".obs;
  final RxString matchStatus = "".obs;

  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final RxString accessToken = "".obs;
  final RxString refreshToken = "".obs;
  final RxDouble confidenceScore = 0.0.obs;

  late final FaceDetector _faceDetector;

  static const String _faceLoginApi =
      'http://att.monteage.co.in/attendance/api/auth/face-login/';

  @override
  void onInit() {
    super.onInit();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo == null) return;

      final file = File(photo.path);
      selectedImage.value = file;
      resetMatchState();
      statusMessage.value = "Checking face...";

      await detectFaceAndValidate(file);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to open camera: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> detectFaceAndValidate(File file) async {
    isChecking.value = true;

    try {
      final inputImage = InputImage.fromFile(file);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        isFaceDetected.value = false;
        isFaceMatched.value = false;
        matchStatus.value = "Face not detected";
        statusMessage.value = "No face found. Please try again.";

        Get.snackbar(
          "Face Not Found",
          "Please capture a clear face image.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (faces.length > 1) {
        isFaceDetected.value = false;
        isFaceMatched.value = false;
        matchStatus.value = "Multiple faces detected";
        statusMessage.value = "Only one face should be visible.";

        Get.snackbar(
          "Multiple Faces",
          "Please capture only your face.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isFaceDetected.value = true;
      statusMessage.value = "Face detected successfully";

      await matchFaceIdWithApi(file);
    } catch (e) {
      isFaceDetected.value = false;
      isFaceMatched.value = false;
      matchStatus.value = "Detection failed";
      statusMessage.value = "Something went wrong while detecting face.";

      Get.snackbar(
        "Error",
        "Face detection failed: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> matchFaceIdWithApi(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_faceLoginApi),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokens =
            (responseData['tokens'] as Map<String, dynamic>?) ??
                <String, dynamic>{};

        final Map<String, dynamic> user =
            (responseData['user'] as Map<String, dynamic>?) ??
                <String, dynamic>{};

        final dynamic confidence = responseData['confidence_score'];

        accessToken.value = (tokens['access'] ?? '').toString();
        refreshToken.value = (tokens['refresh'] ?? '').toString();
        confidenceScore.value = double.tryParse('${confidence ?? 0}') ?? 0.0;

        userData.assignAll(user);

        box.write("access_token", accessToken.value);
        box.write("refresh_token", refreshToken.value);
        box.write("user_data", userData);
        box.write("confidence_score", confidenceScore.value);
        box.write("is_logged_in", true);
        box.write("login_type", "face_id");

        isFaceMatched.value = true;
        matchStatus.value = "Face ID matched";
        statusMessage.value =
        "Face matched successfully. Click Verify Face ID.";

        Get.snackbar(
          "Success",
          "Face ID matched successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        isFaceMatched.value = false;
        userData.clear();
        accessToken.value = "";
        refreshToken.value = "";
        confidenceScore.value = 0.0;

        final String message =
        (responseData['message'] ??
            responseData['detail'] ??
            "Face ID not matched")
            .toString();

        matchStatus.value = message;
        statusMessage.value = "Face does not match";

        Get.snackbar(
          "Failed",
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isFaceMatched.value = false;
      userData.clear();
      accessToken.value = "";
      refreshToken.value = "";
      confidenceScore.value = 0.0;
      matchStatus.value = "Match failed";
      statusMessage.value = "Unable to verify face";

      Get.snackbar(
        "Error",
        "Face verification failed: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void verifyAndGoToHome() {
    if (!isFaceMatched.value) {
      Get.snackbar(
        "Verification Pending",
        "Please match Face ID first.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.offAllNamed(
      AdminRoutes.HOME,
      arguments: {
        "user": Map<String, dynamic>.from(userData),
        "access_token": accessToken.value,
        "refresh_token": refreshToken.value,
        "confidence_score": confidenceScore.value,
      },
    );
  }

  void clearPhoto() {
    selectedImage.value = null;
    resetMatchState();
    statusMessage.value = "Capture your face to login";
  }

  void resetMatchState() {
    isFaceDetected.value = false;
    isFaceMatched.value = false;
    isChecking.value = false;
    matchStatus.value = "";
    accessToken.value = "";
    refreshToken.value = "";
    confidenceScore.value = 0.0;
    userData.clear();
  }

  @override
  void onClose() {
    _faceDetector.close();
    super.onClose();
  }
}