import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_mandean_app/screens/community_comment_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import for Firebase Functions
import 'community_comment.dart';
import 'profile_tab/community_profile_controller.dart'; // Import ProfileController

class CommentsScreen extends StatelessWidget {
  CommentsScreen({super.key});

  final _commentController = Get.put(CommentController());
  final _arguments = Get.arguments;
  final ProfileController profileController = Get.find(); // Reference ProfileController

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _commentController.getPostId(_arguments[3]);

    return Scaffold(
      appBar: AppBar(
        title: Text(profileController.isEnglish.value ? 'Comments' : 'تعليقات'),
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

                  return CommentCard(
                    comment: comment,
                    dateString: dateString,
                    postId: _arguments[3],
                    profileController: profileController, // Pass ProfileController
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
              decoration: InputDecoration(
                hintText: profileController.isEnglish.value ? 'Write a comment...' : 'اكتب تعليق...',
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

class CommentCard extends StatefulWidget {
  const CommentCard({
    Key? key,
    required this.comment,
    required this.dateString,
    required this.postId,
    required this.profileController, // Add ProfileController parameter
  }) : super(key: key);

  final Comment comment;
  final String dateString;
  final String postId;
  final ProfileController profileController; // ProfileController

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String? translatedComment;
  bool isTranslating = false;
  bool isTranslated = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes in language and update the state accordingly
    ever(widget.profileController.isEnglish, (_) {
      setState(() {
        // Reset translation state on language change
        translatedComment = null;
        isTranslated = false;
      });
    });
  }

  Future<void> _translateComment() async {
    setState(() {
      isTranslating = true;
    });

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('translateText');

      // Determine target language based on current language setting
      final targetLanguage = widget.profileController.isEnglish.value ? 'en' : 'ar';

      // Determine the source language (Arabic or English) based on current language setting
      final sourceLanguage = widget.profileController.isEnglish.value ? 'ar' : 'en';

      final result = await callable.call(<String, dynamic>{
        'text': widget.comment.comment!,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
      });

      final translatedText = result.data['translation'] as String;
      setState(() {
        translatedComment = translatedText;
        isTranslated = true;
      });
    } catch (e) {
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
        translatedComment = null;
        isTranslated = false;
      });
    } else {
      // Translate text
      await _translateComment();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the comment text based on the language and translation state
    final commentText = isTranslated ? translatedComment ?? widget.comment.comment : widget.comment.comment;

    // Determine button text
    String buttonText = widget.profileController.isEnglish.value
        ? (isTranslated ? 'Revert to Original' : 'See Translation')
        : (isTranslated ? 'العودة إلى الأصل' : 'عرض الترجمة'); // Arabic translations

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
                backgroundImage: NetworkImage(widget.comment.userUrl!),
              ),
              title: Text(
                widget.comment.userName!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.dateString,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: widget.comment.userUid == FirebaseAuth.instance.currentUser?.uid
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
                    Get.find<CommentController>().deleteComment(widget.comment.commentId!, widget.postId);
                  }
                },
              )
                  : null,
            ),
            SizedBox(height: 8),
            Text(
              commentText!,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            if (!isTranslating)
              TextButton(
                onPressed: _toggleTranslation,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey, minimumSize: Size(100, 30),
                ),
                child: Text(buttonText),
              ),
            if (isTranslating)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
