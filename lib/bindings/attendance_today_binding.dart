import 'package:get/get.dart';
import '../controllers/attendance_today_controller.dart';

class AttendanceTodayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceTodayController>(
            () => AttendanceTodayController());
  }
}
