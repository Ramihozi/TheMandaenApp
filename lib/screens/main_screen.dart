import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:the_mandean_app/constants/constants.dart';
import 'package:the_mandean_app/screens/community_screen.dart';
import 'package:the_mandean_app/screens/ginza_screen.dart';
import 'package:the_mandean_app/screens/home_screen.dart';
import 'package:the_mandean_app/screens/calendar_screen.dart';




class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int selectindex = 0;
  List<Widget> _widgetsList = [HomeScreen(),GinzaScreen(),AudioScreen(),PrayerScreen()];


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: _widgetsList[selectindex],
        bottomNavigationBar: ConvexAppBar(
            items:  [
              TabItem(icon: Image.asset('assets/images/home.png',color: Colors.white,), title: 'Home'),
              TabItem(icon: Image.asset('assets/images/holyQuran.png',color: Colors.white), title: 'Ginza'),
              TabItem(icon: Image.asset('assets/images/community.png',color: Colors.white), title: 'Community'),
              TabItem(icon: Image.asset('assets/images/calendar.png',color: Colors.white), title: 'Calendar'),
            ],
                    initialActiveIndex: 0,
                    onTap: updateIndex,
                  backgroundColor: Colors.black,
                  activeColor: Colors.black,
              )
            )
        );
  }

  void updateIndex(index) {
    setState(() {
      selectindex = index;
    });
  }
}
