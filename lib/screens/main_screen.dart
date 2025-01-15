import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import for CupertinoTabBar
import 'package:get/get.dart'; // Import for using reactive variables and Obx widget
import 'package:the_mandean_app/screens/books_tab/bookSelection.dart';
import 'package:the_mandean_app/screens/community_main_screen.dart';
import 'package:the_mandean_app/screens/home_screen.dart';
import 'package:the_mandean_app/screens/calendar_screen.dart';
import 'package:the_mandean_app/screens/prayer_tab/prayer_screen.dart';
import 'profile_tab/community_profile.dart';
import 'profile_tab/community_profile_controller.dart'; // Import for ProfileScreen and ProfileController

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final ProfileController _profileController = Get.put(ProfileController()); // Get the ProfileController

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    PrayerTab(),
    const BooksSelectionScreen(),
    CommunityMainScreen(), // Add PrayerScreen here
    ProfileScreen(userId: null), // Add ProfileScreen here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Obx(() {
        // Use Obx to reactively update the BottomNavigationBar labels
        return CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: _profileController.isEnglish.value ? 'Home' : 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement), // Prayer icon
              label: _profileController.isEnglish.value ? 'Prayer' : 'الصلاة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: _profileController.isEnglish.value ? 'Books' : 'الكتب',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: _profileController.isEnglish.value ? 'Community' : 'المجتمع',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: _profileController.isEnglish.value ? 'Profile' : 'الملف الشخصي',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          activeColor: Colors.amber, // Active tab color
          inactiveColor: Colors.black54, // Inactive tab color
          backgroundColor: Colors.white, // Background color
        );
      }),
    );
  }
}

