import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_today.dart';
import '../screens/login_screen.dart';

class AttendanceTodayController extends GetxController {
  final box = GetStorage();

  final todayApi = "http://103.251.143.196/attendance/api/attendance/today/";
  final refreshApi = "http://103.251.143.196/attendance/api/auth/refresh/";

  final isLoading = false.obs;
  final Rxn<AttendanceToday> today = Rxn<AttendanceToday>();

  // Image storage for marked attendance
  final Rx<File?> markedAttendanceImage = Rx<File?>(null);

  String get _access => (box.read("access_token") ?? "").toString().trim();
  String get _refresh => (box.read("refresh_token") ?? "").toString().trim();

  @override
  void onInit() {
    super.onInit();
    fetchToday();
  }

  Future<void> fetchToday() async {
    isLoading.value = true;
    try {
      final res = await _authorizedGet(Uri.parse(todayApi));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        today.value = AttendanceToday.fromJson(decoded);

        // Assuming the image path is returned in the API response
        final imagePath = decoded['markedImage']; // Path to the image
        if (imagePath != null) {
          markedAttendanceImage.value = File(imagePath);
        }

        print(today.value);
        return;
      }

      if (res.statusCode == 401) {
        _logout();
        return;
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    final res = await http.get(
      uri,
      headers: {"Authorization": "Bearer $_access", "Accept": "application/json"},
    );

    if (res.statusCode != 401) return res;

    final ok = await _refreshToken();
    if (!ok) return res;

    return http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${(box.read("access_token") ?? "").toString()}",
        "Accept": "application/json"
      },
    );
  }

  Future<bool> _refreshToken() async {
    if (_refresh.isEmpty) return false;

    final res = await http.post(
      Uri.parse(refreshApi),
      headers: const {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({"refresh": _refresh}),
    );

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(res.body);
    final newAccess = decoded["access"]?.toString() ?? "";
    if (newAccess.isEmpty) return false;

    await box.write("access_token", newAccess);
    return true;
  }

  void _logout() {
    box.erase();
    Get.offAll(() => const LoginScreen());
    Get.snackbar("Session Expired", "Please login again");
  }
}
