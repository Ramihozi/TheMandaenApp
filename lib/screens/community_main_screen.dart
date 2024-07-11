import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_main_screen_controller.dart';

class CommunityMainScreen extends StatelessWidget {
  final Color drawerBackgroundColor;
  final Color drawerHeaderColor;

  CommunityMainScreen({
    super.key,
    this.drawerBackgroundColor = Colors.white, // Default background color for Drawer
    this.drawerHeaderColor = Colors.white, // Default background color for DrawerHeader
  });

  final MainScreenController _controller = Get.put(MainScreenController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Social Network'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: drawerBackgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: drawerHeaderColor,
                  ),
                  child: const Text(
                    'Menu Bar',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    _controller.onItemTapped(0); // Navigate to HomeScreen
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Post'),
                  onTap: () {
                    _controller.onItemTapped(1); // Navigate to AddPostScreen
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Chat'),
                  onTap: () {
                    _controller.onItemTapped(2); // Navigate to ChatScreen
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    _controller.onItemTapped(3); // Navigate to ProfileScreen
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: _controller.widgetOptions[_controller.selectedIndex.value],
      );
    });
  }
}
