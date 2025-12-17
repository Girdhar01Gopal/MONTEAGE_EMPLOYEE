import 'package:get/get.dart';
import '../controllers/attendance_history_controller.dart';

class AttendanceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AttendanceHistoryController(), permanent: false);
  }
}
