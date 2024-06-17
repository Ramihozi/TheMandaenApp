import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_mandean_app/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});  // Added super.key

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {  // Ensure context is still valid
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const Center(
              child: Text(
                'Mandean App',
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 0,
              right: 0,
              child: Image.asset('assets/images/mandean.png'),
            ),
          ],
        ),
      ),
    );
  }
}
