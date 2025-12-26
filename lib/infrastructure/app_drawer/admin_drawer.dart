// infrastructure/app_drawer/admin_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:monteage_employee/infrastructure/utils/pref_manager.dart';
import '../../infrastructure/routes/admin_routes.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
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
            // ==================== HEADER ====================
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
                    "Monteage Employee",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "MONTEAGE ATTENDANCE SYSTEM",
                    style: TextStyle(
                      color: Colors.yellow[300],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ==================== HOME STYLE CARDS ====================
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _actionCard(
                    title: "Mark Attendance",
                    subtitle: "Face & location based",
                    icon: Icons.face_retouching_natural,
                    gradient: const [
                      Color(0xFF16A34A),
                      Color(0xFF22C55E),
                    ],
                    isActive: currentRoute == AdminRoutes.MARK_FACE_ATTENDANCE,
                    onTap: () => Get.toNamed(AdminRoutes.MARK_FACE_ATTENDANCE),
                  ),

                  SizedBox(height: 12.h),

                  _actionCard(
                    title: "Attendance History",
                    subtitle: "View daily attendance records",
                    icon: Icons.history,
                    gradient: const [
                      Color(0xFF2563EB),
                      Color(0xFF3B82F6),
                    ],
                    isActive: currentRoute == AdminRoutes.attendanceHistory,
                    onTap: () => Get.toNamed(AdminRoutes.attendanceHistory),
                  ),

                  SizedBox(height: 12.h),

                  _actionCard(
                    title: "Today's Attendance",
                    subtitle: "Verification status & details",
                    icon: Icons.fact_check,
                    gradient: [
                      Colors.grey.shade700,
                      Colors.grey.shade900,
                    ],
                    isActive: currentRoute == AdminRoutes.attendanceToday,
                    onTap: () => Get.toNamed(AdminRoutes.attendanceToday),
                  ),

                  SizedBox(height: 12.h),

                  // ==================== LOGOUT CARD ====================
                  _actionCard(
                    title: "Logout",
                    subtitle: "Exit from your account",
                    icon: Icons.logout,
                    gradient: [
                      Colors.red.shade600,
                      Colors.red.shade900,
                    ],
                    isActive: false,
                    onTap: () async{
                      // TODO: clear storage/session if needed
                      Get.offAllNamed(AdminRoutes.LOGIN);
                      Get.snackbar("LogOut", "You have been logged out successfully.",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      await PrefManager().clearPref();
                    },
                  ),
                ],
              ),
            ),

            // ==================== EXTRA MENU ITEMS (optional) ====================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    // keep empty as your previous code
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ HomeScreen style card
  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
          border: isActive
              ? Border.all(color: Colors.white.withOpacity(0.65), width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              height: 44.h,
              width: 44.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
