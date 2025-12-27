import 'package:get/get.dart';
import '../controllers/check_out_attendance_controller.dart';
import '../controllers/mark_face_attendance_controller.dart';

class checkoutAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<checkoutAttendanceController>(
          () => checkoutAttendanceController(),
    );
  }
}
