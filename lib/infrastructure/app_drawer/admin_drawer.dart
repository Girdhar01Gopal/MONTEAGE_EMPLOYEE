import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../infrastructure/routes/admin_routes.dart';
import '../../utils/constants/color_constants.dart';

class AdminDrawer extends StatefulWidget {
  @override
  _AdminDrawerState createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String? hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== UPDATED HEADER ====================
            Container(
              width: double.infinity,
              height: 150.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFC71585), // Red Violet
                    Color(0xFF4A0000), // Oxblood
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ATTENDANCE APP", // SHOP NAME
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "***********", // GST NUMBER
                    style: TextStyle(
                      color: Colors.yellow[300],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ==================== ELEVATED CARDS ====================
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _elevatedCard(
                    title: "ATTENDANCE",
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFC71585), // Red Violet
                        Color(0xFF4A0000), // Oxblood
                      ],                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    indicatorColor: Colors.yellow,
                    textColor: Colors.white,
                    onTap: () => Get.toNamed(AdminRoutes.attendanceDetails),
                  ),
                   SizedBox(height: 10.h),
                   _elevatedCard(
                     title: "ATTENDANCE 2",
                     gradient: LinearGradient(
                       colors: [Colors.green.shade500, Colors.green.shade900],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     indicatorColor: Colors.white,
                     textColor: Colors.white,
                     onTap: () => Get.toNamed(AdminRoutes.MARK_FACE_ATTENDANCE),
                   ),
                   SizedBox(height: 10.h),
                   _elevatedCard(
                     title: "ATTENDANCE 3",
                     gradient: LinearGradient(
                       colors: [Colors.grey.shade600, Colors.grey.shade900],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     indicatorColor: Colors.lightGreen,
                     textColor: Colors.white,
                     onTap: () => Get.toNamed(AdminRoutes.MARK_FACE_ATTENDANCE),
                   ),
                  SizedBox(height: 10.h),
                  // ==================== LOGOUT CARD ====================
                  _elevatedCard(
                    title: "Logout",
                    gradient: LinearGradient(
                      colors: [Colors.red.shade500, Colors.red.shade900], // Red gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    indicatorColor: Colors.white,
                    textColor: Colors.white,
                    onTap: () {
                      // Clear the session or logout logic
                      Get.offAllNamed(AdminRoutes.LOGIN); // Navigate to the login screen
                    },
                  ),
                ],
              ),
            ),

            // ==================== MENU ITEMS ====================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // You can add additional items here if needed
                    // _buildDrawerItem("Dashboard", Icons.dashboard, AdminRoutes.LOADING_SCREEN, currentRoute),
                    // _buildDrawerItem("Logout", Icons.logout, "", currentRoute, isLogout: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Elevated Card Widget
  Widget _elevatedCard({
    required String title,
    required LinearGradient gradient,
    required Color indicatorColor,
    required Color textColor,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 18.w),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            // Right dot indicator
            Container(
              height: 26.w,
              width: 26.w,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
