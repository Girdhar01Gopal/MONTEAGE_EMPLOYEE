import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  // ✅ Fixed current date
  final selectedDate = DateFormat("dd-MM-yyyy").format(DateTime.now()).obs;
}
