import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:get/get.dart';

import 'profile_tab/community_profile_controller.dart'; // Import GetX for localization

class LikeWidget extends StatelessWidget {
  const LikeWidget({
    super.key,
    required this.postId,
    required this.likes,
    required this.isLiked,
    required this.likePressed
  });

  final String postId;
  final int likes;
  final bool isLiked;
  final VoidCallback likePressed;

  @override
  Widget build(BuildContext context) {
    // Assuming you have a ProfileController or similar to get the current language
    final ProfileController profileController = Get.find<ProfileController>();
    final bool isEnglish = profileController.isEnglish.value;

    // Determine the text based on the language
    final String likesText = isEnglish ? '$likes likes' : '$likes إعجابات';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: likePressed,
          icon: Icon(UniconsLine.thumbs_up,
              color: isLiked
                  ? Colors.blue
                  : Theme.of(context).iconTheme.color),
        ),
        Text(likesText),
      ],
    );
  }
}
