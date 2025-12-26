// screens/permission_boot_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:monteage_employee/infrastructure/routes/admin_routes.dart';


class PermissionBootScreen extends StatefulWidget {
  const PermissionBootScreen({super.key});

  @override
  State<PermissionBootScreen> createState() => _PermissionBootScreenState();
}

class _PermissionBootScreenState extends State<PermissionBootScreen> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFlow());
  }

  Future<void> _initFlow() async {
    // 1) Ensure GPS service is ON
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("GPS Off", "Please enable Location/GPS to continue.");
      // Optional: open device settings
      await Geolocator.openLocationSettings();
      // continue anyway or return; your call
    }

    // 2) Request permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      Get.snackbar("Permission Denied", "Location permission is required.");
      // You can still navigate, but location features will fail.
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Permission Blocked",
        "Enable location permission from Settings.",
      );
      await Geolocator.openAppSettings();
      // continue anyway or return; your call
    }

    // 3) Route to LOGIN/HOME
    final isLoggedIn = box.read('isLoggedIn') ?? false;
    Get.offAllNamed(isLoggedIn ? AdminRoutes.HOME : AdminRoutes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
