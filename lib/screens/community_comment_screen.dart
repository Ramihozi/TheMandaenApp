import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_mandean_app/screens/community_comment_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsScreen extends StatelessWidget {
  CommentsScreen({super.key});

  final _commentController = Get.put(CommentController());
  final _arguments = Get.arguments;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _commentController.getPostId(_arguments[3]);

    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final reversedComments = _commentController.comments.reversed.toList();

              return ListView.builder(
                itemCount: reversedComments.length,
                itemBuilder: (context, index) {
                  final comment = reversedComments[index];

                  // Convert millisecondsSinceEpoch to DateTime in local timezone
                  DateTime localTime = DateTime.fromMillisecondsSinceEpoch(comment.time!);
                  // Format date in MM/dd/yyyy hh:mm a format (12-hour with AM/PM)
                  String dateString = DateFormat('MM/dd/yyyy hh:mm a').format(localTime);

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(comment.userUrl!),
                            ),
                            title: Text(
                              comment.userName!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              dateString,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: comment.userUid == FirebaseAuth.instance.currentUser?.uid
                                ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Comment'),
                                      content: Text('Are you sure you want to delete this comment?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  _commentController.deleteComment(comment.commentId!, _arguments[3]);
                                }
                              },
                            )
                                : null,
                          ),
                          SizedBox(height: 8),
                          Text(
                            comment.comment!,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Divider(height: 0),
          ListTile(
            tileColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            title: TextFormField(
              controller: _commentController.commentTextController,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                border: InputBorder.none,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _commentController.addComment(_arguments[3]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
