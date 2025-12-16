import 'package:get/get.dart';
import '../controllers/mark_face_attendance_controller.dart';

class MarkFaceAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarkFaceAttendanceController>(
          () => MarkFaceAttendanceController(),
    );
  }
}
