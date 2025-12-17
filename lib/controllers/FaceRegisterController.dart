import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class FaceRegisterController extends GetxController {
  var selectedImage = Rx<File?>(null);
  var isSubmitting = false.obs;

  final String faceRegisterUrl = "http://115.241.73.226/attendance/api/face/register/";

  // To pick the image from the camera
  Future<void> takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // To clear the selected image
  void clearPhoto() {
    selectedImage.value = null;
  }

  // To submit the face registration
  Future<void> submitRegistration() async {
    if (selectedImage.value == null) {
      Get.snackbar('Error', 'Please upload your face image first.');
      return;
    }

    isSubmitting.value = true;

    try {
      // Prepare the multipart request
      final request = http.MultipartRequest('POST', Uri.parse(faceRegisterUrl));
      final token = _getToken();  // Get the saved token

      // Add the headers and image file
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage.value!.path));

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Face registered successfully!');
        isSubmitting.value = false;
        // Navigate to HomeScreen after successful registration
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Failed to register face: $responseBody');
        isSubmitting.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Face registration failed: $e');
      isSubmitting.value = false;
    }
  }

  // Function to get the access token
  String _getToken() {
    final token = GetStorage().read('access_token') ?? '';
    if (token.isEmpty) {
      throw Exception('Access token missing');
    }
    return token;
  }
}
