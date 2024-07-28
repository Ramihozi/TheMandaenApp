import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString url = ''.obs;
  RxList<Map<String, String>> blockedUsers = <Map<String, String>>[].obs;
  User? user = FirebaseAuth.instance.currentUser;

  // Controllers for password inputs
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
        // Remove userId from blockedUsers array in Firestore
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

      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user!.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection("user")
          .doc(user!.uid)
          .delete();

      // Delete user from Firebase Auth
      await user!.delete();

      // Sign out the user after deletion
      await FirebaseAuth.instance.signOut();

      // Navigate to a different screen or show a success message
      Get.offAllNamed('/login'); // Example navigation to the login screen
    } catch (e) {
      // Handle errors
      print('Error deleting user: $e');
      // Optionally show an error message to the user
    }
  }

  Future<void> changePassword(BuildContext context, String currentPassword, String newPassword) async {
    try {
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-signed-in', message: 'No user is signed in.');
      }

      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user!.reauthenticateWithCredential(credential);

      // Update password
      await user!.updatePassword(newPassword);

      // Optionally show a success message or update the UI
      Get.snackbar('Success', 'Password changed successfully');
    } catch (e) {
      // Handle errors
      print('Error changing password: $e');
      // Optionally show an error message to the user
    }
  }
}
