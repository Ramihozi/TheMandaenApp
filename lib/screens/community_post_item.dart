import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_mandean_app/screens/community_comment_widget.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_like_widget.dart';
import 'package:the_mandean_app/screens/community_post.dart';
import 'package:unicons/unicons.dart';


class PostItem extends StatelessWidget {
  PostItem({
    super.key,
    required this.post,
  });
  final Post post;
  // GetX dependency injection
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {

    final date =  DateTime.fromMillisecondsSinceEpoch(post.time!);
    final format =  DateFormat("yMd");
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
                backgroundImage:
                NetworkImage(post.userUrl!),
              ),
              title: Text(post.userName!, style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text(dateString),
              trailing: const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16,),
            Text(post.postTitle!, textAlign: TextAlign.left,),
            const SizedBox(height: 16,),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.postUrl!,
                height: 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
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
                      isLiked: post.likes!.contains(_homeController.user.uid),
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
                    ),
                  ],
                ),
                const IconButton(
                    onPressed: null,
                    icon: Icon(
                      UniconsLine.telegram_alt,
                      color: Colors.black,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}