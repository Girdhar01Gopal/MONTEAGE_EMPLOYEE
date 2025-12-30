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

class _PermissionBootScreenState extends State<PermissionBootScreen>
    with WidgetsBindingObserver {
  final box = GetStorage();

  bool _navigated = false;
  bool _openingSettings = false;
  bool _requestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndProceed());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndProceed();
    }
  }

  void _snackRed(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  bool _hasValidTokens() {
    final access = (box.read("access_token") ?? "").toString().trim();
    final refresh = (box.read("refresh_token") ?? "").toString().trim();
    return access.isNotEmpty && refresh.isNotEmpty;
  }

  void _goNext() {
    if (_navigated) return;
    _navigated = true;

    final isLoggedIn = _hasValidTokens();
    Get.offAllNamed(isLoggedIn ? AdminRoutes.HOME : AdminRoutes.LOGIN);
  }

  Future<void> _checkAndProceed() async {
    if (_navigated) return;

    // 1) GPS ON?
    final gpsOn = await Geolocator.isLocationServiceEnabled();
    if (!gpsOn) {
      if (!_openingSettings) {
        _openingSettings = true;
        _snackRed("GPS Off", "Please enable Location/GPS to continue.");
        await Geolocator.openLocationSettings();
        _openingSettings = false;
      }
      return;
    }

    // 2) Permission check
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      if (_requestingPermission) return;
      _requestingPermission = true;

      perm = await Geolocator.requestPermission();
      _requestingPermission = false;
    }

    if (perm == LocationPermission.deniedForever) {
      if (!_openingSettings) {
        _openingSettings = true;
        _snackRed("Permission Blocked", "Enable location permission from Settings.");
        await Geolocator.openAppSettings();
        _openingSettings = false;
      }
      return;
    }

    if (perm == LocationPermission.denied) {
      _snackRed("Permission Denied", "Location permission is required.");
      return;
    }

    // ✅ 3) GPS ON + Permission granted => go next
    _goNext();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.shrink(),
    );
  }
}
