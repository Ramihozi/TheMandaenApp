// saveFcmToken.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FcmTokenManager {
  // Function to save FCM token to Firestore
  static Future<void> saveFcmToken() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({'fcmToken': fcmToken});
      }
    }
  }

  // Function to listen for token refresh and update Firestore
  static void listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // Update the token in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({'fcmToken': newToken});
      }
    });
  }

  // Initialize FCM token management
  static void initialize() {
    saveFcmToken();
    listenToTokenRefresh();
  }
}
