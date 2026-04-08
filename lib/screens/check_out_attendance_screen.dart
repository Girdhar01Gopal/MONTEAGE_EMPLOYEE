import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/check_out_attendance_controller.dart';

class CheckOutAttendanceScreen extends StatefulWidget {
  const CheckOutAttendanceScreen({super.key});

  @override
  State<CheckOutAttendanceScreen> createState() =>
      _CheckOutAttendanceScreenState();
}

class _CheckOutAttendanceScreenState extends State<CheckOutAttendanceScreen> {
  late final CheckOutAttendanceController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<CheckOutAttendanceController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.ensureLocationFetched();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 72.h,
        backgroundColor: const Color(0xFFF6F1ED),
        surfaceTintColor: Colors.transparent,
        leadingWidth: 72.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF241917),
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check Out Attendance',
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF241917),
                ),
              ),
              Text(
                'Face verification & location check-out',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF756A66),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              Obx(() {
                final File? img = c.selectedImage.value;

                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 240.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(
                          color: const Color(0xFF1E8E5A).withOpacity(0.3),
                          width: 2,
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
                            color: Color(0x18000000),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: img == null
                          ? Center(
                              child: Icon(
                                Icons.face_rounded,
                                size: 80.sp,
                                color: const Color(0xFF1E8E5A).withOpacity(0.3),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      left: 12.w,
                      bottom: 12.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          final loading = c.isLocLoading.value;
                          return Text(
                            loading
                                ? 'Fetching location...'
                                : 'Lat: ${c.latText.value} | Lng: ${c.lngText.value}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: _CircleActionButton(
                        icon: Icons.my_location_rounded,
                        onTap: c.fetchLocationAll,
                        accentColor: const Color(0xFF1E8E5A),
                      ),
                    ),
                    if (img != null)
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: _CircleActionButton(
                          icon: Icons.close_rounded,
                          onTap: c.clearPhoto,
                          accentColor: const Color(0xFFB54545),
                        ),
                      ),
                  ],
                );
              }),
              SizedBox(height: 20.h),
              Text(
                'Capture Your Face',
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF241917),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Take a clear, well-lit photo showing your full face. Make sure there are no shadows or glare.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF756A66),
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton.icon(
                  onPressed: c.takePhoto,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8E5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(
                    'Take Photo',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Location Details',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF241917),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFEDE2DC), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48.h,
                      width: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F9D9A).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF0F9D9A),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Location',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8B7D77),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              c.addressText.value,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5F5450),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Obx(() {
                final loading = c.isSubmittingAttendance.value;
                return SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton(
                    onPressed: loading ? null : c.submitCheckoutAttendance,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6A3027),
                      disabledBackgroundColor: const Color(
                        0xFF6A3027,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: loading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Submit Checkout',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    required this.accentColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: accentColor),
      ),
    );
  }
}