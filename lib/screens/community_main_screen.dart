import 'package:flutter/material.dart';
import 'package:the_mandean_app/constants/constants.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_main_screen_controller.dart';


class CommunityMainScreen extends StatelessWidget {
  CommunityMainScreen({Key? key}) : super(key: key);

  final _controller = Get.put(MainScreenController(),permanent: true);
  @override
  Widget build(BuildContext context) {
    return Obx((){
      return Scaffold(
        body: _controller.widgetOptions.elementAt(_controller.selectedIndex.value),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            backgroundColor: lightPrimaryColor.withOpacity(0.3),
            currentIndex: _controller.selectedIndex.value,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            iconSize: 40,
            onTap: _controller.onItemTapped,
            elevation: 5
        ),
      );
    });
  }
}