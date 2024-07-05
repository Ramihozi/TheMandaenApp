import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

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
        Text('$likes likes'),
      ],
    );
  }
}