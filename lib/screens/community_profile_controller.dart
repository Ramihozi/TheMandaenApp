import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // Add this import

class ProfileController extends GetxController {
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString url = ''.obs;
  RxList<Map<String, String>> blockedUsers = <Map<String, String>>[].obs;
  User? user = FirebaseAuth.instance.currentUser;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getUserData();
    listenToBlockedUsers();
  }

  Future<void> getUserData() async {
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("user")
          .doc(user!.uid)
          .get();
      name.value = documentSnapshot['name'];
      email.value = documentSnapshot['email'];
      url.value = documentSnapshot['url'];
    }
  }

  Future<void> updateProfilePicture(String filePath) async {
    try {
      // Upload the image to Firebase Storage
      File file = File(filePath);
      String storagePath = 'uploads/pic/${user!.uid}.jpg'; // Specify the path
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(storagePath)
          .putFile(file);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Update Firestore with the new profile picture URL
      await FirebaseFirestore.instance
          .collection("user")
          .doc(user!.uid)
          .update({
        'url': downloadURL,
      });

      // Update the local state
      url.value = downloadURL;

      // Optionally show a success message
      Get.snackbar('Success', 'Profile picture updated successfully');
    } catch (e) {
      print('Error updating profile picture: $e');
      Get.snackbar('Error', 'Failed to update profile picture');
    }
  }

  void listenToBlockedUsers() {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(user!.uid)
          .snapshots()
          .listen((documentSnapshot) {
        if (documentSnapshot.exists) {
          List<String> blockedUserIds = List<String>.from(documentSnapshot['blockedUsers'] ?? []);
          _fetchBlockedUsers(blockedUserIds);
        }
      });
    }
  }

  Future<void> _fetchBlockedUsers(List<String> userIds) async {
    List<Map<String, String>> users = [];
    for (String userId in userIds) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        users.add({
          'id': userId,
          'name': userDoc['name'] ?? 'Unknown',
        });
      }
    }
    blockedUsers.value = users;
  }

  Future<void> unblockUser(String userId) async {
    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .update({
          'blockedUsers': FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      print('Error unblocking user: $e');
      Get.snackbar('Error', 'Failed to unblock user');
    }
  }

  Future<void> deleteUserAccount(BuildContext context, String password) async {
    try {
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-signed-in', message: 'No user is signed in.');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user!.reauthenticateWithCredential(credential);

      await FirebaseFirestore.instance
          .collection("user")
          .doc(user!.uid)
          .delete();

      await user!.delete();

      await FirebaseAuth.instance.signOut();

      Get.offAllNamed('/login');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> changePassword(BuildContext context, String currentPassword, String newPassword) async {
    try {
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-signed-in', message: 'No user is signed in.');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user!.reauthenticateWithCredential(credential);

      await user!.updatePassword(newPassword);

      Get.snackbar('Success', 'Password changed successfully');
    } catch (e) {
      print('Error changing password: $e');
    }
  }
}
