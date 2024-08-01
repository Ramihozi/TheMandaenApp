import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_create_story.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_post_item.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:the_mandean_app/screens/community_stories_controller.dart';
import 'package:the_mandean_app/screens/community_story_widget.dart';

import 'community_post.dart';
import 'edit_story_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _homeController = Get.put(HomeController());
  final _profileController = Get.put(ProfileController());
  final _storyController = Get.put(StoriesController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: SizedBox(
                  height: size.height * 0.15, // Increased height to accommodate larger profile pictures and names
                  child: Obx(() {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _storyController.stories.length + 1,
                      padding: const EdgeInsets.only(left: 12.0), // Add padding to the left
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return CreateStory(
                            onTap: () async {
                              final imagePicked = await _storyController.getImage();
                              if (imagePicked) {
                                final editedImagePath = await Get.to(() => EditStoryScreen(selectedImagePath: _storyController.selectedImagePath.value));
                                if (editedImagePath != null) {
                                  _storyController.selectedImagePath.value = editedImagePath;
                                  _storyController.createStory(
                                    userName: _profileController.name.value,
                                    userUrl: _profileController.url.value,
                                  );
                                }
                              }
                            },
                          );
                        } else {
                          return StoryWidget(
                            name: _storyController.stories[index - 1].userName!,
                            image: _storyController.stories[index - 1].userUrl!,
                            onTap: () {
                              Get.toNamed('/story_view_screen', arguments: [_storyController.stories[index - 1]]);
                            },
                            size: size.height * 0.10, // Pass size to StoryWidget to adjust the profile picture size
                          );
                        }
                      },
                    );
                  }),
                ),
              ),
              StreamBuilder<List<Post>>(
                stream: _homeController.getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No posts available.'));
                  }

                  final posts = snapshot.data!;

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // Disable the scroll physics to allow the SingleChildScrollView to handle scrolling
                    shrinkWrap: true,
                    cacheExtent: 1000,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostItem(
                        post: posts[index],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
