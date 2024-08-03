import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_like_widget.dart';
import 'package:the_mandean_app/screens/community_post.dart';
import 'package:unicons/unicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import

import 'community_comment_widget.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
    required this.post,
    required this.onProfilePictureClick,
    required this.onNameClick,
  });

  final Post post;
  final VoidCallback onProfilePictureClick;
  final VoidCallback onNameClick;

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find(); // Use Get.find() to access the HomeController instance

    final date = DateTime.fromMillisecondsSinceEpoch(post.time);
    final format = DateFormat.yMd();
    final dateString = format.format(date);

    return Card(
      color: Colors.white, // Set the background color to white
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0), // Add padding to move profile picture to the right
              child: GestureDetector(
                onTap: onProfilePictureClick,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: CachedNetworkImageProvider(post.userUrl),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 10.0), // Add padding to move name to the right
              child: GestureDetector(
                onTap: onNameClick,
                child: Text(
                  post.userName,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 10.0), // Add padding to move date to the right
              child: Text(dateString),
            ),
            trailing: post.userUid == homeController.user?.uid
                ? PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmationDialog(context);
                }
              },
            )
                : IconButton(
              icon: const Icon(Icons.report),
              onPressed: () {
                _showReportConfirmationDialog(context, post.postId);
              },
            ),
          ),
          // Post Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              post.postTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),
          if (post.postUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.postUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          const SizedBox(height: 8),
          // Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    LikeWidget(
                      likePressed: () {
                        homeController.setLike(post.postId);
                      },
                      likes: post.likes.length,
                      isLiked: post.likes.contains(homeController.user?.uid),
                      postId: post.postId,
                    ),
                    SizedBox(width: 16),
                    CommentWidget(
                      comments: post.commentsCount,
                      onPressed: () {
                        Get.toNamed('/comments_screen', arguments: [
                          post.userName, //0
                          post.userUrl, //1
                          post.userUid, //2
                          post.postId //3
                        ]);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            UniconsLine.comment_alt,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.commentsCount.toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'comments',
                                style: TextStyle(color: Colors.black.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    _sharePost(post); // Share post when the button is pressed
                  },
                  icon: const Icon(
                    UniconsLine.telegram_alt,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sharePost(Post post) {
    final String text = '${post.postTitle}\n\n${post.postUrl.isNotEmpty ? post.postUrl : ''}';
    Share.share(text);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.find<HomeController>().deletePost(post.postId);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReportConfirmationDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: const Text('Are You Sure? Post Will Be Removed From View Upon App Restart.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.find<HomeController>().reportPost(postId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Post Has Been Reported, Please Allow 24 Hours For Review")),
                );
              },
              child: const Text(
                'Report',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
