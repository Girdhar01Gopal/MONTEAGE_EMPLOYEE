// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
import '../infrastructure/app_drawer/admin_drawer.dart';
import '../infrastructure/routes/admin_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final EmployeeProfileController profileC =
  Get.put(EmployeeProfileController(), permanent: true);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer(),
      backgroundColor: Colors.white,
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            // ✅ Employee Profile Card (same as before)
            Obx(() {
              if (profileC.isLoading.value) {
                return Container(
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
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Loading profile...",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF444444),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => profileC.fetchProfile(showSuccess: false),
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  ),
                );
              }

              final p = profileC.profile.value;
              if (p == null) {
                return Container(
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
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(Icons.error_outline, color: Colors.red),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Profile not loaded",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF444444),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => profileC.fetchProfile(showSuccess: false),
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                );
              }

              final u = p.user;
              final imgUrl = profileC.fullImageUrl(u.profileImage);

              return Container(
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26.r,
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
                          child: ClipOval(
                            child: imgUrl.isEmpty
                                ? const Icon(Icons.person,
                                color: Color(0xFF6C63FF), size: 28)
                                : Image.network(
                              imgUrl,
                              width: 52.r,
                              height: 52.r,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Color(0xFF6C63FF),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileC.titleCase(
                                  u.fullName.isNotEmpty
                                      ? u.fullName
                                      : "${u.firstName} ${u.lastName}",
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Employee ID: ${u.employeeId}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                u.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF777777),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "Department: ${profileC.titleCase(u.department)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF555555),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => profileC.fetchProfile(showSuccess: false),
                          icon: const Icon(Icons.refresh),
                        )
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        const Spacer(),
                        Obx(
                              () => Text(
                            controller.selectedDate.value,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 18.h),

            // ✅ 2x2 Grid (rectangular cube style)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _gridCard(
                            title: "Mark Attendance",
                            subtitle: "Face & location",
                            icon: Icons.face_retouching_natural,
                            gradient: const [Color(0xFF16A34A), Color(0xFF22C55E)],
                            onTap: () => Get.toNamed(AdminRoutes.MARK_FACE_ATTENDANCE),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _gridCard(
                            title: "Attendance History",
                            subtitle: "Daily records",
                            icon: Icons.history,
                            gradient: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                            onTap: () => Get.toNamed(AdminRoutes.attendanceHistory),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: _gridCard(
                            title: "Today's Attendance",
                            subtitle: "Status & details",
                            icon: Icons.fact_check,
                            gradient: [Colors.grey.shade700, Colors.grey.shade900],
                            onTap: () => Get.toNamed(AdminRoutes.attendanceToday),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _gridCard(
                            title: "Check Out Attendance",
                            subtitle: "Face & location",
                            icon: Icons.logout_rounded,
                            gradient: const [Color(0xFFFF6F00), Color(0xFFFFA000)],
                            onTap: () => Get.toNamed(AdminRoutes.checkoutattendace),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Rectangular cube-style grid card
  Widget _gridCard({
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
        height: 120.h, // ✅ fixed height for cube look
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 42.h,
                  width: 42.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
