import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  var email = '';
  var password = '';
  var isLoading = false.obs;
  var errorMessage = ''.obs; // Added to display error message

  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validEmail(String value) {
    if (!GetUtils.isEmail(value.trim())) {
      return "Please Provide a Valid Email";
    }
    return null;
  }

  String? validPassword(String value) {
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    isLoading.value = true;
    errorMessage.value = ''; // Clear any previous errors

    formKey.currentState!.save();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      ).then((value) {
        Get.offAllNamed('/main_screen');
      });
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      // Logging the error code to check if it's being correctly caught
      print('FirebaseAuthException Code: ${e.code}');

      // Error message handling based on FirebaseAuthException code
      if (e.code == 'user-not-found') {
        errorMessage.value = 'Email is incorrect';
      } else if (e.code == 'wrong-password') {
        errorMessage.value = 'Password is incorrect';
      } else if (e.code == 'invalid-credential') {
        errorMessage.value = 'Invalid credentials provided. Please try again.';
      } else {
        errorMessage.value = 'An unexpected error occurred';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred';
      print('Catch Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
