import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String postId;
  String postUrl;
  String postTitle;
  String userName;
  String userUrl;
  String userUid;
  int time;
  List<String> likes;
  int commentsCount;
  List<String> comments;

  Post({
    required this.postId,
    required this.postUrl,
    required this.postTitle,
    required this.userName,
    required this.userUrl,
    required this.userUid,
    required this.time,
    required this.likes,
    required this.commentsCount,
    required this.comments,
  });

  Post.fromDocumentSnapshot(DocumentSnapshot documentSnapshot)
      : postId = documentSnapshot.id,
        postUrl = documentSnapshot['postUrl'] ?? '',
        postTitle = documentSnapshot['postTitle'] ?? '',
        userName = documentSnapshot['userName'] ?? '',
        userUrl = documentSnapshot['userUrl'] ?? '',
        userUid = documentSnapshot['userUid'] ?? '',
        time = documentSnapshot['time'] ?? 0,
        likes = (documentSnapshot['likes'] as List<dynamic>).map((like) => like.toString()).toList(),
        commentsCount = documentSnapshot['commentsCount'] ?? 0,
        comments = []; // Initialize comments as an empty list

  List<String> getComments() {
    return comments;
  }

  // Method to convert to JSON object for Firestore
  Map<String, dynamic> toJson() {
    return {
      'postUrl': postUrl,
      'postTitle': postTitle,
      'userName': userName,
      'userUrl': userUrl,
      'userUid': userUid,
      'time': time,
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }
}
