import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:the_mandean_app/constants/constants.dart';



class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>{
  @override
  Widget build(BuildContext context) {
    return SafeArea (
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Build Better Habits",
              bodyWidget: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Customize Your Reading View, Read In Multiple Language, Listen To different Audio"
                      ,textAlign: TextAlign.center,style: TextStyle(fontSize: 16),),
                  ),
                ],
              ),
              image: Center(child: Image.asset('assets/images/quran2.png', fit: BoxFit.fitWidth,)),
            ),
            PageViewModel(
              title: "Prayer Alerts",
              bodyWidget: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Choose When To Be Notified Of Prayer and How Often.  ",
                      textAlign: TextAlign.center,style: TextStyle(fontSize: 16),),
                  ),
                ],
              ),
              image: Center(child: Image.asset('assets/images/namaz2.png')),
            ),
            PageViewModel(
              title: "Build Better Habits",
              bodyWidget: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Make Mandeanism Practices a part of your daily life in a way that suites your life "
                          ,textAlign: TextAlign.center,style: TextStyle(fontSize: 16),),
                    ),
                ],
              ),
              image: Center(child: Image.asset('assets/images/zakat2.png')),
            ),

          ],
          showNextButton: true,
          next: const Icon(Icons.arrow_forward, color: Colors.black),
          done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black)),
          onDone: () {
            User? user = FirebaseAuth.instance.currentUser;
            // user is already logged in go to main screen
            if(user != null){
              Timer(const Duration(seconds: 3),(){
                Get.offNamed('/main_screen');
              });
            }else{
              Timer(const Duration(seconds: 3),(){
                Get.offNamed('/login_screen');
              });
            }
          },

          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Constants.kPrimary,
            color: Colors.grey,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
            ),
          ),
        )
      )
    );
  }
}

