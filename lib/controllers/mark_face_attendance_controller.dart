import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class MarkFaceAttendanceController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Image
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Lat/Lng + Address
  final RxString latText = "--".obs;
  final RxString lngText = "--".obs;
  final RxString addressText = "Fetching current location...".obs;

  // Loading
  final RxBool isLocLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // ✅ Change this to your backend endpoint
  final String submitUrl = "https://YOUR_DOMAIN.com/api/attendance/mark";

  @override
  void onInit() {
    super.onInit();
    fetchLocationAll();
  }

  Future<void> fetchLocationAll() async {
    try {
      isLocLoading.value = true;
      addressText.value = "Fetching current location...";

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        latText.value = "GPS OFF";
        lngText.value = "GPS OFF";
        addressText.value = "Location is OFF. Please enable GPS.";
        return;
      }

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
        addressText.value = "Permission blocked. Enable from Settings.";
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latText.value = pos.latitude.toStringAsFixed(6);
      lngText.value = pos.longitude.toStringAsFixed(6);

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
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
        if ((p.administrativeArea ?? "").trim().isNotEmpty) p.administrativeArea!.trim(),
        if ((p.postalCode ?? "").trim().isNotEmpty) p.postalCode!.trim(),
        if ((p.country ?? "").trim().isNotEmpty) p.country!.trim(),
      ];

      addressText.value = parts.join(", ");
    } catch (e) {
      latText.value = "ERROR";
      lngText.value = "ERROR";
      addressText.value = "Failed to fetch location: $e";
      Get.snackbar("Error", "Location failed: $e", snackPosition: SnackPosition.TOP);
    } finally {
      isLocLoading.value = false;
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return;

      selectedImage.value = File(picked.path);
      await fetchLocationAll();
    } catch (e) {
      Get.snackbar("Error", "Camera failed: $e", snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> uploadPhoto() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      selectedImage.value = File(picked.path);
      await fetchLocationAll();
    } catch (e) {
      Get.snackbar("Error", "Gallery failed: $e", snackPosition: SnackPosition.TOP);
    }
  }

  void clearPhoto() {
    selectedImage.value = null;
  }

  Future<void> openLocationSettings() async => Geolocator.openLocationSettings();
  Future<void> openAppSettings() async => Geolocator.openAppSettings();

  // ✅ SUBMIT/SAVE DATA TO SERVER
  Future<void> submitAttendance() async {
    final img = selectedImage.value;

    // Hard validation (don’t submit garbage)
    if (img == null) {
      Get.snackbar("Missing Photo", "Please take/upload a photo first.",
          snackPosition: SnackPosition.TOP);
      return;
    }

    // If location is not ready, stop
    final lat = latText.value;
    final lng = lngText.value;

    if (lat == "--" || lng == "--" || lat == "GPS OFF" || lat == "DENIED" || lat == "SETTINGS") {
      Get.snackbar("Location Required", "Please enable location and refresh.",
          snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isSubmitting.value = true;

      final req = http.MultipartRequest("POST", Uri.parse(submitUrl));

      // ✅ Add fields (adjust names to match your backend)
      req.fields["latitude"] = lat;
      req.fields["longitude"] = lng;
      req.fields["address"] = addressText.value;
      req.fields["marked_at"] = DateTime.now().toIso8601String();

      // Example optional fields:
      // req.fields["employee_id"] = "123";
      // req.fields["device"] = "android";

      req.files.add(await http.MultipartFile.fromPath("photo", img.path));

      // If you need token:
      // req.headers["Authorization"] = "Bearer YOUR_TOKEN";

      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar("Success", "Attendance saved successfully!",
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("Failed", "Server error (${res.statusCode}): $body",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", "Submit failed: $e", snackPosition: SnackPosition.TOP);
    } finally {
      isSubmitting.value = false;
    }
  }
}
