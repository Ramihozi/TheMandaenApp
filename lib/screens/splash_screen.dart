import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package for URL launching
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:the_mandean_app/screens/onboarding_screen.dart';
import 'community_stories_controller.dart'; // Import your StoriesController

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StoriesController _storiesController = StoriesController(); // Initialize your controller

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdateDialog();
      _deleteOldStories();
    });
  }

  Future<void> _deleteOldStories() async {
    await _storiesController.deleteOldStoriesFromFirestore();
    Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
          );
        }
      },
    );
  }

  Future<void> _showUpdateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    bool? hasShownUpdateDialog = prefs.getBool('hasShownUpdateDialog');

    if (hasShownUpdateDialog != true) {
      // Check if the app needs to be updated
      // For example, compare app version with the latest version from your server

      // Replace the URL with the link to your app on the App Store or Google Play Store
      const appStoreUrl = 'https://apps.apple.com/us/app/ginzapp/id6575359956';

      // Show the dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('UPDATE'),
            content: const Text('Please Update The App To Enjoy The Latest Features'),
            actions: [
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.amber)),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _launchURL(appStoreUrl); // Open the app store
                  prefs.setBool('hasShownUpdateDialog', true); // Mark dialog as shown
                },
              ),
            ],
            backgroundColor: Colors.white,
          );
        },
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the error
      throw 'Could not launch $url';
    }
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
