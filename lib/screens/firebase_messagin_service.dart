import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permissions for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Retrieve FCM token
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      print('FCM Token: $fcmToken');
      // Save token to your backend or database
    } else {
      print('Failed to retrieve FCM token');
    }

    // Retrieve APNS token
    String? apnsToken = await _firebaseMessaging.getAPNSToken();
    if (apnsToken != null) {
      print('APNS Token: $apnsToken');
      // Use APNS token as needed
    } else {
      print('APNS Token not set yet');
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('New FCM Token: $newToken');
      // Update token in your backend or database
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.messageId}');
      // Handle the message
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.messageId}');
      // Navigate to the relevant screen or handle the notification
    });
  }

}