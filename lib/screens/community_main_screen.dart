import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'community_add_post_screen.dart';
import 'community_chat_screen.dart';
import 'community_main_screen_controller.dart';

class CommunityMainScreen extends StatelessWidget {
  final MainScreenController _controller = Get.put(MainScreenController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int unreadMessagesCount = _controller.unreadMessagesCount.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('GinzApp'),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.0,
          titleSpacing: 10,
          toolbarHeight: 40,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPostScreen()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: badges.Badge(
                badgeContent: Text(
                  '$unreadMessagesCount',
                  style: TextStyle(color: Colors.white),
                ),
                showBadge: unreadMessagesCount > 0,
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.red,
                ),
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                child: IconButton(
                  icon: Icon(
                    Icons.message_outlined,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommunityChatScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: _controller.widgetOptions[_controller.selectedIndex.value],
      );
    });
  }
}

class StoryCard extends StatelessWidget {
  final String imageUrl;

  StoryCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
