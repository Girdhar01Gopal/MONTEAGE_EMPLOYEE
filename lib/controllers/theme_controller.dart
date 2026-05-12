import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Observable variable for theme state (dark or light mode)
  var isDark = false.obs;

  // Toggle function to switch between light and dark mode
  void toggle() {
    isDark.value = !isDark.value;
  }
}