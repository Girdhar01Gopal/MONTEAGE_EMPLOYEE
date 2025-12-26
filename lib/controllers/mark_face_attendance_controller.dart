// controllers/mark_face_attendance_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MarkFaceAttendanceController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final box = GetStorage();

  // Image
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Lat/Lng + Address
  final RxString latText = "--".obs;
  final RxString lngText = "--".obs;
  final RxString addressText = "Fetching current location...".obs;

  // Loading
  final RxBool isLocLoading = false.obs;
  final RxBool isSubmittingAttendance = false.obs;

  // API URLs
  final String attendanceUrl =
      "http://115.241.73.226/attendance/api/attendance/mark/";

  String _tokenOrThrow() {
    final token = (box.read("access_token") ?? "").toString().trim();
    if (token.isEmpty) {
      throw Exception(
        "Access token missing. Save token in GetStorage as 'access_token' at login.",
      );
    }
    return token;
  }

  bool _isValidLatLng(String v) => double.tryParse(v) != null;

  // -----------------------------
  // Auto fetch safe method (call this from screen)
  // -----------------------------
  Future<void> ensureLocationFetched() async {
    if (isLocLoading.value) return; // don't spam
    await fetchLocationAll();
  }

Future<void> fetchLocationAll() async {
  try {
    isLocLoading.value = true;
    addressText.value = "Fetching current location...";

    // 1️⃣ Check GPS service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      latText.value = "GPS OFF";
      lngText.value = "GPS OFF";
      addressText.value = "Location service is OFF. Please enable GPS.";
      return;
    }

    // 2️⃣ Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      latText.value = "DENIED";
      lngText.value = "DENIED";
      addressText.value = "Location permission denied.";
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      latText.value = "SETTINGS";
      lngText.value = "SETTINGS";
      addressText.value =
          "Location permission permanently denied. Enable from Settings.";
      return;
    }

    // 3️⃣ Fetch position
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latText.value = pos.latitude.toStringAsFixed(6);
    lngText.value = pos.longitude.toStringAsFixed(6);

    // 4️⃣ Reverse geocode
    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    if (placemarks.isEmpty) {
      addressText.value = "Address not found (Lat/Lng available).";
      return;
    }

    final p = placemarks.first;
    final parts = <String>[
      if ((p.name ?? "").trim().isNotEmpty) p.name!.trim(),
      if ((p.street ?? "").trim().isNotEmpty) p.street!.trim(),
      if ((p.subLocality ?? "").trim().isNotEmpty) p.subLocality!.trim(),
      if ((p.locality ?? "").trim().isNotEmpty) p.locality!.trim(),
      if ((p.administrativeArea ?? "").trim().isNotEmpty)
        p.administrativeArea!.trim(),
      if ((p.postalCode ?? "").trim().isNotEmpty) p.postalCode!.trim(),
      if ((p.country ?? "").trim().isNotEmpty) p.country!.trim(),
    ];

    addressText.value = parts.join(", ");
  } catch (e) {
    latText.value = "ERROR";
    lngText.value = "ERROR";
    addressText.value = "Failed to fetch location.";
    Get.snackbar(
      "Error",
      "Location failed: $e",
      snackPosition: SnackPosition.TOP,
    );
  } finally {
    isLocLoading.value = false;
  }
}

  // -----------------------------
  // Take Photo using Camera
  // -----------------------------
  Future<void> takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return;

      selectedImage.value = File(picked.path);

      // refresh location after photo (optional)
      await fetchLocationAll();
    } catch (e) {
      Get.snackbar("Error", "Camera failed: $e",
          snackPosition: SnackPosition.TOP);
    }
  }

  void clearPhoto() => selectedImage.value = null;

  // -----------------------------
  // COMMON MULTIPART SENDER
  // -----------------------------
  Future<_ApiResult> _postMultipart({
    required String url,
    required Map<String, String> fields,
    required File imageFile,
  }) async {
    final token = _tokenOrThrow();

    final req = http.MultipartRequest("POST", Uri.parse(url));
    req.headers["Authorization"] = "Bearer $token";
    req.headers["Accept"] = "application/json";
    req.fields.addAll(fields);

    req.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    Map<String, dynamic>? jsonBody;
    try {
      jsonBody = body.isNotEmpty ? jsonDecode(body) : null;
    } catch (_) {
      jsonBody = null;
    }

    return _ApiResult(
      statusCode: res.statusCode,
      rawBody: body,
      json: jsonBody,
    );
  }

  // -----------------------------
  // TODAY'S ATTENDANCE SUBMIT
  // -----------------------------
  Future<void> submitAttendance() async {
    final img = selectedImage.value;

    if (img == null) {
      Get.snackbar("Missing Photo", "Please take/upload a photo first.",
          snackPosition: SnackPosition.TOP);
      return;
    }

    final lat = latText.value.trim();
    final lng = lngText.value.trim();

    if (!_isValidLatLng(lat) || !_isValidLatLng(lng)) {
      Get.snackbar("Location Required", "Please enable location and refresh.",
          snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isSubmittingAttendance.value = true;

      final result = await _postMultipart(
        url: attendanceUrl,
        fields: {
          "latitude": lat,
          "longitude": lng,
        },
        imageFile: img,
      );
print(result.rawBody);
print(attendanceUrl);
print(img.path);
      if (result.statusCode == 200 || result.statusCode == 201) {
        Get.snackbar("Success", "Today's attendance saved successfully!",
            snackPosition: SnackPosition.TOP);
      } else {
        final msg = result.json?["message"] ?? result.rawBody;
        Get.snackbar("Failed", "(${result.statusCode}) $msg",
            snackPosition: SnackPosition.TOP);
            print("Attendance submit failed: ${result.rawBody}");
      }
    } catch (e) {
      Get.snackbar("Error", "Submit failed: $e",
          snackPosition: SnackPosition.TOP);
    } finally {
      isSubmittingAttendance.value = false;
    }
  }
}

class _ApiResult {
  final int statusCode;
  final String rawBody;
  final Map<String, dynamic>? json;

  _ApiResult({
    required this.statusCode,
    required this.rawBody,
    required this.json,
  });
}
