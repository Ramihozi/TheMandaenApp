import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_comment.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);

  List<Comment> get comments => _comments.value;

  final _collectionReference = FirebaseFirestore.instance.collection("post");
  final _userCollection = FirebaseFirestore.instance.collection("user");

  final TextEditingController commentTextController = TextEditingController();

  String _postId = "";

  void getPostId(String id) {
    _postId = id;
    getComments();
  }

  Future<void> getComments() async {
    _comments.bindStream(
      _collectionReference
          .doc(_postId)
          .collection("comment")
          .orderBy("time", descending: true)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Comment> list = [];
        for (var element in querySnapshot.docs) {
          list.add(Comment.fromDocumentSnapshot(element));
        }
        return list;
      }),
    );
  }

  Future<void> addComment(String postId) async {
    // Fetch current user's information
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle if user is not logged in (optional)
      return;
    }

    // Fetch user's name and url from "user" collection
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection(
        "user").doc(currentUser.uid).get();
    String userName = userSnapshot.exists ? userSnapshot['name'] : '';
    String userUrl = userSnapshot.exists ? userSnapshot['url'] : '';

    // Generate a random comment ID
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    String randomStr = String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    // Add comment to Firestore
    await FirebaseFirestore.instance.collection("post").doc(postId).collection(
        "comment").doc(randomStr).set({
      "commentId": randomStr,
      "comment": commentTextController.text,
      "name": userName,
      "url": userUrl,
      "uid": currentUser.uid,
      "postId": postId,
      "time": DateTime
          .now()
          .millisecondsSinceEpoch,
    });

    // Update comments count
    FirebaseFirestore.instance.collection("post").doc(postId).get().then((
        DocumentSnapshot snapshot) async {
      int count = snapshot['commentsCount'];
      FirebaseFirestore.instance.collection("post").doc(postId).update(
          {"commentsCount": count + 1}).then((value) {
        commentTextController.text = '';
      });
    });
  }
}