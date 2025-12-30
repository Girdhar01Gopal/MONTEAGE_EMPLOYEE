// infrastructure/routes/admin_routes.dart
import 'package:get/get.dart';
import 'package:monteage_employee/screens/permission_boot_screen.dart';
import '../../bindings/FaceRegisterBinding.dart';
import '../../bindings/NotificationBinding.dart';
import '../../bindings/attendance_binding.dart';
import '../../bindings/attendance_history_binding.dart';
import '../../bindings/attendance_today_binding.dart';
import '../../bindings/check_out_attendance_binding.dart';
import '../../bindings/home_binding.dart';
import '../../bindings/login_binding.dart';
import '../../bindings/mark_face_attendance_binding.dart';
import '../../bindings/profile_binding.dart';
import '../../bindings/register_binding.dart';
import '../../screens/FaceRegisterScreen.dart';
import '../../screens/NotificationScreen.dart';
import '../../screens/admin_splash_screen.dart';
import '../../screens/attendance_details_page.dart';
import '../../screens/attendance_history_screen.dart';
import '../../screens/attendance_today_screen.dart';
import '../../screens/check_out_attendance_screen.dart';
import '../../screens/employee_profile_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/mark_face_attendance_screen.dart';
import '../../screens/register_screen.dart';

class AdminRoutes {
  // ==================
  // Route Names
  // ==================
  static const ADMIN_SPLASH = '/admin/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const NOTIFICATIONS = '/notifications';
  static const MARK_FACE_ATTENDANCE = "/mark-face-attendance";
  static const attendanceDetails = '/attendance-details';
  static const attendanceHistory = "/attendance-history";
  static const  registerScreen = '/register';
  static const  faceRegister = '/face-register';
  static const attendanceToday = "/attendance-today";
  static const BOOT = "/boot";
  static const checkoutattendace = "/checkoutattendace";
  static const profile = "/profile";







  // ==================
  // Route Definitions
  // ==================
  static final List<GetPage> routes = [
    // ---------- SPLASH ----------
    GetPage(
      name: ADMIN_SPLASH,
      page: () => AdminSplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),

  GetPage(
      name: BOOT,
      page: () => PermissionBootScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 200),
    ),

    // ---------- LOGIN ----------
    GetPage(
      name: LOGIN,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: MARK_FACE_ATTENDANCE,
      page: () => MarkFaceAttendanceScreen(),
      binding: MarkFaceAttendanceBinding(),
    ),

    GetPage(
      name: profile,
      page: () => EmployeeProfileScreen(),
      binding: EmployeeProfileBinding(),
    ),

    GetPage(
      name: checkoutattendace,
      page: () => CheckOutAttendanceScreen(),
      binding: checkoutAttendanceBinding(),
    ),



    // ---------- HOME ----------
    GetPage(
      name: HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),


    // ---------- NOTIFICATIONS ----------
    GetPage(
      name: NOTIFICATIONS,
      page: () => NotificationScreen(),
      binding: NotificationBinding(),
    ),

    GetPage(
      name: attendanceDetails,
      page: () =>  AttendanceDetailsPage(),
      binding: AttendanceBinding(),
    ),

    GetPage(
      name: attendanceHistory,
      page: () =>  AttendanceHistoryScreen(),
      binding: AttendanceHistoryBinding(),
    ),

    GetPage(
      name: registerScreen,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
    ),

    GetPage(
      name: faceRegister,
      page: () =>  FaceRegisterScreen(),
      binding: FaceRegisterBinding(),
    ),

    GetPage(
      name: attendanceToday,
      page: () =>  AttendanceTodayScreen(),
      binding: AttendanceTodayBinding(),
    ),

  ];
}
