import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/attendance_history_controller.dart';
import '../models/attendance_history_model.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceHistoryController());

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
                'Attendance History',
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF241917),
                ),
              ),
              Text(
                'Review your attendance records',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF756A66),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Container(
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
                  Icons.search_rounded,
                  color: Color(0xFF241917),
                ),
                onPressed: () => _showSearchDialog(context, c),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Obx(() {
              final s = c.statistics.value;
              if (s == null) return SizedBox(height: 16.h);

              return Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: const Color(0xFFEDE2DC),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 14,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatTile(
                        label: 'Total',
                        value: (s.total ?? 0).toString(),
                        icon: Icons.view_agenda_rounded,
                        accentColor: const Color(0xFF6A3027),
                      ),
                      _StatTile(
                        label: 'Verified',
                        value: (s.verified ?? 0).toString(),
                        icon: Icons.check_circle_outline,
                        accentColor: const Color(0xFF2AB673),
                      ),
                      _StatTile(
                        label: 'Pending',
                        value: (s.pending ?? 0).toString(),
                        icon: Icons.schedule_rounded,
                        accentColor: const Color(0xFFF0A43C),
                      ),
                      _StatTile(
                        label: 'Rejected',
                        value: (s.rejected ?? 0).toString(),
                        icon: Icons.cancel_outlined,
                        accentColor: const Color(0xFFD85E5E),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading your records',
                          style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF241917),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (c.filteredRecords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 64.sp,
                          color: const Color(0xFF756A66).withOpacity(0.3),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No attendance records found',
                          style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF241917),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: c.fetchHistory,
                  color: const Color(0xFF6A3027),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: c.filteredRecords.length,
                    itemBuilder: (_, i) =>
                        _HistoryCard(record: c.filteredRecords[i], c: c),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSearchDialog(
    BuildContext context,
    AttendanceHistoryController c,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Search by Date',
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF241917),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: c.searchDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: 'dd-MM-yyyy',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: const Color(0xFFB0B0B0),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F1F1),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        c.clearFilter();
                        Get.back();
                      },
                      child: Text(
                        'Clear',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF756A66),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        c.applyDateFilter(c.searchDateController.text.trim());
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3027),
                      ),
                      child: Text(
                        'Search',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accentColor, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF241917),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B7D77),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Result record;
  final AttendanceHistoryController c;

  const _HistoryCard({required this.record, required this.c});

  Color _statusColor(String? s) {
    switch ((s ?? "").toUpperCase()) {
      case "VERIFIED":
        return const Color(0xFF2AB673);
      case "REJECTED":
        return const Color(0xFFD85E5E);
      case "PENDING":
      default:
        return const Color(0xFFF0A43C);
    }
  }

  Widget _kv(String k, String v, {Color? vColor, FontWeight? vWeight}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              k,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF8B7D77),
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: vColor ?? const Color(0xFF241917),
                fontWeight: vWeight ?? FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBlock(String title, String? url) {
    final full = c.fullImageUrl(url);
    if (full.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF241917),
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              full,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF1F1F1),
                alignment: Alignment.center,
                child: Text(
                  "Image unavailable",
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF8B7D77),
                  ),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFF1F1F1),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkInColor = _statusColor(record.status);
    final checkOutColor = _statusColor(record.checkoutStatus);

    final checkInTime = c.formatIsoTime(record.timestamp);
    final checkOutTime = c.formatIsoTime(record.checkoutTimestamp);
    final headerDate = c.formatToDdMmYyyy(record.date);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEDE2DC), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(dividerColor: const Color(0xFFF1F1F1)),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.all(16.w),
            collapsedIconColor: checkInColor,
            iconColor: checkInColor,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.titleCase(record.employeeName),
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF241917),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "ID: ${record.employeeId} • $headerDate",
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF8B7D77),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: checkInColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: checkInColor),
                    ),
                    child: Text(
                      record.status ?? "--",
                      style: GoogleFonts.manrope(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: checkInColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            children: [
              _kv("Username", c.titleCase(record.username)),
              _kv("Check-in Date", c.formatToDdMmYyyy(record.date)),
              _kv("Check-in Time", checkInTime),
              _kv("Face Confidence", record.confidenceScore.toStringAsFixed(3)),
              _kv("Face Detected", record.faceDetected ? "Yes" : "No"),
              _kv("Verified", record.isVerified ? "Yes" : "No"),
              Divider(height: 16.h, color: const Color(0xFFF1F1F1)),
              Text(
                "Check-in Location",
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF241917),
                ),
              ),
              SizedBox(height: 8.h),
              _kv("Latitude", (record.latitude ?? 0).toString()),
              _kv("Longitude", (record.longitude ?? 0).toString()),
              _kv(
                "Accuracy (m)",
                (record.locationAccuracy ?? 0).toStringAsFixed(1),
              ),
              _imageBlock("Check-in Photo", record.imageUrl),
              Divider(height: 20.h, color: const Color(0xFFF1F1F1)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Check-out Details",
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF241917),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: checkOutColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: checkOutColor),
                    ),
                    child: Text(
                      record.checkoutStatus ?? "--",
                      style: GoogleFonts.manrope(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: checkOutColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _kv("Checkout Date", c.formatToDdMmYyyy(record.checkoutDate)),
              _kv("Checkout Time", checkOutTime),
              _kv(
                "Checkout Confidence",
                record.checkoutConfidenceScore == null
                    ? "--"
                    : record.checkoutConfidenceScore!.toStringAsFixed(3),
              ),
              SizedBox(height: 12.h),
              Text(
                "Check-out Location",
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF241917),
                ),
              ),
              SizedBox(height: 8.h),
              _kv("Latitude", (record.checkoutLatitude ?? 0).toString()),
              _kv("Longitude", (record.checkoutLongitude ?? 0).toString()),
              _kv(
                "Accuracy (m)",
                (record.checkoutLocationAccuracy ?? 0).toStringAsFixed(1),
              ),
              _imageBlock("Check-out Photo", record.checkoutImageUrl),
              Divider(height: 20.h, color: const Color(0xFFF1F1F1)),
              _kv(
                "Duration",
                record.duration?.formatted ?? "--",
                vWeight: FontWeight.w700,
                vColor: const Color(0xFF6A3027),
              ),
              _kv("Total Seconds", record.duration?.seconds.toString() ?? "--"),
              if (record.isSuspicious) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD85E5E).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFD85E5E)),
                  ),
                  child: Text(
                    "⚠ Suspicious: ${record.suspiciousReason ?? "Yes"}",
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD85E5E),
                    ),
                  ),
                ),
              ],
              Divider(height: 20.h, color: const Color(0xFFF1F1F1)),
              _kv("Created", c.formatIsoDateTime(record.createdAt)),
              _kv("Updated", c.formatIsoDateTime(record.updatedAt)),
            ],
          ),
        ),
      ),
    );
  }
}
