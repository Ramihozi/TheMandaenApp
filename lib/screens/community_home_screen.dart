import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_create_story.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_post_item.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:the_mandean_app/screens/community_stories_controller.dart';
import 'package:the_mandean_app/screens/community_story_widget.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _homeController = Get.put(HomeController());
  final _profileController = Get.put(ProfileController());
  final _storyController = Get.put(StoriesController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '',
          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.12,
              child: Row(
                children: [
                  CreateStory(
                    onTap: () {
                      _storyController.getImage().then((value) {
                        if (value) {
                          _storyController.createStory(
                            userName: _profileController.name.value,
                            userUrl: _profileController.url.value,
                          );
                        }
                      });
                    },
                  ),
                  Obx(() {
                    return Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _storyController.stories.length,
                        itemBuilder: (context, index) {
                          return StoryWidget(
                            name: _storyController.stories[index].userName!,
                            image: _storyController.stories[index].userUrl!,
                            onTap: () {
                              Get.toNamed('/story_view_screen', arguments: [_storyController.stories[index]]);
                            },
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            Obx(() {
              return Expanded(
                child: ListView.builder(
                  cacheExtent: 1000, // Increase cache extent to preload images
                  itemCount: _homeController.posts.length,
                  itemBuilder: (context, index) {
                    return PostItem(
                      post: _homeController.posts[index],
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
