// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../infrastructure/app_drawer/admin_drawer.dart';
import '../infrastructure/routes/admin_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer(),
      backgroundColor: const Color(0xFFF6F1F3),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF8A80),
                Color(0xFFE57373),
                Color(0xFFE53935),
                Color(0xFFB71C1C),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text(
          "MONTEAGE",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_none, color: Colors.white),
        //     onPressed: () => Get.toNamed(AdminRoutes.NOTIFICATIONS),
        //   ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            // Date Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 44.h,
                    width: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.calendar_month, color: Colors.white),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                        () => Text(
                      "Today • ${controller.selectedDate.value}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 22.h),

            // 🔹 Mark Attendance Card
            _actionCard(
              title: "Mark Attendance",
              subtitle: "Face verification & location based",
              icon: Icons.face_retouching_natural,
              gradient: const [
                Color(0xFF16A34A),
                Color(0xFF22C55E),
              ],
              onTap: () => Get.toNamed(AdminRoutes.MARK_FACE_ATTENDANCE),
            ),

            SizedBox(height: 16.h),

            // 🔹 Attendance History Card
            _actionCard(
              title: "Attendance History",
              subtitle: "View daily attendance records",
              icon: Icons.history,
              gradient: const [
                Color(0xFF2563EB),
                Color(0xFF3B82F6),
              ],
              onTap: () => Get.toNamed(AdminRoutes.attendanceHistory),
            ),
            SizedBox(height: 22.h),

            // 🔹 Mark Attendance Card
            _actionCard(
              title: "Today's Attendance",
              subtitle: "Verification status & details",
              icon: Icons.fact_check,
              gradient: [
                Colors.grey.shade700,
                Colors.grey.shade900,
              ],
              onTap: () => Get.toNamed(AdminRoutes.attendanceToday),
            ),

          ],
        ),
      ),
    );
  }

  // 🔥 Reusable Action Card Widget
  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
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
        ),
        child: Row(
          children: [
            Container(
              height: 46.h,
              width: 46.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
