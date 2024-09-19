import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:get/get.dart';
import 'community_profile_controller.dart'; // Import your profile controller

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.comments,
    required this.onPressed,
    required this.child,
  });

  final int comments;
  final VoidCallback onPressed;
  final Row child;

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();

    // Determine the comment text based on the current language
    final commentText = profileController.isEnglish.value ? 'comment' : 'تعليق';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(UniconsLine.comment_lines,
              color: Theme.of(context).iconTheme.color),
        ),
        Text('$comments $commentText'),
      ],
    );
  }
}
