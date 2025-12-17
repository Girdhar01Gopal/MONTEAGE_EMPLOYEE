import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/mark_face_attendance_controller.dart';

class MarkFaceAttendanceScreen extends StatelessWidget {
  const MarkFaceAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarkFaceAttendanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFFE53935), size: 22.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Mark Face Attendance",
          style: TextStyle(
            color: const Color(0xFF555555),
            fontWeight: FontWeight.w800,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),

            Obx(() {
              final File? img = c.selectedImage.value;

              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 220.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: const Color(0xFFE53935), width: 2),
                      color: Colors.white,
                      image: img != null
                          ? DecorationImage(
                          image: FileImage(img), fit: BoxFit.cover)
                          : null,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: img == null
                        ? Center(
                      child: Icon(Icons.person_outline,
                          size: 80.sp,
                          color: const Color(0xFFE53935)),
                    )
                        : null,
                  ),

                  // lat/lng overlay
                  Positioned(
                    left: 12.w,
                    bottom: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Obx(() {
                        final loading = c.isLocLoading.value;
                        return Text(
                          loading
                              ? "Fetching location..."
                              : "Lat: ${c.latText.value}  |  Lng: ${c.lngText.value}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      }),
                    ),
                  ),

                  // refresh location
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: _circleIcon(
                      icon: Icons.my_location,
                      onTap: c.fetchLocationAll,
                    ),
                  ),

                  // clear photo
                  if (img != null)
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: _circleIcon(
                        icon: Icons.close,
                        onTap: c.clearPhoto,
                      ),
                    ),
                ],
              );
            }),

            SizedBox(height: 16.h),

            Text(
              "Take a Photo of you",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Please make sure your photo clearly shows your face",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF777777)),
            ),

            SizedBox(height: 22.h),

            _gradientButton(text: "Take Photo", onTap: c.takePhoto),
            SizedBox(height: 14.h),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 52.h),
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: c.uploadPhoto,
              child: Text(
                "Upload Photo",
                style: TextStyle(
                  color: const Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                  fontSize: 15.sp,
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // Address Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0x1AE53935)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFE53935)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(() => Text(
                      c.addressText.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF666666),
                        height: 1.25,
                      ),
                    )),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // REGISTER FACE
            Obx(() {
              final loading = c.isRegisteringFace.value;
              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: loading ? null : c.registerFace,
                  child: loading
                      ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    "Register Face",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 12.h),

            // SUBMIT ATTENDANCE
            Obx(() {
              final loading = c.isSubmittingAttendance.value;
              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: loading ? null : c.submitAttendance,
                  child: loading
                      ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    "Submit Attendance",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
        padding: EdgeInsets.all(7.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Icon(icon, size: 18.sp, color: const Color(0xFFE53935)),
      ),
    );
  }

  Widget _gradientButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        elevation: 10,
        shadowColor: const Color(0x55E53935),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: const LinearGradient(
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
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
