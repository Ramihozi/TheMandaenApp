import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_mandean_app/constants/constants.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IntroductionScreen(
        pages: [
          _buildPageViewModel(
            title: "Build Better Habits",
            body:
            "Customize Your Reading View, Read In Multiple Language, Listen To different Audio (coming soon...)",
            image: 'assets/images/OnboardPicture1.jpeg',
          ),
          _buildPageViewModel(
            title: "Prayer Alerts",
            body: "Choose When To Be Notified Of Prayer and How Often. (coming soon...)",
            image: 'assets/images/OnboardPicture2.jpeg',
          ),
          _buildPageViewModel(
            title: "Build Better Habits",
            body:
            "Make Mandeanism Practices a part of your daily life in a way that suits your life",
            image: 'assets/images/OnboardPicture3.jpeg',
          ),
        ],
        showNextButton: true,
        next: const Icon(Icons.arrow_forward, color: Colors.black),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        onDone: () => _handleDone(),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Constants.kPrimary,
          color: Colors.grey,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  void _handleDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true); // Mark onboarding as complete

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offNamed('/main_screen');
    } else {
      Get.offNamed('/login_screen');
    }
  }
  PageViewModel _buildPageViewModel({
    required String title,
    required String body,
    required String image,
  }) {
    return PageViewModel(
      titleWidget: Transform.translate(
        offset: const Offset(0, 60), // Moves the title down by 20 pixels
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      bodyWidget: Transform.translate(
        offset: const Offset(0, 60), // Moves the body text down by 20 pixels
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      image: Center(
        child: Transform.translate(
          offset: const Offset(0, 55), // Moves the image down by 20 pixels
          child: Image.asset(image, fit: BoxFit.fitWidth),
        ),
      ),
    );
  }
}
