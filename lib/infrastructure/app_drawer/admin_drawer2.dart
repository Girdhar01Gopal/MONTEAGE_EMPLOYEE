import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../infrastructure/routes/admin_routes.dart';
import '../../utils/constants/color_constants.dart';

class AdminDrawer2 extends StatefulWidget {
  @override
  _AdminDrawer2State createState()  => _AdminDrawer2State();
}

class _AdminDrawer2State extends State<AdminDrawer2> {
  String? hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            /// ===== Custom Header =====
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/drawer_bg_pattern.png'), // optional background
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Red Diagonal Band
                  Positioned(
                    right: -50,
                    top: 0,
                    child: Transform.rotate(
                      angle: -0.4,
                      child: Container(
                        width: 180.w,
                        height: 300.h,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),

                  // Profile Info
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 45, color: Colors.white70),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ===== Drawer Items =====
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: [
                    // _buildDrawerItem(
                    //   "Discussion List",
                    //   Icons.list_alt,
                    //   AdminRoutes.LOADING_SCREEN,
                    //   currentRoute,
                    // ),
                    // _buildDrawerItem(
                    //   "Login page",
                    //   Icons.login,
                    //   //AdminRoutes.LOADING_SCREEN,
                    //   currentRoute,
                    // ),
                    // _buildDrawerItem(
                    //   "Reset",
                    //   Icons.refresh_rounded,
                    //   //AdminRoutes.LOADING_SCREEN,
                    //   currentRoute,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== Drawer Item Widget =====
  Widget _buildDrawerItem(
      String title,
      IconData icon,
      String route,
      String currentRoute, {
        bool isLogout = false,
      }) {
    final isSelected = currentRoute == route;
    final isHovered = hoveredRoute == route;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: Container(
        color: isSelected
            ? AppColor.grey_200
            : isHovered
            ? AppColor.grey_100
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(
            icon,
            color: isLogout
                ? Colors.red
                : isSelected
                ? AppColor.APP_Color_Indigo
                : isHovered
                ? AppColor.APP_Color_Pink
                : Colors.grey.shade800,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout
                  ? Colors.red
                  : isSelected
                  ? AppColor.APP_Color_Indigo
                  : isHovered
                  ? AppColor.APP_Color_Pink
                  : Colors.black,
              fontWeight:
              isLogout || isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onTap: () {
            if (isLogout) {
              GetStorage().erase();
              //Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
            } else if (!isSelected) {
              Get.toNamed(route);
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }
}
