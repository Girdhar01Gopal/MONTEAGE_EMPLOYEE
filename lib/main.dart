// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'infrastructure/routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MONTEAGE EMPLOYEE',
      debugShowCheckedModeBanner: false,
      getPages: AdminRoutes.routes,

      // ✅ Always start at boot to request permission first
      initialRoute: AdminRoutes.BOOT,

      theme: ThemeData(useMaterial3: true),

      builder: (context, child) {
        return ScreenUtilInit(
          designSize: const Size(411.42, 890.28),
          child: child!,
        );
      },
    );
  }
}
