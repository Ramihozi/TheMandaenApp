import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_main_screen_controller.dart';
import 'community_add_post_screen.dart';
import 'community_chat_screen.dart'; // Import the chat screen

class CommunityMainScreen extends StatelessWidget {
  final MainScreenController _controller = Get.put(MainScreenController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('GinzApp'),
          backgroundColor: Colors.white,
          elevation: 0, // Disable the shadow effect
          scrolledUnderElevation: 0.0, // Prevent color change on scroll
          titleSpacing: 10, // Adjust this to control the space between the title and the start of the AppBar
          toolbarHeight: 40, // Adjust this value to change the overall height of the AppBar
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0), // Adjust the right padding as needed
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30, // Adjust the size as needed
                ),
                onPressed: () {
                  // Navigate to the AddPostScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPostScreen()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Adjust the right padding as needed
              child: IconButton(
                icon: Icon(
                  Icons.message_outlined, // Use a modern chat icon
                  size: 30, // Adjust the size as needed
                ),
                onPressed: () {
                  // Navigate to the chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommunityChatScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: _controller.widgetOptions[_controller.selectedIndex.value],
      );
    });
  }
}
