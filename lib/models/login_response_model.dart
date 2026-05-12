import 'package:monteage_employee/models/login_employee_model.dart';
class LoginResponseModel {
  final String message;
  final int statuscode;
  final LoginEmployeeModel? data;

  LoginResponseModel({
    required this.message,
    required this.statuscode,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? '',
      statuscode: json['statuscode'] ?? 0,
      data: json['data'] != null
          ? LoginEmployeeModel.fromJson(json['data'])
          : null,
    );
  }
}