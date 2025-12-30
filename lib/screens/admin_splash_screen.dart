// screens/admin_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/admin_splash_controller.dart';
import '../utils/constants/color_constants.dart';

class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminSplashController());

    return Scaffold(
      backgroundColor: AppColor.White,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/monteage_logo.png',
            height: 70.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
