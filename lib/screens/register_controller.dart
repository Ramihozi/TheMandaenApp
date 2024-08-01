import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var selectedImagePath = ''.obs;
  final isLoading = false.obs;
  final isAgreed = false.obs; // Observable for agreement checkbox

  String? name;
  String? email;
  String? password;

  @override
  void onInit() {
    super.onInit();
    // Initialize or reset any necessary values here
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    // Clear the image path when the controller is closed
    selectedImagePath.value = '';
    super.onClose();
  }

  void updateImagePath(String path) {
    selectedImagePath.value = path;
  }

  void resetImagePath() {
    selectedImagePath.value = '';
  }

  String? validName(String value) {
    if (value.trim().isEmpty) {
      return "Name is required";
    }
    return null;
  }

  String? validEmail(String value) {
    if (!GetUtils.isEmail(value.trim())) {
      return "Please provide a valid email";
    }
    return null;
  }

  String? validPassword(String value) {
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> userRegister() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (selectedImagePath.value.isEmpty) {
      Get.snackbar(
        'Image Required',
        'Please upload a profile picture to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    formKey.currentState?.save();

    try {
      String? imageUrl = await uploadFile();
      if (imageUrl != null) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await saveDataToDb(imageUrl);
        isLoading.value = false;
        Get.offAllNamed('/login_screen');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar(
          'Email In Use',
          'The email address is already in use by another account.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          e.message ?? 'An unknown error occurred.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      isLoading.value = false;
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'An unknown error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  void toggleAgreement(bool? value) {
    isAgreed.value = value ?? false;
  }

  Future<String?> uploadFile() async {
    File file = File(selectedImagePath.value);
    FirebaseStorage storage = FirebaseStorage.instance;

    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    String randomStr = String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    try {
      await storage
          .ref('uploads/pic/$randomStr')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
      return null;
    }

    String downloadURL = await storage
        .ref('uploads/pic/$randomStr')
        .getDownloadURL();

    return downloadURL;
  }

  Future<void> saveDataToDb(String url) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text,
        'email': emailController.text,
        'url': url,
        'blockedUsers': [] // Initialize blockedUsers as an empty list
      });
    }
  }
}
