import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as log;

class AddPostController extends GetxController {
  RxBool isImgAvailable = false.obs;
  final _picker = ImagePicker();
  RxString selectedImagePath = ''.obs;
  RxString selectedImageSize = ''.obs;
  RxBool isLoading = false.obs;

  late TextEditingController postTxtController;
  CollectionReference userDatBaseReference =
  FirebaseFirestore.instance.collection("post");

  @override
  void onInit() {
    super.onInit();
    postTxtController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    postTxtController.dispose();
  }

  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;

      selectedImageSize.value =
      "${((File(selectedImagePath.value)).lengthSync() / 1024 / 1024).toStringAsFixed(2)} Mb";

      isImgAvailable.value = true;
    } else {
      isImgAvailable.value = false;
    }
  }

  Future<String?> uploadImage() async {
    File file = File(selectedImagePath.value);
    FirebaseStorage storage = FirebaseStorage.instance;

    // Generate a random string for image name
    String randomStr = getRandomString(8);

    try {
      // Upload image to Firebase Storage
      await storage.ref('uploads/post/$randomStr').putFile(file);
      // Get download URL for the uploaded image
      String downloadURL =
      await storage.ref('uploads/post/$randomStr').getDownloadURL();
      return downloadURL;
    } catch (e) {
      log.log('Error uploading image: $e');
      return null;
    }
  }

  String getRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> addPost({required String userName, required String userUrl}) async {
    if (isImgAvailable.value && postTxtController.text.isNotEmpty) {
      isLoading.value = true;

      // Upload image and get download URL
      String? imageUrl = await uploadImage();

      if (imageUrl != null) {
        // Save post data to Firestore
        await saveDataToDb(
          url: imageUrl,
          userName: userName,
          userUrl: userUrl,
        );

        isLoading.value = false;

        // Clear text field and selected image path after posting
        postTxtController.text = '';
        selectedImagePath.value = '';
      } else {
        isLoading.value = false;
        Get.snackbar(
          "Error",
          "Failed to upload image",
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        "Warning",
        "Please enter details and select an image",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveDataToDb({
    required String url,
    required String userName,
    required String userUrl,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    await userDatBaseReference.add({
      'postTitle': postTxtController.text,
      'userUid': user!.uid,
      'userName': userName,
      'userUrl': userUrl,
      'postUrl': url,
      'time': DateTime.now().millisecondsSinceEpoch,
      'likes': [],
      'commentsCount': 0,
    });
  }
}
