import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/mark_face_attendance_controller.dart';
import '../controllers/check_out_attendance_controller.dart';
import '../bindings/mark_face_attendance_binding.dart';
import '../bindings/check_out_attendance_binding.dart';
import '../widgets/bottom_nav_wrapper.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isCheckIn = true; // true = Check In, false = Check Out

  late final MarkFaceAttendanceController _checkInC;
  late final CheckOutAttendanceController _checkOutC;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MarkFaceAttendanceController>()) {
      MarkFaceAttendanceBinding().dependencies();
    }
    if (!Get.isRegistered<CheckOutAttendanceController>()) {
      checkoutAttendanceBinding().dependencies();
    }
    _checkInC = Get.find<MarkFaceAttendanceController>();
    _checkOutC = Get.find<CheckOutAttendanceController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInC.ensureLocationFetched();
      _checkOutC.ensureLocationFetched();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      child: Scaffold(
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
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF241917)),
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
                'Attendance',
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF241917),
                ),
              ),
              Text(
                'Face verification & location',
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
              // ── Toggle at top ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DDD9),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    _ToggleTab(
                      label: 'Check In',
                      icon: Icons.login_rounded,
                      isActive: _isCheckIn,
                      activeColor: const Color(0xFF1E8E5A),
                      onTap: () => setState(() => _isCheckIn = true),
                    ),
                    _ToggleTab(
                      label: 'Check Out',
                      icon: Icons.logout_rounded,
                      isActive: !_isCheckIn,
                      activeColor: const Color(0xFFC75B2A),
                      onTap: () => setState(() => _isCheckIn = false),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // ── Content based on toggle ────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: _isCheckIn
                    ? _CheckInBody(c: _checkInC, key: const ValueKey('checkin'))
                    : _CheckOutBody(c: _checkOutC, key: const ValueKey('checkout')),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// ── Toggle Tab Widget ──────────────────────────────────────────────────────

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isActive ? Colors.white : const Color(0xFF8B7D77),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : const Color(0xFF8B7D77),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Check In Body ──────────────────────────────────────────────────────────

class _CheckInBody extends StatelessWidget {
  const _CheckInBody({required this.c, super.key});
  final MarkFaceAttendanceController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final File? img = c.selectedImage.value;
          return _PhotoBox(
            img: img,
            accentColor: const Color(0xFF1E8E5A),
            latText: c.latText.value,
            lngText: c.lngText.value,
            isLocLoading: c.isLocLoading.value,
            onLocation: c.fetchLocationAll,
            onClear: img != null ? c.clearPhoto : null,
          );
        }),
        SizedBox(height: 20.h),
        _SectionLabel(title: 'Capture Your Face', subtitle:
            'Take a clear, well-lit photo showing your full face. Make sure there are no shadows or glare.'),
        SizedBox(height: 18.h),
        _PhotoButton(
          label: 'Take Photo',
          color: const Color(0xFF1E8E5A),
          onTap: c.takePhoto,
        ),
        SizedBox(height: 20.h),
        _LocationCard(addressText: c.addressText),
        SizedBox(height: 20.h),
        Obx(() {
          final loading = c.isSubmittingAttendance.value;
          return _SubmitButton(
            label: 'Submit Attendance',
            color: const Color(0xFF6A3027),
            isLoading: loading,
            onTap: loading ? null : c.submitAttendance,
          );
        }),
      ],
    );
  }
}

// ── Check Out Body ─────────────────────────────────────────────────────────

class _CheckOutBody extends StatelessWidget {
  const _CheckOutBody({required this.c, super.key});
  final CheckOutAttendanceController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final File? img = c.selectedImage.value;
          return _PhotoBox(
            img: img,
            accentColor: const Color(0xFFC75B2A),
            latText: c.latText.value,
            lngText: c.lngText.value,
            isLocLoading: c.isLocLoading.value,
            onLocation: c.fetchLocationAll,
            onClear: img != null ? c.clearPhoto : null,
          );
        }),
        SizedBox(height: 20.h),
        _SectionLabel(title: 'Capture Your Face', subtitle:
            'Take a clear, well-lit photo showing your full face. Make sure there are no shadows or glare.'),
        SizedBox(height: 18.h),
        _PhotoButton(
          label: 'Take Photo',
          color: const Color(0xFFC75B2A),
          onTap: c.takePhoto,
        ),
        SizedBox(height: 20.h),
        _LocationCard(addressText: c.addressText),
        SizedBox(height: 20.h),
        Obx(() {
          final loading = c.isSubmittingAttendance.value;
          return _SubmitButton(
            label: 'Submit Checkout',
            color: const Color(0xFF6A3027),
            isLoading: loading,
            onTap: loading ? null : c.submitCheckoutAttendance,
          );
        }),
      ],
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.img,
    required this.accentColor,
    required this.latText,
    required this.lngText,
    required this.isLocLoading,
    required this.onLocation,
    required this.onClear,
  });

  final File? img;
  final Color accentColor;
  final String latText, lngText;
  final bool isLocLoading;
  final VoidCallback onLocation;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: double.infinity,
        height: 240.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
          color: Colors.white,
          image: img != null
              ? DecorationImage(image: FileImage(img!), fit: BoxFit.cover)
              : null,
          boxShadow: const [
            BoxShadow(color: Color(0x18000000), blurRadius: 22, offset: Offset(0, 10)),
          ],
        ),
        child: img == null
            ? Center(child: Icon(Icons.face_rounded, size: 80.sp, color: accentColor.withOpacity(0.3)))
            : null,
      ),
      Positioned(
        left: 12.w,
        bottom: 12.h,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            isLocLoading ? 'Fetching location...' : 'Lat: $latText | Lng: $lngText',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      Positioned(
        top: 12.h,
        left: 12.w,
        child: _CircleBtn(icon: Icons.my_location_rounded, onTap: onLocation, color: accentColor),
      ),
      if (onClear != null)
        Positioned(
          top: 12.h,
          right: 12.w,
          child: _CircleBtn(icon: Icons.close_rounded, onTap: onClear!, color: const Color(0xFFB54545)),
        ),
    ]);
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

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
          boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.manrope(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
      SizedBox(height: 6.h),
      Text(subtitle, style: GoogleFonts.inter(fontSize: 13.sp, height: 1.5, fontWeight: FontWeight.w500, color: const Color(0xFF756A66))),
    ]);
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        ),
        icon: const Icon(Icons.camera_alt_rounded),
        label: Text(label, style: GoogleFonts.manrope(fontSize: 16.sp, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.addressText});
  final RxString addressText;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Location Details', style: GoogleFonts.manrope(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF241917))),
      SizedBox(height: 12.h),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFEDE2DC), width: 1),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 7))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 48.h,
            width: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0F9D9A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Icon(Icons.location_on_outlined, color: Color(0xFF0F9D9A)),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Current Location', style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF8B7D77))),
              SizedBox(height: 6.h),
              Text(addressText.value, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13.sp, height: 1.45, fontWeight: FontWeight.w500, color: const Color(0xFF5F5450))),
            ])),
          ),
        ]),
      ),
    ]);
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.label, required this.color, required this.isLoading, required this.onTap});
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        ),
        child: isLoading
            ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label, style: GoogleFonts.manrope(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}