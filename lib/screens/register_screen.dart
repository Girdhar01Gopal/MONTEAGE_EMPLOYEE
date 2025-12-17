import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 18.h),

              Image.asset(
                "assets/images/monteage_logo.png",
                height: 60.h,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 18.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Please sign up to continue",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),

                    SizedBox(height: 18.h),

                    Form(
                      key: c.formKey,  // Use the form key here
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label("Username"),
                          _Input(
                            controller: c.usernameController,
                            hint: "Enter Username",
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),

                          _Label("Email"),
                          _Input(
                            controller: c.emailController,
                            hint: "Enter Email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                      //    SizedBox(height: 14.h),

                          _Label("EmployeeId"),
                          _Input(
                            controller: c.EmployeeIdc,
                            hint: "Enter Your EmployeeId",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'EmployeeId is required';
                              }
                              if (!GetUtils.isNum(value)) {
                                return 'EmployeeId a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),

                          _Label("Password"),
                          Obx(() {
                            return _Input(
                              controller: c.passwordController,
                              hint: "Enter Password",
                              obscure: c.isPasswordHidden.value,
                              suffix: IconButton(
                                onPressed: c.togglePassword,
                                icon: Icon(
                                  c.isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            );
                          }),

                          SizedBox(height: 14.h),

                          _Label("Confirm Password"),
                          Obx(() {
                            return _Input(
                              controller: c.password2Controller,
                              hint: "Confirm Password",
                              obscure: c.isPassword2Hidden.value,
                              suffix: IconButton(
                                onPressed: c.togglePassword2,
                                icon: Icon(
                                  c.isPassword2Hidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirm password is required';
                                }
                                if (value != c.passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            );
                          }),

                          SizedBox(height: 10.h),

                          SizedBox(height: 18.h),

                          Obx(() {
                            return _GradientElevatedButton(
                              text: "Sign Up",
                              loading: c.isLoading.value,
                              onTap: c.isLoading.value ? null : c.registerUser,
                            );
                          }),

                          SizedBox(height: 10.h),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => LoginScreen());  // Navigate to LoginScreen
                              },
                              child: Text(
                                "Already have an account? Login",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3D3D3D),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // Label widget for text fields
  Widget _Label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A4A4A),
        ),
      ),
    );
  }

  // Input widget for text fields
  Widget _Input({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFB0B0B0), fontSize: 13.sp),
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}

// Gradient Elevated Button Widget
class _GradientElevatedButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onTap;

  const _GradientElevatedButton({
    required this.text,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        elevation: 10,
        shadowColor: const Color(0x55E53935),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF8A80),
                  Color(0xFFE57373),
                  Color(0xFFE53935),
                  Color(0xFFB71C1C),
                ],
              ),
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
