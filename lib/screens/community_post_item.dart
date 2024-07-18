import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_like_widget.dart';
import 'package:the_mandean_app/screens/community_post.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:unicons/unicons.dart';

import 'community_comment_widget.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final HomeController _homeController = HomeController(); // Replace with your HomeController setup

    final date = DateTime.fromMillisecondsSinceEpoch(post.time);
    final format = DateFormat.yMd();
    final dateString = format.format(date);

    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(post.userUrl),
              ),
              title: Text(post.userName, style: Theme.of(context).textTheme.headlineSmall),
              subtitle: Text(dateString),
              trailing: post.userUid == _homeController.user?.uid
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
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Text(post.postTitle, textAlign: TextAlign.left),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.postUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    LikeWidget(
                      likePressed: (){
                        _homeController.setLike(post.postId!);
                      },
                      likes: post.likes!.length,
                      isLiked: post.likes!.contains(_homeController.user?.uid),
                      postId: post.postId!,
                    ),
                    CommentWidget(
                      comments: post.commentsCount!,
                      onPressed: (){
                        Get.toNamed('/comments_screen', arguments: [
                          post.userName, //0
                          post.userUrl, //1
                          post.userUid, //2
                          post.postId //3
                        ] );
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
                    // Example action for the telegram icon
                  },
                  icon: const Icon(
                    UniconsLine.telegram_alt,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                HomeController().deletePost(post.postId);
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
}
