import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_mandean_app/screens/community_home_screen_controller.dart';
import 'package:the_mandean_app/screens/community_like_widget.dart';
import 'package:the_mandean_app/screens/community_post.dart';
import 'package:unicons/unicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'community_comment_widget.dart';
import 'community_profile_controller.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Add this import for Firebase Functions


class PostItem extends StatefulWidget {
  const PostItem({
    super.key,
    required this.post,
    required this.onProfilePictureClick,
    required this.onNameClick,
    this.profilePictureDecoration,
  });

  final Post post;
  final VoidCallback onProfilePictureClick;
  final VoidCallback onNameClick;
  final BoxDecoration? profilePictureDecoration;

  @override
  _PostItemState createState() => _PostItemState();
}


class _PostItemState extends State<PostItem> {
  String? translatedTitle;
  bool isTranslating = false;
  bool isTranslated = false; // Track translation state

  final HomeController homeController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    // Listen to changes in language and update the state accordingly
    ever(profileController.isEnglish, (_) {
      setState(() {
        // Reset translation state on language change
        if (!isTranslated) {
          translatedTitle = null; // Keep original if not translated
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(widget.post.time);
    final format = DateFormat.yMd();
    final dateString = format.format(date);

    // Determine the post title based on the language and translation state
    final postTitle = isTranslated
        ? translatedTitle ?? widget.post.postTitle // Use translatedTitle if it's available
        : (profileController.isEnglish.value
        ? widget.post.postTitle // Original English title
        : widget.post.postTitle); // Original Arabic title

    // Determine button text
    String buttonText = profileController.isEnglish.value
        ? (isTranslated ? 'Revert to Original' : 'See Translation')
        : (isTranslated ? 'العودة إلى الأصل' : 'عرض الترجمة');

    return Card(
      color: Colors.white,
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
              padding: const EdgeInsets.only(left: 10.0),
              child: GestureDetector(
                onTap: widget.onProfilePictureClick,
                child: Container(
                  decoration: widget.profilePictureDecoration,
                  padding: EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: CachedNetworkImageProvider(widget.post.userUrl),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: GestureDetector(
                onTap: widget.onNameClick,
                child: Text(
                  widget.post.userName,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(dateString),
            ),
            trailing: widget.post.userUid == homeController.user?.uid
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
                _showReportConfirmationDialog(context, widget.post.postId);
              },
            ),
          ),
          // Post Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (!isTranslating)
                  TextButton(
                    onPressed: _toggleTranslation,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      minimumSize: Size(100, 30), // Size of the button
                    ),
                    child: Text(buttonText),
                  ),
                if (isTranslating) const CircularProgressIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (widget.post.postUrl.isNotEmpty)
            FutureBuilder<Size>(
              future: _calculateImageDimension(widget.post.postUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  final size = snapshot.data!;
                  final aspectRatio = size.width / size.height;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: CachedNetworkImage(
                        imageUrl: widget.post.postUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
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
                        homeController.setLike(widget.post.postId);
                      },
                      likes: widget.post.likes.length,
                      isLiked: widget.post.likes.contains(homeController.user?.uid),
                      postId: widget.post.postId,
                    ),
                    const SizedBox(width: 16),
                    CommentWidget(
                      comments: widget.post.commentsCount,
                      onPressed: () {
                        Get.toNamed('/comments_screen', arguments: [
                          widget.post.userName, //0
                          widget.post.userUrl, //1
                          widget.post.userUid, //2
                          widget.post.postId //3
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
                                widget.post.commentsCount.toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                profileController.isEnglish.value ? 'comments' : 'تعليقات',
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
                    _sharePost(widget.post);
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

  Future<void> _translatePostTitle() async {
    setState(() {
      isTranslating = true;
    });

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('translateText');

      // Determine target language based on current language setting
      final targetLanguage = profileController.isEnglish.value ? 'en' : 'ar';

      // Determine the source language (Arabic or English) based on current language setting
      final sourceLanguage = profileController.isEnglish.value ? 'ar' : 'en';

      final result = await callable.call(<String, dynamic>{
        'text': widget.post.postTitle,
        'sourceLanguage': sourceLanguage, // Specify source language
        'targetLanguage': targetLanguage,
      });

      // Debugging: Print the result data
      print('Translation Result: ${result.data}');

      final translatedText = result.data['translation'] as String;
      setState(() {
        translatedTitle = translatedText;
        isTranslated = true; // Set to true when translation is completed
      });
    } catch (e) {
      // Debugging: Print any errors encountered
      print('Error translating text: $e');
    } finally {
      setState(() {
        isTranslating = false;
      });
    }
  }

  Future<void> _toggleTranslation() async {
    if (isTranslated) {
      // Revert to original text
      setState(() {
        translatedTitle = null;
        isTranslated = false;
      });
    } else {
      // Translate text
      await _translatePostTitle();
    }
  }


  Future<Size> _calculateImageDimension(String url) {
    Completer<Size> completer = Completer();
    Image image = Image.network(url);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo info, bool _) {
          completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
        },
      ),
    );
    return completer.future;
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
                Get.find<HomeController>().deletePost(widget.post.postId);
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