import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  // ✅ fixed current date
  final selectedDate = DateFormat("dd-MM-yyyy").format(DateTime.now()).obs;

  // stats
  final active = 0.obs;
  final holiday = 0.obs;
  final present = 0.obs;
  final absent = 0.obs;

  // ✅ default current time shown
  final checkInTime = "".obs;
  final checkOutTime = "".obs;

  // ✅ Work From Home toggle
  final isWorkFromHome = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setDefaultTimesToNow();
  }

  void _setDefaultTimesToNow() {
    final now = DateTime.now();
    final t = DateFormat("hh:mm a").format(now);
    checkInTime.value = t;
    checkOutTime.value = t;
  }

  // ✅ date fixed (no change)
  void pickDate() {}

  Future<void> pickCheckInTime() async {
    final picked = await _pickTime();
    if (picked == null) return;
    checkInTime.value = _formatTimeOfDay(picked);
  }

  Future<void> pickCheckOutTime() async {
    final picked = await _pickTime();
    if (picked == null) return;
    checkOutTime.value = _formatTimeOfDay(picked);
  }

  Future<TimeOfDay?> _pickTime() async {
    final ctx = Get.context;
    if (ctx == null) return null;

    return showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat("hh:mm a").format(dt);
  }

  // ✅ toggle WFH
  void toggleWorkFromHome() {
    isWorkFromHome.value = !isWorkFromHome.value;
  }
}
