import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import for CupertinoTabBar
import 'package:the_mandean_app/screens/community_main_screen.dart';
import 'package:the_mandean_app/screens/ginza_screen.dart';
import 'package:the_mandean_app/screens/home_screen.dart';
import 'package:the_mandean_app/screens/calendar_screen.dart';
import 'community_profile.dart'; // Import for ProfileScreen

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const GinzaScreen(),
    CommunityMainScreen(),
    const PrayerScreen(),
    ProfileScreen(), // Add ProfileScreen here
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
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Ginza',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // Add Profile tab here
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        activeColor: Colors.amber, // Active tab color
        inactiveColor: Colors.grey, // Inactive tab color
        backgroundColor: Colors.white, // Background color
      ),
    );
  }
}
