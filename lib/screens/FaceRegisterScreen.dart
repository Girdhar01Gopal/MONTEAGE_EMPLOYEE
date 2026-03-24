import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/FaceRegisterController.dart';

class FaceRegisterScreen extends StatelessWidget {
  const FaceRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ ensure single instance
    if (!Get.isRegistered<FaceRegisterController>()) {
      Get.put(FaceRegisterController());
    }
    final controller = Get.find<FaceRegisterController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F1ED),
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(16.r),
                child: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFF6A3027),
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Face Registration",
              style: GoogleFonts.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917),
              ),
            ),
            Text(
              "Register your face for attendance",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF8B7D77),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),

            Obx(() {
              final File? img = controller.selectedImage.value;

              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF1E8E5A),
                        width: 2.5,
                      ),
                      color: Colors.white,
                      image: img != null
                          ? DecorationImage(
                              image: FileImage(img),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: img == null
                        ? Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 72.sp,
                              color: const Color(0xFF1E8E5A),
                            ),
                          )
                        : null,
                  ),

                  if (img != null)
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: _circleIcon(
                        icon: Icons.close,
                        onTap: controller.clearPhoto,
                      ),
                    ),
                ],
              );
            }),

            SizedBox(height: 20.h),

            Text(
              "Capture Your Face",
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241917),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Make sure your face is clearly visible and well-lit",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF8B7D77),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton.icon(
                onPressed: controller.takePhoto,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8E5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.camera_alt_rounded, size: 22.sp),
                label: Text(
                  "Take Photo",
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            Obx(() {
              final loading = controller.isSubmitting.value;
              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: loading ? null : controller.submitRegistration,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3027),
                    disabledBackgroundColor: const Color(0xFFC9C9C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: loading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.check_circle_outline, size: 20.sp),
                  label: Text(
                    loading ? "Registering..." : "Submit Registration",
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: const Color(0xFF1E8E5A)),
      ),
    );
  }
}
