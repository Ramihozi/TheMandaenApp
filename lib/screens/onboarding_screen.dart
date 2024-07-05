import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:the_mandean_app/constants/constants.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

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
            "Customize Your Reading View, Read In Multiple Language, Listen To different Audio",
            image: 'assets/images/quran2.png',
          ),
          _buildPageViewModel(
            title: "Prayer Alerts",
            body: "Choose When To Be Notified Of Prayer and How Often.",
            image: 'assets/images/namaz2.png',
          ),
          _buildPageViewModel(
            title: "Build Better Habits",
            body:
            "Make Mandeanism Practices a part of your daily life in a way that suits your life",
            image: 'assets/images/zakat2.png',
          ),
        ],
        showNextButton: true,
        next: Icon(Icons.arrow_forward, color: Colors.black),
        done: Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
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

  void _handleDone() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed('/main_screen');
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed('/login_screen');
      });
    }
  }

  PageViewModel _buildPageViewModel({
    required String title,
    required String body,
    required String image,
  }) {
    return PageViewModel(
      title: title,
      bodyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      image: Center(child: Image.asset(image, fit: BoxFit.fitWidth)),
    );
  }
}
