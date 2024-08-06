import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_create_story.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_post_item.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:the_mandean_app/screens/community_stories_controller.dart';
import 'package:the_mandean_app/screens/community_story_widget.dart';

import 'community_post.dart';
import 'community_view_profile.dart';
import 'edit_story_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _homeController = Get.put(HomeController());
  final _profileController = Get.put(ProfileController());
  final _storyController = Get.put(StoriesController());

  void _showUploadSuccessSnackbar() {
    if (_storyController.uploadStatus.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          margin: const EdgeInsets.all(16.0),
          borderRadius: 8.0,
          duration: const Duration(seconds: 3), // Show Snackbar for 3 seconds
          messageText: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 16.0),
              Text(
                _storyController.uploadStatus.value,
                style: TextStyle(
                  color: _storyController.uploadStatus.value.contains('Failed')
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        // Clear the upload status after showing the snackbar
        _storyController.uploadStatus.value = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Story section
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: SizedBox(
                  height: size.height * 0.15, // Adjust height as needed
                  child: Obx(() {
                    // Check for upload status and show success snackbar
                    _showUploadSuccessSnackbar();

                    // Filter and remove stories older than 2 days
                    _storyController.removeOldStories();

                    return Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.15, // Adjust size to fit the story widget
                          child: ListView.builder(
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
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              // Posts section
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
                      final userStories = _storyController.stories.where((story) => story.userUid == posts[index].userUid).toList();

                      return PostItem(
                        post: posts[index],
                        onProfilePictureClick: () {
                          if (userStories.isNotEmpty) {
                            Get.toNamed('/story_view_screen', arguments: userStories);
                          } else {
                            Get.to(() => ViewProfileScreen(userId: posts[index].userUid));
                          }
                        },
                        onNameClick: () {
                          Get.to(() => ViewProfileScreen(userId: posts[index].userUid));
                        },
                        // Adding colorful outline if user has a story
                        profilePictureDecoration: userStories.isNotEmpty
                            ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber, // Instagram-like color
                            width: 3.0, // Thickness of the border
                          ),
                        )
                            : null,
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
