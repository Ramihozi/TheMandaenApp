import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:the_mandean_app/screens/community_create_story.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_post_item.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:the_mandean_app/screens/community_stories_controller.dart';
import 'package:the_mandean_app/screens/community_story_widget.dart';

import 'Community_dm_screen.dart';
import 'community_post.dart';
import 'community_view_profile.dart';
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
              // Story section
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: SizedBox(
                  height: size.height * 0.15,
                  child: Obx(() {
                    _storyController.removeOldStories();

                    return Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.15,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _storyController.stories.length + 1,
                            padding: const EdgeInsets.only(left: 12.0),
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
                                  size: size.height * 0.10,
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
              Obx(() {
                final posts = _homeController.posts;

                // Ensure there is at least one post to display
                if (posts.isEmpty) {
                  return SizedBox.shrink();
                }

                // Randomly select where to display the suggested friends list between 1st and 5th post
                final random = Random();
                final maxIndex = min(5, posts.length);
                final randomIndex = random.nextInt(maxIndex); // Random index between 0 and maxIndex-1

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  cacheExtent: 1000,
                  itemCount: posts.length + 1, // +1 to account for suggested friends section
                  itemBuilder: (context, index) {
                    if (index == randomIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display suggested friends text based on the language
                            Obx(() {
                              String suggestedFriendsText = _profileController.isEnglish.value
                                  ? "Suggested Friends"
                                  : "الأصدقاء المقترحون"; // Arabic translation
                              return Padding(
                                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                                child: Text(
                                  suggestedFriendsText,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                height: size.height * 0.20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Obx(() {
                                  final suggestedFriends = _homeController.suggestedFriends;

                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: suggestedFriends.length,
                                    padding: const EdgeInsets.only(left: 12.0),
                                    itemBuilder: (context, index) {
                                      final friend = suggestedFriends[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 16.0, top: 12.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(
                                                  friendId: friend.id,
                                                  friendName: friend.name,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Profile picture (larger)
                                              Container(
                                                width: size.height * 0.12,
                                                height: size.height * 0.12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.amber,
                                                    width: 2.0,
                                                  ),
                                                  image: DecorationImage(
                                                    image: CachedNetworkImageProvider(friend.url), // Using CachedNetworkImage
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.0),
                                              // Friend name (larger)
                                              Text(
                                                friend.name,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final postIndex = index > randomIndex ? index - 1 : index;
                      final userStories = _storyController.stories.where((story) => story.userUid == posts[postIndex].userUid).toList();

                      return PostItem(
                        post: posts[postIndex],
                        onProfilePictureClick: () {
                          if (userStories.isNotEmpty) {
                            Get.toNamed('/story_view_screen', arguments: userStories);
                          } else {
                            Get.to(() => ViewProfileScreen(userId: posts[postIndex].userUid));
                          }
                        },
                        onNameClick: () {
                          Get.to(() => ViewProfileScreen(userId: posts[postIndex].userUid));
                        },
                        profilePictureDecoration: userStories.isNotEmpty
                            ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber,
                            width: 3.0,
                          ),
                        )
                            : null,
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
