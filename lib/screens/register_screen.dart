// screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/register_controller.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
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
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFEDE2DC), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Account",
                      style: GoogleFonts.manrope(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF241917),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Sign up to get started",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF8B7D77),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 18.h),

                    Form(
                      key: c.formKey, // Use the form key here
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label("First Name"),
                          _Input(
                            controller: c.firstNameController,
                            hint: "Enter First Name",
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First Name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _Label("Last Name"),
                          _Input(
                            controller: c.lastNameController,
                            hint: "Enter Last Name",
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last Name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _Label("Department"),
                          _Input(
                            controller: c.departmentController,
                            hint: "Enter Department",
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Department is required';
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
                                  color: const Color(0xFF8B7D77),
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
                                  color: const Color(0xFF8B7D77),
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
                            return _ModernButton(
                              text: "Sign Up",
                              loading: c.isLoading.value,
                              onTap: c.isLoading.value ? null : c.registerUser,
                            );
                          }),

                          SizedBox(height: 10.h),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => LoginScreen(),
                                ); // Navigate to LoginScreen
                              },
                              child: Text(
                                "Already have an account? Login",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6A3027),
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
        style: GoogleFonts.manrope(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF241917),
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
      style: GoogleFonts.inter(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFFB0B0B0),
          fontSize: 13.sp,
        ),
        filled: true,
        fillColor: const Color(0xFFF6F1ED),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFEDE2DC), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFEDE2DC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF6A3027), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

// Modern Button Widget
class _ModernButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onTap;

  const _ModernButton({
    required this.text,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6A3027),
          disabledBackgroundColor: const Color(0xFFC9C9C9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: loading
            ? SizedBox(
                height: 22.h,
                width: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
