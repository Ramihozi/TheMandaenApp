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
  final RxBool isEnglish = true.obs;

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

      // Show a success message in a centered dialog
      Get.dialog(
        Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white, // Set background color to white
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEnglish.value ? 'Success' : 'نجاح',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  isEnglish.value
                      ? 'Please Restart App To Apply Changes Fully!'
                      : 'يرجى إعادة تشغيل التطبيق لتطبيق التغييرات بالكامل!',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                TextButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  child: Text(
                    isEnglish.value ? 'OK' : 'موافق',
                    style: TextStyle(
                      color: Colors.amber, // Set OK text color to golden
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true, // Allows tapping outside to dismiss the dialog
      );
    } catch (e) {
      print('Error updating profile picture: $e');
      Get.dialog(
        Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white, // Set background color to white
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEnglish.value ? 'Error' : 'خطأ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  isEnglish.value
                      ? 'Failed to update profile picture'
                      : 'فشل في تحديث صورة الملف الشخصي',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                TextButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  child: Text(
                    isEnglish.value ? 'OK' : 'موافق',
                    style: TextStyle(
                      color: Colors.amber, // Set OK text color to golden
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true, // Allows tapping outside to dismiss the dialog
      );
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
          'name': userDoc['name'] ?? (isEnglish.value ? 'Unknown' : 'مجهول'),
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
      Get.snackbar(
        isEnglish.value ? 'Error' : 'خطأ',
        isEnglish.value ? 'Failed to unblock user' : 'فشل في إلغاء حظر المستخدم',
      );
    }
  }

  Future<void> deleteUserAccount(BuildContext context, String password) async {
    try {
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-signed-in', message: isEnglish.value ? 'No user is signed in.' : 'لا يوجد مستخدم مسجل الدخول.');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user!.reauthenticateWithCredential(credential);

      // Delete user's posts from the 'post' collection
      QuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('post')
          .where('userUid', isEqualTo: user!.uid)
          .get();

      for (QueryDocumentSnapshot doc in postSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's stories from the 'story' collection
      QuerySnapshot storySnapshot = await FirebaseFirestore.instance
          .collection('story')
          .where('userUid', isEqualTo: user!.uid)
          .get();

      for (QueryDocumentSnapshot doc in storySnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the user's document from the 'user' collection
      await FirebaseFirestore.instance
          .collection("user")
          .doc(user!.uid)
          .delete();

      await user!.delete();

      await FirebaseAuth.instance.signOut();

      Get.offAllNamed('/login');
    } catch (e) {
      print('Error deleting user: $e');
      Get.snackbar(
        isEnglish.value ? 'Error' : 'خطأ',
        isEnglish.value ? 'Failed to delete account' : 'فشل في حذف الحساب',
      );
    }
  }

  Future<void> changePassword(BuildContext context, String currentPassword, String newPassword) async {
    try {
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-signed-in', message: isEnglish.value ? 'No user is signed in.' : 'لا يوجد مستخدم مسجل الدخول.');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user!.reauthenticateWithCredential(credential);

      await user!.updatePassword(newPassword);

      Get.snackbar(
        isEnglish.value ? 'Success' : 'نجاح',
        isEnglish.value ? 'Password changed successfully' : 'تم تغيير كلمة المرور بنجاح',
      );
    } catch (e) {
      print('Error changing password: $e');
    }
  }
}
