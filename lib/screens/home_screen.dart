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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Get.toNamed(AdminRoutes.NOTIFICATIONS),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: ListView(
          children: [
            //  Fixed current date (below AppBar) - improved display
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
                  )
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
                  Obx(() => Text(
                    "Today • ${controller.selectedDate.value}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF444444),
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            //  Work From Home Toggle Card (NEW)
            Obx(() {
              final wfh = controller.isWorkFromHome.value;
              return InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: controller.toggleWorkFromHome,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
                    border: Border.all(
                      color: wfh ? const Color(0xFF16A34A) : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44.h,
                        width: 44.h,
                        decoration: BoxDecoration(
                          color: wfh ? const Color(0xFF16A34A) : const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(Icons.home_work, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Work From Home",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF444444),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              wfh ? "Enabled" : "Disabled",
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: wfh
                              ? const Color(0xFF16A34A).withOpacity(0.12)
                              : const Color(0xFFE53935).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          wfh ? "ON" : "OFF",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            color: wfh ? const Color(0xFF16A34A) : const Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 16.h),

            // Stats row 1
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "Active",
                      value: controller.active.value.toString(),
                      icon: Icons.groups,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _statCard(
                      title: "Holiday",
                      value: controller.holiday.value.toString(),
                      icon: Icons.beach_access,
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: 12.h),

            // Stats row 2
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "Present",
                      value: controller.present.value.toString(),
                      icon: Icons.how_to_reg,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _statCard(
                      title: "Absent",
                      value: controller.absent.value.toString(),
                      icon: Icons.location_off,
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: 12.h),

            // Check In / Check Out (tap -> clock -> set time)
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: controller.pickCheckInTime,
                      child: _statCard(
                        title: "Check In",
                        value: controller.checkInTime.value,
                        icon: Icons.login,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: controller.pickCheckOutTime,
                      child: _statCard(
                        title: "Check Out",
                        value: controller.checkOutTime.value,
                        icon: Icons.logout,
                      ),
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: 10.h),

            // See More
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Get.toNamed(AdminRoutes.MARK_FACE_ATTENDANCE),
                child: Text(
                  "Mark attendance here",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ✅ Donut Card (kept exactly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Head Count & Attendance Statistics",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF555555),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Center(
                    child: Obx(() {
                      return _DonutRing(
                        centerValue: controller.active.value.toString(),
                        centerLabel: "Active",
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _legendDot("Present", controller.present.value.toString(),
                            const Color(0xFF2E7D32)),
                        _legendDot("Absent", controller.absent.value.toString(),
                            const Color(0xFFE53935)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // unchanged widgets
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: const Color(0xFF222222),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFFF3F3F3),
            child: Icon(icon, color: const Color(0xFFE53935)),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, String value, Color dotColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF666666),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Container(
              height: 12.w,
              width: 12.w,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        )
      ],
    );
  }
}

//  KEEP THIS AS-IS (same as your code)
class _DonutRing extends StatelessWidget {
  final String centerValue;
  final String centerLabel;

  const _DonutRing({
    required this.centerValue,
    required this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      width: 220.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 200.h,
            width: 200.h,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 22.w,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFEDEDED)),
            ),
          ),
          ShaderMask(
            shaderCallback: (rect) => const SweepGradient(
              colors: [
                Color(0xFFFF8A80),
                Color(0xFFE57373),
                Color(0xFFE53935),
                Color(0xFFB71C1C),
              ],
            ).createShader(rect),
            child: SizedBox(
              height: 200.h,
              width: 200.h,
              child: const CircularProgressIndicator(
                value: 1,
                strokeWidth: 22,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF555555),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                centerLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
