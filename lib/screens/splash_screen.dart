import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:get/get.dart'; // For routing
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:the_mandean_app/screens/onboarding_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermissions(); // Request notification permissions here
      _checkOnboardingStatus();
    });
  }

  Future<void> _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
      // Get and store the FCM token here if needed
      String? token = await messaging.getToken();
      print("FCM Token: $token");
      // Optionally save this token to your backend
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnboardingComplete = prefs.getBool('onboarding_complete');

    if (isOnboardingComplete == null || !isOnboardingComplete) {
      // If onboarding is not complete, show the onboarding screen
      Timer(
        const Duration(seconds: 3),
            () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
          );
        },
      );
    } else {
      // If onboarding is complete, check if the user is logged in
      _checkUserLoggedIn();
    }
  }

  void _checkUserLoggedIn() {
    User? user = FirebaseAuth.instance.currentUser;

    Timer(
      const Duration(seconds: 3),
          () {
        if (user != null) {
          // Navigate to main screen if user is logged in
          Get.offNamed('/main_screen');
        } else {
          // Navigate to login screen if not logged in
          Get.offNamed('/login_screen');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text(
              'GinzApp',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/mandean.png',
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ],
      ),
    );
  }
}
